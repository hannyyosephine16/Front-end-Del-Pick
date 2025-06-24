import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:del_pick/app/config/environment_config.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/core/interceptors/auth_interceptor.dart';
import 'package:del_pick/core/interceptors/error_interceptor.dart';
import 'package:del_pick/core/interceptors/logging_interceptor.dart';
import 'package:del_pick/core/interceptors/connectivity_interceptor.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class ApiService extends getx.GetxService {
  // final Dio _dio;
  late Dio _dio;
  final StorageService _storageService = getx.Get.find<StorageService>();

  // Cache untuk token agar tidak membaca storage berulang kali
  String? _cachedToken;
  DateTime? _lastTokenCheck;
  static const Duration _tokenCacheTimeout = Duration(minutes: 1);

  Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvironmentConfig.productionUrl,
        connectTimeout: Duration(seconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(seconds: AppConstants.apiTimeout),
        sendTimeout: Duration(seconds: AppConstants.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        //response handling
        validateStatus: (status) => status! < 500,
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();

    //Auth -> Connectivity -> Logging -> Error
    _dio.interceptors.add(AuthInterceptor(_storageService));

    //Hanya tambahkan jika service tersedia
    try {
      _dio.interceptors.add(ConnectivityInterceptor());
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('Warning: ConnectivityInterceptor not available: $e');
      }
    }

    //Logging hanya untuk development
    if (EnvironmentConfig.enableLogging) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    // Error interceptor terakhir
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// GET request dengan improved error handling
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: _mergeOptions(options),
        cancelToken: cancelToken,
      );
      return _validateResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  /// POST request dengan improved handling
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options),
        cancelToken: cancelToken,
      );
      return _validateResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options),
        cancelToken: cancelToken,
      );
      return _validateResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options),
        cancelToken: cancelToken,
      );
      return _validateResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options),
        cancelToken: cancelToken,
      );
      return _validateResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  ///✅ FILE UPLOAD WITH BASE64 SUPPORT (sesuai backend)

  /// Upload file sebagai base64
  Future<Response> uploadBase64Image(
    String path,
    File file, {
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
  }) async {
    try {
      // ✅ Convert to base64 sesuai backend expectation
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final extension = file.path.split('.').last.toLowerCase();

      // ✅ Validasi format sesuai backend
      if (!AppConstants.allowedImageFormats.contains(extension)) {
        throw UnsupportedFileTypeException('Format $extension tidak didukung');
      }

      // ✅ Validasi size sesuai backend (5MB)
      if (bytes.length > AppConstants.maxImageSizeMB * 1024 * 1024) {
        throw FileSizeExceededException(AppConstants.maxImageSizeMB);
      }

      final requestData = {
        'image': 'data:image/$extension;base64,$base64String',
        ...?data,
      };

      final response =
          await post(path, data: requestData, cancelToken: cancelToken);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload file traditional multipart (jika diperlukan)
  Future<Response> uploadFile(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return _validateResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException('File upload failed: $e');
    }
  }

  // ===============================================
  // ✅ HELPER METHODS - BACKEND COMPATIBILITY
  // ===============================================

  /// Merge default options dengan custom options
  Options _mergeOptions(Options? options) {
    final defaultOptions = Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (options == null) return defaultOptions;

    return Options(
      method: options.method ?? defaultOptions.method,
      sendTimeout: options.sendTimeout ?? defaultOptions.sendTimeout,
      receiveTimeout: options.receiveTimeout ?? defaultOptions.receiveTimeout,
      extra: {...?defaultOptions.extra, ...?options.extra},
      headers: {...?defaultOptions.headers, ...?options.headers},
      responseType: options.responseType ?? defaultOptions.responseType,
      contentType: options.contentType ?? defaultOptions.contentType,
      validateStatus: options.validateStatus ?? defaultOptions.validateStatus,
      receiveDataWhenStatusError: options.receiveDataWhenStatusError ??
          defaultOptions.receiveDataWhenStatusError,
      followRedirects:
          options.followRedirects ?? defaultOptions.followRedirects,
      maxRedirects: options.maxRedirects ?? defaultOptions.maxRedirects,
    );
  }

  /// Validasi response format sesuai backend
  Response _validateResponse(Response response) {
    // ✅ Backend selalu mengembalikan JSON dengan struktur tertentu
    if (response.data is! Map<String, dynamic>) {
      throw DataParsingException();
    }

    final data = response.data as Map<String, dynamic>;

    // ✅ Backend format: { message, data?, errors? }
    if (!data.containsKey('message')) {
      throw DataParsingException();
    }

    return response;
  }

  /// Handle DioException sesuai backend error responses
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const ConnectionException();

      case DioExceptionType.badResponse:
        return _parseBackendError(e);

      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');

      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return const ConnectionException();
        }
        return NetworkException(e.message ?? 'Unknown network error');
    }
  }

  /// Parse backend error response format
  Exception _parseBackendError(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? 'An error occurred';
      final code = data['code']?.toString();
      final errors = data['errors'];

      // ✅ Handle validation errors sesuai backend format
      if (statusCode == 400 && errors != null) {
        Map<String, List<String>>? validationErrors;

        if (errors is Map<String, dynamic>) {
          validationErrors = <String, List<String>>{};
          errors.forEach((key, value) {
            if (value is List) {
              validationErrors![key] = value.cast<String>();
            } else if (value is String) {
              validationErrors![key] = [value];
            }
          });
        } else if (errors is String) {
          validationErrors = {
            'general': [errors]
          };
        }

        return ValidationException(message,
            errors: validationErrors, code: code);
      }

      // ✅ Handle specific backend status codes
      switch (statusCode) {
        case 401:
          if (message.toLowerCase().contains('token') ||
              message.toLowerCase().contains('expired')) {
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
          return ValidationException(message, code: code);

        case 429:
          return const TooManyRequestsException();

        default:
          return ServerException(statusCode, message, code: code);
      }
    }

    return ServerException(statusCode, 'Server error occurred');
  }

  //AUTHENTICATION METHODS

  /// Set authentication token dengan cache
  void setAuthToken(String token) {
    _cachedToken = token;
    _lastTokenCheck = DateTime.now();
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Get cached auth token
  String? getAuthToken() {
    final now = DateTime.now();

    // Refresh cache jika expired
    if (_lastTokenCheck == null ||
        now.difference(_lastTokenCheck!).compareTo(_tokenCacheTimeout) > 0) {
      _cachedToken = _storageService.readString(StorageConstants.authToken);
      _lastTokenCheck = now;
    }

    return _cachedToken;
  }

  /// Clear authentication
  void clearAuthToken() {
    _cachedToken = null;
    _lastTokenCheck = null;
    _dio.options.headers.remove('Authorization');
  }

  // ===============================================
  // ✅ UTILITY METHODS
  // ===============================================

  /// Create cancel token
  CancelToken createCancelToken() => CancelToken();

  /// Cancel requests
  void cancelRequests(CancelToken cancelToken, [String? reason]) {
    cancelToken.cancel(reason);
  }

  /// Check if request was cancelled
  bool isRequestCancelled(dynamic error) {
    return error is DioException && error.type == DioExceptionType.cancel;
  }

  /// Retry request
  Future<Response> retryRequest(RequestOptions requestOptions) async {
    return await _dio.fetch(requestOptions);
  }

  /// Refresh configuration
  void refreshConfiguration() {
    _initializeDio();
  }

  /// Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove custom header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Update base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Health check endpoint
  Future<bool> healthCheck() async {
    try {
      final response = await get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Clear all caches
  void clearCache() {
    _cachedToken = null;
    _lastTokenCheck = null;
  }
}
