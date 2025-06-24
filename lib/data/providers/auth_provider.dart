// lib/data/providers/auth_provider.dart - UPDATED untuk Result class existing
import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class AuthProvider {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthProvider({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<Result<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Call remote API
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save to local storage
      if (response['token'] != null) {
        await localDataSource.saveAuthToken(response['token']);

        // ✅ PENTING: Save user data juga
        if (response['user'] != null) {
          await localDataSource.saveUser(response['user']);
        }
      }

      return Result.success(response, 'Login berhasil');
    } on InvalidCredentialsException catch (e) {
      return Result.failure('Email atau password salah');
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } on NetworkException catch (e) {
      return Result.failure('Tidak ada koneksi internet');
    } on TimeoutException catch (e) {
      return Result.failure('Koneksi timeout. Silakan coba lagi');
    } on ServerException catch (e) {
      return Result.failure('Server bermasalah. Silakan coba lagi nanti');
    } catch (e) {
      print('❌ Login provider error: $e');
      return Result.failure('Terjadi kesalahan yang tidak terduga');
    }
  }

  Future<Result<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      return Result.success(response, 'Registrasi berhasil');
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } on AlreadyExistsException catch (e) {
      return Result.failure('Email sudah terdaftar');
    } on NetworkException catch (e) {
      return Result.failure('Tidak ada koneksi internet');
    } on ServerException catch (e) {
      return Result.failure('Server bermasalah. Silakan coba lagi nanti');
    } catch (e) {
      print('❌ Register provider error: $e');
      return Result.failure('Terjadi kesalahan yang tidak terduga');
    }
  }

  Future<Result<UserModel>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      final user = UserModel.fromJson(response);

      // Update local storage
      await localDataSource.saveUser(response);

      return Result.success(user, 'Profil berhasil diambil');
    } on NetworkException catch (e) {
      // Try to get cached user
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
        final user = UserModel.fromJson(cachedUser);
        return Result.success(user, 'Data dari cache');
      }
      return Result.failure('Tidak ada koneksi internet');
    } on UnauthorizedException catch (e) {
      // Token expired, clear local data
      await localDataSource.clearAuthData();
      return Result.failure('Sesi berakhir. Silakan login kembali');
    } on ServerException catch (e) {
      return Result.failure('Server bermasalah');
    } catch (e) {
      print('❌ Get profile provider error: $e');
      return Result.failure('Gagal mengambil data profil');
    }
  }

  Future<Result<UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final response = await remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
      );

      final user = UserModel.fromJson(response);
      await localDataSource.saveUser(response);

      return Result.success(user, 'Profil berhasil diperbarui');
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } on NetworkException catch (e) {
      return Result.failure('Tidak ada koneksi internet');
    } on ServerException catch (e) {
      return Result.failure('Server bermasalah');
    } catch (e) {
      print('❌ Update profile provider error: $e');
      return Result.failure('Gagal memperbarui profil');
    }
  }

  Future<Result<void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return Result.success(null, 'Link reset password telah dikirim ke email');
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } on NotFoundException catch (e) {
      return Result.failure('Email tidak terdaftar');
    } on NetworkException catch (e) {
      return Result.failure('Tidak ada koneksi internet');
    } on ServerException catch (e) {
      return Result.failure('Server bermasalah');
    } catch (e) {
      print('❌ Forgot password provider error: $e');
      return Result.failure('Gagal mengirim link reset password');
    }
  }

  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await remoteDataSource.resetPassword(token: token, password: password);
      return Result.success(null, 'Password berhasil direset');
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } on UnauthorizedException catch (e) {
      return Result.failure('Token reset tidak valid atau sudah expired');
    } on NetworkException catch (e) {
      return Result.failure('Tidak ada koneksi internet');
    } on ServerException catch (e) {
      return Result.failure('Server bermasalah');
    } catch (e) {
      print('❌ Reset password provider error: $e');
      return Result.failure('Gagal reset password');
    }
  }

  Future<Result<void>> logout() async {
    try {
      // Call API logout first (best effort)
      try {
        await remoteDataSource.logout();
      } catch (e) {
        print('⚠️ API logout failed, but continuing with local logout: $e');
      }

      // Always clear local data
      await localDataSource.clearAuthData();

      return Result.success(null, 'Logout berhasil');
    } catch (e) {
      print('❌ Logout provider error: $e');
      // Even if error, still try to clear local data
      try {
        await localDataSource.clearAuthData();
      } catch (clearError) {
        print('❌ Failed to clear local data: $clearError');
      }
      return Result.success(null, 'Logout berhasil');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await localDataSource.hasValidToken();
    } catch (e) {
      print('❌ Check login status error: $e');
      return false;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await localDataSource.getUser();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('❌ Get current user error: $e');
      return null;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await localDataSource.getAuthToken();
    } catch (e) {
      print('❌ Get auth token error: $e');
      return null;
    }
  }
}
