// lib/core/utils/dio_helper.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/errors/failures.dart';
import '../../data/models/base/base_model.dart';

class DioHelper {
  /// Create default Dio configuration
  static Dio createDio({
    String? baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
  }) {
    final dio = Dio();

    // Base configuration
    dio.options = BaseOptions(
      baseUrl: baseUrl ?? 'https://delpick.horas-code.my.id/api/v1',
      connectTimeout: Duration(
        seconds: connectTimeout ?? AppConstants.connectionTimeout,
      ),
      receiveTimeout: Duration(
        seconds: receiveTimeout ?? AppConstants.apiTimeout,
      ),
      sendTimeout: Duration(
        seconds: sendTimeout ?? AppConstants.apiTimeout,
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
      followRedirects: true,
      maxRedirects: 3,
    );

    return dio;
  }

  /// Handle API response and extract data
  static T handleResponse<T>(
    Response response,
    T Function(dynamic data) fromJson,
  ) {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        // Handle different response formats
        if (responseData is Map<String, dynamic>) {
          // Check if response has 'data' field (common API format)
          if (responseData.containsKey('data')) {
            return fromJson(responseData['data']);
          } else {
            return fromJson(responseData);
          }
        } else {
          return fromJson(responseData);
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: response.requestOptions,
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  /// Handle paginated API response
  static PaginatedResponse<T> handlePaginatedResponse<T>(
    Response response,
    T Function(dynamic data) fromJson,
  ) {
    try {
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'];

          // Extract pagination info
          final totalItems = data['totalItems'] as int? ?? 0;
          final totalPages = data['totalPages'] as int? ?? 1;
          final currentPage = data['currentPage'] as int? ?? 1;

          // Extract items (could be in 'items', 'stores', 'orders', etc.)
          List<dynamic> items = [];
          for (final key in [
            'items',
            'stores',
            'orders',
            'menuItems',
            'drivers',
            'customers'
          ]) {
            if (data[key] is List) {
              items = data[key];
              break;
            }
          }

          final parsedItems = items.map((item) => fromJson(item)).toList();

          return PaginatedResponse<T>(
            items: parsedItems,
            totalItems: totalItems,
            totalPages: totalPages,
            currentPage: currentPage,
          );
        }
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: response.requestOptions,
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  /// Create multipart file from File (for image upload)
  static Future<MultipartFile> createMultipartFile(
    File file, {
    String? filename,
    String? contentType,
  }) async {
    return MultipartFile.fromFile(
      file.path,
      filename: filename ?? file.path.split('/').last,
      contentType: contentType != null ? DioMediaType.parse(contentType) : null,
    );
  }

  /// Create form data for file upload
  static FormData createFormData(Map<String, dynamic> fields) {
    return FormData.fromMap(fields);
  }

  /// Parse error response to get user-friendly message
  static String parseErrorMessage(DioException error) {
    try {
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        // Try to get message from response
        if (data['message'] != null) {
          return data['message'].toString();
        }

        // Try to get first validation error
        if (data['errors'] is Map<String, dynamic>) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            } else if (firstError is String) {
              return firstError;
            }
          }
        }
      }

      // Fallback to default error messages
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network.';
        case DioExceptionType.badResponse:
          return _getStatusCodeMessage(error.response?.statusCode);
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return 'An unexpected error occurred. Please try again.';
      }
    } catch (e) {
      return 'An error occurred while processing the request.';
    }
  }

  /// Get user-friendly message for HTTP status codes
  static String _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'The resource already exists.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Convert DioException to Failure
  static Failure dioExceptionToFailure(DioException error) {
    return ErrorHandler.handleException(error);
  }

  /// Add retry logic to API calls
  static Future<Response<T>> retryRequest<T>(
    Future<Response<T>> Function() request, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(DioException)? retryCondition,
  }) async {
    DioException? lastError;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await request();
      } on DioException catch (e) {
        lastError = e;

        // Check if we should retry
        final shouldRetry =
            retryCondition?.call(e) ?? _defaultRetryCondition(e);

        if (attempt < maxRetries && shouldRetry) {
          await Future.delayed(delay * (attempt + 1)); // Exponential backoff
          continue;
        }

        rethrow;
      }
    }

    throw lastError!;
  }

  /// Default retry condition
  static bool _defaultRetryCondition(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  /// Log request and response for debugging
  static void logRequest(RequestOptions options) {
    if (kDebugMode) {
      print('\n🔥 REQUEST 🔥');
      print('Method: ${options.method}');
      print('URL: ${options.uri}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Data: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('Query: ${options.queryParameters}');
      }
      print('🔥 END REQUEST 🔥\n');
    }
  }

  /// Log response for debugging
  static void logResponse(Response response) {
    if (kDebugMode) {
      print('\n✅ RESPONSE ✅');
      print('Status: ${response.statusCode}');
      print('URL: ${response.requestOptions.uri}');
      print('Data: ${response.data}');
      print('✅ END RESPONSE ✅\n');
    }
  }

  /// Log error for debugging
  static void logError(DioException error) {
    if (kDebugMode) {
      print('\n❌ ERROR ❌');
      print('Type: ${error.type}');
      print('Message: ${error.message}');
      print('URL: ${error.requestOptions.uri}');
      if (error.response != null) {
        print('Status: ${error.response?.statusCode}');
        print('Data: ${error.response?.data}');
      }
      print('❌ END ERROR ❌\n');
    }
  }

  /// Create request options with timeout
  static Options createRequestOptions({
    Duration? timeout,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
  }) {
    return Options(
      sendTimeout: timeout,
      receiveTimeout: timeout,
      headers: headers,
      responseType: responseType ?? ResponseType.json,
    );
  }

  /// Build query parameters string
  static String buildQueryString(Map<String, dynamic> params) {
    final queryParams = params.entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    return queryParams.isNotEmpty ? '?$queryParams' : '';
  }

  /// Validate response structure
  static bool isValidResponse(Response response) {
    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300 &&
        response.data != null;
  }

  /// Extract message from API response
  static String? extractMessage(Response response) {
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return data['message']?.toString();
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
