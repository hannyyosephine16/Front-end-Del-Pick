// lib/data/datasources/remote/auth_remote_datasource.dart - FIXED
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/errors/exceptions.dart';
import 'package:del_pick/core/utils/validators.dart';

class AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource(this._apiService);

  // ✅ FIXED: Login sesuai backend response format
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
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

  // ✅ FIXED: Register sesuai backend
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
        },
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ✅ FIXED: Get profile sesuai backend
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ✅ FIXED: Update profile sesuai backend
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ✅ FIXED: Forgot password sesuai backend
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ✅ FIXED: Reset password sesuai backend
  Future<void> resetPassword({
    required String token,
    required String password, // ✅ FIXED: backend expects 'password'
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiEndpoints.resetPassword}/$token', // ✅ FIXED: token in URL
        data: {'password': password},
      );

      _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ✅ FIXED: Logout sesuai backend
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ✅ FIXED: Handle response sesuai backend format
  Map<String, dynamic> _handleAuthResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return data['data'] ?? data;
    }
    throw AuthException(response.data['message'] ?? 'Authentication failed');
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      return data['data'] ?? data;
    }
    throw ServerException(
      response.statusCode ?? 500,
      response.data['message'] ?? 'Request failed',
    );
  }

  AppException _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return ValidationException(
          e.response?.data['message'] ?? 'Invalid request data',
        );
      case 401:
        final message =
            e.response?.data['message']?.toString().toLowerCase() ?? '';
        if (message.contains('password') || message.contains('salah')) {
          return const InvalidCredentialsException();
        }
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return NotFoundException(
          e.response?.data['message'] ?? 'Resource not found',
        );
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
}
