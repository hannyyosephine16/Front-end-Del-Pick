// lib/core/services/api/api_service.dart - FIXED
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/interceptors/auth_interceptor.dart';
import 'package:del_pick/core/interceptors/connectivity_interceptor.dart';
import 'package:del_pick/core/interceptors/error_interceptor.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';

class ApiService extends GetxService {
  late final Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();

  Dio get dio => _dio;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeDio();
  }

  Future<void> _initializeDio() async {
    _dio = Dio();

    // Base configuration
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30), // Increase timeout
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        // Accept all status codes, let interceptors handle errors
        return status != null && status < 500;
      },
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'DelPick-Flutter-App/1.0.0',
      },
      followRedirects: true,
      maxRedirects: 5,
    );

    // Add logging interceptor for debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }

    // Add custom interceptors in correct order
    _dio.interceptors.addAll([
      ConnectivityInterceptor(), // Check connectivity first
      AuthInterceptor(_storageService), // Handle auth
      ErrorInterceptor(), // Handle errors last
    ]);

    // Load saved token if exists
    await _loadAuthToken();

    if (kDebugMode) {
      debugPrint(
          '✅ ApiService initialized with base URL: ${ApiEndpoints.baseUrl}');
    }
  }

  Future<void> _loadAuthToken() async {
    try {
      final token = _storageService.readString(StorageConstants.authToken);
      if (token != null && token.isNotEmpty) {
        setAuthToken(token);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to load auth token: $e');
      }
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    if (kDebugMode) {
      debugPrint('🔐 Auth token set');
    }
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    if (kDebugMode) {
      debugPrint('🔓 Auth token cleared');
    }
  }

  // ✅ HTTP Methods with better error handling
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 GET Request: $path');
        if (queryParameters != null) {
          debugPrint('📝 Query Parameters: $queryParameters');
        }
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      if (kDebugMode) {
        debugPrint('✅ GET Success: ${response.statusCode}');
      }

      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ GET Error: ${e.type} - ${e.message}');
        debugPrint('URL: ${e.requestOptions.uri}');
        debugPrint('Status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 POST Request: $path');
        if (data != null) {
          // Don't log sensitive data like passwords
          final logData = Map<String, dynamic>.from(data);
          if (logData.containsKey('password')) {
            logData['password'] = '***';
          }
          debugPrint('📝 Request Data: $logData');
        }
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (kDebugMode) {
        debugPrint('✅ POST Success: ${response.statusCode}');
      }

      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ POST Error: ${e.type} - ${e.message}');
        debugPrint('URL: ${e.requestOptions.uri}');
        debugPrint('Status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 PUT Request: $path');
      }

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (kDebugMode) {
        debugPrint('✅ PUT Success: ${response.statusCode}');
      }

      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PUT Error: ${e.type} - ${e.message}');
      }
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DELETE Request: $path');
      }

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (kDebugMode) {
        debugPrint('✅ DELETE Success: ${response.statusCode}');
      }

      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DELETE Error: ${e.type} - ${e.message}');
      }
      rethrow;
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 PATCH Request: $path');
      }

      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (kDebugMode) {
        debugPrint('✅ PATCH Success: ${response.statusCode}');
      }

      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PATCH Error: ${e.type} - ${e.message}');
      }
      rethrow;
    }
  }

  // ✅ Test connection method
  Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Testing connection to: ${ApiEndpoints.baseUrl}');
      }

      final response = await _dio.get(
        '/v1/health',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final isSuccess = response.statusCode == 200;
      if (kDebugMode) {
        debugPrint(isSuccess
            ? '✅ Connection test passed'
            : '❌ Connection test failed');
      }

      return isSuccess;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Connection test error: $e');
      }
      return false;
    }
  }

  // ✅ Retry mechanism for failed requests
  Future<Response> retryRequest(
    Future<Response> Function() request, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    DioException? lastError;

    while (attempts < maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        lastError = e;
        attempts++;

        if (attempts >= maxRetries) {
          if (kDebugMode) {
            debugPrint('❌ Max retry attempts reached: $maxRetries');
          }
          rethrow;
        }

        // Only retry for certain error types
        if (_shouldRetry(e)) {
          if (kDebugMode) {
            debugPrint('🔄 Retrying request (attempt $attempts/$maxRetries)');
          }
          await Future.delayed(delay * attempts);
        } else {
          rethrow;
        }
      }
    }

    throw lastError ?? const UnknownException('Max retries exceeded');
  }

  bool _shouldRetry(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // Only retry for 5xx server errors
        final statusCode = error.response?.statusCode;
        return statusCode != null && statusCode >= 500;
      default:
        return false;
    }
  }
}

// Custom exception for unknown errors
class UnknownException implements Exception {
  final String message;
  const UnknownException(this.message);

  @override
  String toString() => 'UnknownException: $message';
}
