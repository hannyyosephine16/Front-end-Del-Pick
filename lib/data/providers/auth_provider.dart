// lib/data/providers/auth_provider.dart - FIXED VERSION
import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/auth/login_response_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class AuthProvider {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthProvider({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // ✅ Login - Sesuai backend response format
  Future<Result<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginData = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Parse login response model
      final loginResponse = LoginResponseModel.fromJson(loginData);

      // Save token and user data locally
      await _localDataSource.saveAuthToken(loginResponse.token);
      await _localDataSource.saveUser(loginResponse.user);

      return Result.success(loginResponse);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Login failed: ${e.toString()}');
    }
  }

  // ✅ Register - Sesuai backend response
  Future<Result<UserModel>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final registerData = await _remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      final user = UserModel.fromJson(registerData);
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Registration failed: ${e.toString()}');
    }
  }

  // ✅ Get Profile - Returns UserModel
  Future<Result<UserModel>> getProfile() async {
    try {
      final profileData = await _remoteDataSource.getProfile();
      final user = UserModel.fromJson(profileData);

      // Update local storage
      await _localDataSource.saveUser(user);

      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to get profile: ${e.toString()}');
    }
  }

  // ✅ Update Profile - Returns UserModel
  Future<Result<UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final updatedData = await _remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
      );

      final user = UserModel.fromJson(updatedData);

      // Update local storage
      await _localDataSource.saveUser(user);

      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to update profile: ${e.toString()}');
    }
  }

  // ✅ Update FCM Token
  Future<Result<void>> updateFcmToken(String fcmToken) async {
    try {
      await _remoteDataSource.updateFcmToken(fcmToken);

      // Update local storage FCM token
      await _localDataSource.updateUserProfile(fcmToken: fcmToken);

      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to update FCM token: ${e.toString()}');
    }
  }

  // ✅ Forgot Password
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to send password reset: ${e.toString()}');
    }
  }

  // ✅ Reset Password
  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        token: token,
        password: password,
      );
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to reset password: ${e.toString()}');
    }
  }

  // ✅ Logout
  Future<Result<void>> logout() async {
    try {
      // Call remote logout (clear server session if needed)
      await _remoteDataSource.logout();

      // Clear local data
      await _localDataSource.clearAuthData();

      return Result.success(null);
    } on AppException catch (e) {
      // Even if remote logout fails, clear local data
      await _localDataSource.clearAuthData();
      return Result.failure(e.message);
    } catch (e) {
      // Even if remote logout fails, clear local data
      await _localDataSource.clearAuthData();
      return Result.failure('Logout failed: ${e.toString()}');
    }
  }

  // ✅ Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      return await _localDataSource.hasValidToken();
    } catch (e) {
      return false;
    }
  }

  // ✅ Get current user from local storage
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _localDataSource.getUser();
    } catch (e) {
      return null;
    }
  }

  // ✅ Get auth token
  Future<String?> getAuthToken() async {
    try {
      return await _localDataSource.getAuthToken();
    } catch (e) {
      return null;
    }
  }

  // ✅ Clear all auth data (for emergency logout)
  Future<void> clearAllAuthData() async {
    try {
      await _localDataSource.clearAuthData();
    } catch (e) {
      // Silent fail for cleanup
    }
  }
}
