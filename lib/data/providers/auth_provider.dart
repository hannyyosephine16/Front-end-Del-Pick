// lib/data/providers/auth_provider.dart
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
        await localDataSource.saveUser(response['user']);
      }

      return Result.success(response);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('An unexpected error occurred: $e');
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

      return Result.success(response);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<UserModel>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      final user = UserModel.fromJson(response);
      await localDataSource.saveUser(response);
      return Result.success(user);
    } on NetworkException catch (e) {
      // Try to get cached user
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
        return Result.success(UserModel.fromJson(cachedUser));
      }
      return Result.failure(e.message);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('An unexpected error occurred: $e');
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
      return Result.success(user);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await remoteDataSource.resetPassword(token: token, password: password);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(e.message);
    } on ServerException catch (e) {
      return Result.failure(e.message);
    } on ValidationException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return Result.success(null);
    } catch (e) {
      // Clear local data even if API call fails
      await localDataSource.clearAuthData();
      return Result.success(null);
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserModel?> getCurrentUser() async {
    final userData = await localDataSource.getUser();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  Future<String?> getAuthToken() async {
    return await localDataSource.getAuthToken();
  }
}
