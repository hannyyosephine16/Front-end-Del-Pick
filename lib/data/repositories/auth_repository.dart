// lib/data/repositories/auth_repository.dart - FINAL
import 'package:flutter/foundation.dart';
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

  // ✅ Login dengan error handling yang proper
  Future<Result<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 AuthRepository.login: $email');
      }

      // Call remote data source
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ Remote login response received');
        debugPrint('📝 Response keys: ${response.keys.toList()}');
      }

      // Create LoginResponseModel
      final loginResponse = LoginResponseModel.fromBackendResponse(response);

      if (kDebugMode) {
        debugPrint('✅ LoginResponseModel created successfully');
        debugPrint('📝 User: ${loginResponse.user.name}');
        debugPrint('📝 Role: ${loginResponse.user.role}');
      }

      // Save to local storage
      await _localDataSource.saveAuthToken(loginResponse.token);
      await _localDataSource.saveUser(loginResponse.user);

      // Save role-specific data if available
      if (loginResponse.hasDriver && loginResponse.driver != null) {
        await _localDataSource.saveDriverData(loginResponse.driver!.toJson());
        if (kDebugMode) {
          debugPrint('✅ Driver data saved');
        }
      }

      if (loginResponse.hasStore && loginResponse.store != null) {
        await _localDataSource.saveStoreData(loginResponse.store!.toJson());
        if (kDebugMode) {
          debugPrint('✅ Store data saved');
        }
      }

      return Result.success(loginResponse);
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AppException in login: ${e.toString()}');
      }
      return Result.failure(e.message);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error in login: ${e.toString()}');
        debugPrint('📝 StackTrace: $stackTrace');
      }
      return Result.failure('Login failed: ${e.toString()}');
    }
  }

  // ✅ Register
  Future<Result<UserModel>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 AuthRepository.register: $email, role: $role');
      }

      final response = await _remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      final user = UserModel.fromJson(response);

      if (kDebugMode) {
        debugPrint('✅ Registration successful: ${user.name}');
      }

      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Registration failed: ${e.toString()}');
    }
  }

  // ✅ Get profile
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
      return Result.failure('Get profile failed: ${e.toString()}');
    }
  }

  // ✅ Update profile
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
      return Result.failure('Update profile failed: ${e.toString()}');
    }
  }

  // ✅ Update FCM token
  Future<Result<void>> updateFcmToken(String fcmToken) async {
    try {
      await _remoteDataSource.updateFcmToken(fcmToken);
      await _localDataSource.updateUserProfile(fcmToken: fcmToken);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Update FCM token failed: ${e.toString()}');
    }
  }

  // ✅ Forgot password
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Forgot password failed: ${e.toString()}');
    }
  }

  // ✅ Reset password
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
      return Result.failure('Reset password failed: ${e.toString()}');
    }
  }

  // ✅ Logout
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
      return Result.failure('Logout failed: ${e.toString()}');
    }
  }

  // ✅ Helper methods
  Future<bool> isLoggedIn() async {
    return await _localDataSource.hasValidToken();
  }

  Future<UserModel?> getCurrentUser() async {
    return await _localDataSource.getUser();
  }

  Future<String?> getAuthToken() async {
    return await _localDataSource.getAuthToken();
  }

  Future<void> clearAuthData() async {
    await _localDataSource.clearAuthData();
  }
}
