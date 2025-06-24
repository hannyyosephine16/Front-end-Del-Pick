// lib/data/repositories/auth_repository.dart - FIXED
import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/auth/login_response_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepository(this._remoteDataSource, this._localDataSource);

  Future<Result<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      final loginResponse = LoginResponseModel.fromJson(response);

      // Save to local storage
      await _localDataSource.saveAuthToken(loginResponse.token);
      await _localDataSource.saveUser(loginResponse.user);

      return Result.success(loginResponse);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure(e.toString());
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
      final response = await _remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      final user = UserModel.fromJson(response);
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<UserModel>> getProfile() async {
    try {
      final response = await _remoteDataSource.getProfile();
      final user = UserModel.fromJson(response);

      // Update local storage
      await _localDataSource.saveUser(user);

      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final response = await _remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
      );

      final user = UserModel.fromJson(response);

      // Update local storage
      await _localDataSource.updateUserProfile(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
      );

      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure(e.toString());
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
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _remoteDataSource.resetPassword(token: token, password: password);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearAuthData();
      return Result.success(null);
    } on AppException catch (e) {
      await _localDataSource.clearAuthData(); // Clear local data anyway
      return Result.failure(e.message);
    } catch (e) {
      await _localDataSource.clearAuthData(); // Clear local data anyway
      return Result.failure(e.toString());
    }
  }

  Future<bool> isLoggedIn() async {
    return await _localDataSource.hasValidToken();
  }

  Future<UserModel?> getCurrentUser() async {
    return await _localDataSource.getUser();
  }

  Future<String?> getAuthToken() async {
    return await _localDataSource.getAuthToken();
  }
}
