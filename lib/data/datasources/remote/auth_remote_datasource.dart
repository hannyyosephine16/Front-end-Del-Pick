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
      // Validate input first
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw const ValidationException('Email and password are required');
      }

      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      return _handleAuthResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
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
      // Validate input data
      if (name.trim().isEmpty) {
        throw const ValidationException('Name is required');
      }
      if (email.trim().isEmpty) {
        throw const ValidationException('Email is required');
      }
      if (phone.trim().isEmpty) {
        throw const ValidationException('Phone is required');
      }
      if (password.trim().isEmpty) {
        throw const ValidationException('Password is required');
      }
      if (!['customer', 'driver', 'store'].contains(role)) {
        throw const ValidationException('Invalid role');
      }

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
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // ✅ FIXED: Get profile sesuai backend
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
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
      if (name != null && name.trim().isNotEmpty) data['name'] = name;
      if (email != null && email.trim().isNotEmpty) data['email'] = email;
      if (phone != null && phone.trim().isNotEmpty) data['phone'] = phone;
      if (avatar != null && avatar.trim().isNotEmpty) data['avatar'] = avatar;

      if (data.isEmpty) {
        throw const ValidationException('At least one field must be provided');
      }

      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // ✅ FIXED: Update FCM token sesuai backend
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateFcmToken,
        data: {'fcm_token': fcmToken},
      );

      _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // ✅ FIXED: Forgot password sesuai backend
  Future<void> forgotPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw const ValidationException('Email is required');
      }

      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // ✅ FIXED: Reset password sesuai backend
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      if (token.trim().isEmpty) {
        throw const ValidationException('Token is required');
      }
      if (password.trim().isEmpty) {
        throw const ValidationException('Password is required');
      }

      final response = await _apiService.post(
        '${ApiEndpoints.resetPassword}/$token',
        data: {'password': password},
      );

      _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // ✅ FIXED: Logout sesuai backend
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // ✅ FIXED: Handle auth response sesuai backend format
  Map<String, dynamic> _handleAuthResponse(Response response) {
    if (response.statusCode == 200) {
      final responseData = response.data as Map<String, dynamic>;

      // Backend returns { message: string, data: { token, user, driver?, store? } }
      if (responseData.containsKey('data')) {
        return responseData['data'] as Map<String, dynamic>;
      }

      // Fallback jika struktur berbeda
      return responseData;
    }

    throw AuthException(
      response.data?['message'] ?? 'Authentication failed',
      code: response.statusCode?.toString(),
    );
  }

  // ✅ FIXED: Handle general response sesuai backend format
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data as Map<String, dynamic>;

      // Backend format: { message: string, data: any }
      if (responseData.containsKey('data')) {
        return responseData['data'] as Map<String, dynamic>;
      }

      // Fallback
      return responseData;
    }

    throw ServerException(
      response.statusCode ?? 500,
      response.data?['message'] ?? 'Request failed',
      code: response.statusCode?.toString(),
    );
  }

  // ✅ FIXED: Handle Dio exceptions sesuai backend error responses
  AppException _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data as Map<String, dynamic>?;
    final message = responseData?['message']?.toString() ?? 'Network error';

    switch (statusCode) {
      case 400:
        // Handle validation errors dari backend
        if (responseData?.containsKey('errors') == true) {
          final errors = responseData!['errors'] as Map<String, dynamic>?;
          return ValidationException(
            message,
            errors: errors?.map((key, value) => MapEntry(
                  key,
                  (value as List?)?.map((e) => e.toString()).toList() ??
                      [value.toString()],
                )),
          );
        }
        return ValidationException(message);

      case 401:
        // Handle different types of 401 errors dari backend
        if (message.toLowerCase().contains('password') ||
            message.toLowerCase().contains('salah') ||
            message.toLowerCase().contains('invalid')) {
          return const InvalidCredentialsException();
        }
        if (message.toLowerCase().contains('token')) {
          return const TokenExpiredException();
        }
        return const UnauthorizedException();

      case 403:
        return const ForbiddenException();

      case 404:
        return NotFoundException(message);

      case 409:
        return AlreadyExistsException(message);

      case 429:
        return const TooManyRequestsException();

      case 500:
        return const InternalServerException();

      case 502:
        return const BadGatewayException();

      case 503:
        return const ServiceUnavailableException();

      case 504:
        return const GatewayTimeoutException();

      default:
        // Handle Dio-specific errors
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            return const TimeoutException();

          case DioExceptionType.connectionError:
            return const ConnectionException();

          case DioExceptionType.badResponse:
            return ServerException(
              statusCode ?? 500,
              message,
              code: statusCode?.toString(),
            );

          case DioExceptionType.cancel:
            return const NetworkException('Request was cancelled');

          case DioExceptionType.unknown:
          default:
            return NetworkException(e.message ?? 'Unknown network error');
        }
    }
  }
}
