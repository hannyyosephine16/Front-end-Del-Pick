import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/utils/validators.dart';

class AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource(this._apiService);

  // Future<Map<String, dynamic>> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final response = await _apiService.post(
  //       ApiEndpoints.login,
  //       data: {'email': email, 'password': password},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return response.data['data'];
  //     } else {
  //       throw Exception(response.data['message'] ?? 'Login failed');
  //     }
  //   } on DioException catch (e) {
  //     throw Exception(e.response?.data['message'] ?? 'Network error');
  //   }
  // }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // ✅ One liner validation
      Validators.validateLoginData(email, password);

      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      return _handleAuthResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? password,
    String? avatar,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (password != null) data['password'] = password;
      if (avatar != null) data['avatar'] = avatar;

      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Update failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data['message'] ?? 'Failed to send reset email',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to reset password');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      // Logout can fail but we should still clear local data
      throw Exception(e.response?.data['message'] ?? 'Logout failed');
    }
  }

  AppException _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return ValidationException(
            e.response?.data['message'] ?? 'Invalid request data');
      case 401:
        // Cek apakah ini invalid credentials atau unauthorized
        final message =
            e.response?.data['message']?.toString().toLowerCase() ?? '';
        if (message.contains('invalid') ||
            message.contains('password') ||
            message.contains('email')) {
          return const InvalidCredentialsException();
        }
        return const UnauthorizedException();
      case 403:
        // Cek apakah ini account not verified
        final message =
            e.response?.data['message']?.toString().toLowerCase() ?? '';
        if (message.contains('verify') || message.contains('activation')) {
          return const AccountNotVerifiedException();
        }
        return const ForbiddenException();
      case 404:
        return NotFoundException(
            e.response?.data['message'] ?? 'Resource not found');
      case 429:
        return const TooManyRequestsException();
      case 500:
      case 502:
      case 503:
        return NetworkException(e.response?.data['message'] ?? 'Server error');
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return const TimeoutException();
        }
        if (e.type == DioExceptionType.connectionError) {
          return const ConnectionException();
        }
        return NetworkException(e.message ?? 'Unknown network error');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Map<String, dynamic> _handleAuthResponse(Response response) {
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'];
    }
    throw AuthException(response.data['message'] ?? 'Authentication failed');
  }
}
