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

  Future<Result<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginData = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      final loginResponse = LoginResponseModel.fromJson(loginData);

      await _localDataSource.saveAuthToken(loginResponse.token);
      await _localDataSource.saveUser(loginResponse.user);

      return Result.success(loginResponse);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Login failed: ${e.toString()}');
    }
  }

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

  Future<Result<UserModel>> getProfile() async {
    try {
      final profileData = await _remoteDataSource.getProfile();
      final user = UserModel.fromJson(profileData);

      await _localDataSource.saveUser(user);

      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to get profile: ${e.toString()}');
    }
  }

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
      await _localDataSource.saveUser(user);

      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to update profile: ${e.toString()}');
    }
  }

  Future<Result<void>> updateFcmToken(String fcmToken) async {
    try {
      await _remoteDataSource.updateFcmToken(fcmToken);
      await _localDataSource.updateUserProfile(fcmToken: fcmToken);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to update FCM token: ${e.toString()}');
    }
  }

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

  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearAuthData();
      return Result.success(null);
    } on AppException catch (e) {
      await _localDataSource.clearAuthData();
      return Result.failure(e.message);
    } catch (e) {
      await _localDataSource.clearAuthData();
      return Result.failure('Logout failed: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await _localDataSource.hasValidToken();
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return await _localDataSource.getUser();
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _localDataSource.getAuthToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAllAuthData() async {
    try {
      await _localDataSource.clearAuthData();
    } catch (e) {
      // Silent fail
    }
  }
}
