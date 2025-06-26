// lib/data/datasources/remote/auth_remote_datasource.dart - SIMPLIFIED FIX
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource(this._apiService);

  // ✅ FIXED: Login yang tidak throwing exception pada response sukses
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 AuthRemoteDataSource.login: $email');
      }

      // Validate input first
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw const ValidationException('Email and password are required');
      }

      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (kDebugMode) {
        debugPrint('✅ Login response received');
        debugPrint('📝 Status: ${response.statusCode}');
        debugPrint('📝 Response type: ${response.data.runtimeType}');
      }

      // ⚠️ CRITICAL FIX: Jangan throw exception jika response sukses
      if (response.statusCode == 200) {
        return _handleSuccessResponse(response.data);
      }

      // Jika bukan 200, handle sebagai error
      throw AuthException('Login failed with status ${response.statusCode}');
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException in login: ${e.toString()}');
        debugPrint('🔍 Response status: ${e.response?.statusCode}');
        debugPrint('🔍 Response data: ${e.response?.data}');
      }
      throw _handleDioException(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ General exception in login: ${e.toString()}');
      }
      if (e is AppException) rethrow;
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  // ✅ Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 AuthRemoteDataSource.register: $email');
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

      return _handleSuccessResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  // ✅ Get profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);
      return _handleSuccessResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Get profile failed: ${e.toString()}');
    }
  }

  // ✅ Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name?.trim().isNotEmpty == true) data['name'] = name;
      if (email?.trim().isNotEmpty == true) data['email'] = email;
      if (phone?.trim().isNotEmpty == true) data['phone'] = phone;
      if (avatar?.trim().isNotEmpty == true) data['avatar'] = avatar;

      if (data.isEmpty) {
        throw const ValidationException('At least one field must be provided');
      }

      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      return _handleSuccessResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Update profile failed: ${e.toString()}');
    }
  }

  // ✅ Update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateFcmToken,
        data: {'fcm_token': fcmToken},
      );

      _handleSuccessResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Update FCM token failed: ${e.toString()}');
    }
  }

  // ✅ Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw const ValidationException('Email is required');
      }

      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      _handleSuccessResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Forgot password failed: ${e.toString()}');
    }
  }

  // ✅ Reset password
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

      _handleSuccessResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Reset password failed: ${e.toString()}');
    }
  }

  // ✅ Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      // Ignore 401 errors on logout (already logged out)
      if (e.response?.statusCode == 401) return;
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  // ✅ CRITICAL FIX: Handle success response TANPA throw exception
  Map<String, dynamic> _handleSuccessResponse(dynamic responseData) {
    try {
      if (kDebugMode) {
        debugPrint(
            '🔍 _handleSuccessResponse input type: ${responseData.runtimeType}');
      }

      // Pastikan response adalah Map
      if (responseData is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint(
              '❌ Response is not Map<String, dynamic>: ${responseData.runtimeType}');
        }
        throw const DataParsingException();
      }

      final data = Map<String, dynamic>.from(responseData);

      if (kDebugMode) {
        debugPrint('✅ Response is valid Map with keys: ${data.keys.toList()}');
      }

      // Backend DelPick format: { message: string, data: { ... } }
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        final resultData = data['data'] as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint(
              '✅ Returning data from response: ${resultData.keys.toList()}');
        }
        return resultData;
      }

      // Fallback: jika tidak ada key 'data', return seluruh response
      if (kDebugMode) {
        debugPrint('⚠️ No data key found, returning entire response');
      }
      return data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error in _handleSuccessResponse: ${e.toString()}');
      }
      if (e is AppException) rethrow;
      throw DataParsingException();
    }
  }

  // ✅ DIO EXCEPTION HANDLER
  AppException _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data as Map<String, dynamic>?;
    final message = responseData?['message']?.toString() ?? 'Network error';

    switch (statusCode) {
      case 400:
        if (responseData?.containsKey('errors') == true) {
          return ValidationException(message,
              errors: _parseValidationErrors(responseData!['errors']));
        }
        return ValidationException(message);

      case 401:
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
      case 422:
        return ValidationException(message,
            errors: _parseValidationErrors(responseData?['errors']));
      case 429:
        return const TooManyRequestsException();
      case 500:
        return const InternalServerException();

      default:
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            return const TimeoutException();
          case DioExceptionType.connectionError:
            return const ConnectionException();
          case DioExceptionType.cancel:
            return const NetworkException('Request was cancelled');
          default:
            return NetworkException(e.message ?? 'Unknown network error');
        }
    }
  }

  // ✅ Parse validation errors
  Map<String, List<String>>? _parseValidationErrors(dynamic errors) {
    if (errors == null) return null;

    final Map<String, List<String>> result = {};

    if (errors is Map<String, dynamic>) {
      errors.forEach((key, value) {
        if (value is List) {
          result[key] = value.cast<String>();
        } else if (value is String) {
          result[key] = [value];
        }
      });
    } else if (errors is String) {
      result['general'] = [errors];
    }

    return result.isNotEmpty ? result : null;
  }
}
