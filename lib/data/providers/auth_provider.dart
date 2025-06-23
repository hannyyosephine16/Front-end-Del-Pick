// lib/data/providers/auth_provider.dart - FIXED
import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/core/utils/result.dart';

class AuthProvider {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthProvider({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // Login sesuai backend response
  Future<Result<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Backend returns { token, user }
      if (result['token'] != null && result['user'] != null) {
        await localDataSource.saveAuthToken(result['token']);
        await localDataSource.saveUser(UserModel.fromJson(result['user']));
      }

      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // Register method
  Future<Result<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  //Get profile
  Future<Result<UserModel>> getProfile() async {
    try {
      final result = await remoteDataSource.getProfile();
      final user = UserModel.fromJson(result);

      await localDataSource.saveUser(user);
      return Result.success(user);
    } catch (e) {
      try {
        final localUser = await localDataSource.getUser();
        if (localUser != null) {
          return Result.success(localUser);
        }
      } catch (_) {}

      return Result.failure(e.toString());
    }
  }

  //Update profile
  Future<Result<UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final result = await remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
      );

      final user = UserModel.fromJson(result);
      await localDataSource.saveUser(user);

      return Result.success(user);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  //Reset password parameter
  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        token: token,
        password: password,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return Result.success(null);
    } catch (e) {
      await localDataSource.clearAuthData();
      return Result.failure(e.toString());
    }
  }

  // ✅ ADDED: Helper methods
  Future<bool> isLoggedIn() async {
    return await localDataSource.hasValidToken();
  }

  Future<UserModel?> getCurrentUser() async {
    return await localDataSource.getUser();
  }

  Future<String?> getAuthToken() async {
    return await localDataSource.getAuthToken();
  }
}
