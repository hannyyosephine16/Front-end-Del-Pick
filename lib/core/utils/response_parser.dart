// lib/core/utils/response_parser.dart

import 'package:dio/dio.dart';

/// Flexible Response Parser untuk handle berbagai format response backend
class ResponseParser {
  /// Parse successful response dengan berbagai format yang ada di backend
  static Map<String, dynamic> parseSuccessResponse(Response response) {
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      // Fallback untuk response yang bukan object
      return {
        'success': true,
        'message': 'Success',
        'data': data,
        'statusCode': response.statusCode, // Dari HTTP header, bukan body
      };
    }

    final responseData = Map<String, dynamic>.from(data);

    // Extract base fields yang selalu ada
    final result = {
      'success': true,
      'message': responseData['message'] ?? 'Success',
      'statusCode': response.statusCode, // Dari HTTP header, bukan body
    };

    // Handle berbagai format data dan pagination
    final parsedData = _parseDataAndPagination(responseData);
    result.addAll(parsedData);

    return result;
  }

  /// Parse data dan pagination dari berbagai format
  static Map<String, dynamic> _parseDataAndPagination(
      Map<String, dynamic> responseData) {
    final result = <String, dynamic>{};

    // Case 1: Pagination di root level (driverController, dll)
    // Format: { message, data, totalItems, totalPages, currentPage }
    if (responseData.containsKey('totalItems')) {
      result['data'] = responseData['data'];
      result['pagination'] = {
        'totalItems': responseData['totalItems'],
        'totalPages': responseData['totalPages'],
        'currentPage': responseData['currentPage'],
      };
      return result;
    }

    // Case 2: Pagination dalam data object (customerController)
    // Format: { message, data: { total_items, total_pages, current_page, customers } }
    final dataObj = responseData['data'];
    if (dataObj is Map<String, dynamic>) {
      // Check for snake_case pagination
      if (dataObj.containsKey('total_items')) {
        result['pagination'] = {
          'totalItems': dataObj['total_items'],
          'totalPages': dataObj['total_pages'],
          'currentPage': dataObj['current_page'],
        };

        // Extract actual data (remove pagination keys)
        final actualData = Map<String, dynamic>.from(dataObj);
        actualData.remove('total_items');
        actualData.remove('total_pages');
        actualData.remove('current_page');

        // If only one key left, use its value directly
        if (actualData.length == 1) {
          result['data'] = actualData.values.first;
        } else {
          result['data'] = actualData;
        }
        return result;
      }

      // Check for camelCase pagination in data
      if (dataObj.containsKey('totalItems')) {
        result['pagination'] = {
          'totalItems': dataObj['totalItems'],
          'totalPages': dataObj['totalPages'],
          'currentPage': dataObj['currentPage'],
        };

        // Extract actual data (remove pagination keys)
        final actualData = Map<String, dynamic>.from(dataObj);
        actualData.remove('totalItems');
        actualData.remove('totalPages');
        actualData.remove('currentPage');

        // If only one key left, use its value directly
        if (actualData.length == 1) {
          result['data'] = actualData.values.first;
        } else {
          result['data'] = actualData;
        }
        return result;
      }
    }

    // Case 3: Simple data without pagination
    // Format: { message, data }
    result['data'] = responseData['data'];
    return result;
  }

  /// Parse error response dari backend
  static Map<String, dynamic> parseErrorResponse(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    String message = 'Terjadi kesalahan';
    String? code;
    Map<String, List<String>>? validationErrors;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;
      code = data['code']?.toString();

      // Parse validation errors
      if (data['errors'] != null) {
        validationErrors = _parseValidationErrors(data['errors']);
      }
    } else if (data is String) {
      message = data;
    }

    return {
      'success': false,
      'message': message,
      'code': code,
      'validationErrors': validationErrors,
      'statusCode': statusCode,
      'type': _getErrorType(statusCode),
    };
  }

  /// Parse validation errors dari berbagai format
  static Map<String, List<String>>? _parseValidationErrors(dynamic errors) {
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
    } else if (errors is List) {
      result['general'] = errors.cast<String>();
    }

    return result.isNotEmpty ? result : null;
  }

  /// Get error type berdasarkan status code
  static String _getErrorType(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'validation';
      case 401:
        return 'unauthorized';
      case 403:
        return 'forbidden';
      case 404:
        return 'not_found';
      case 409:
        return 'conflict';
      case 422:
        return 'validation';
      case 429:
        return 'rate_limit';
      case 500:
        return 'server_error';
      default:
        return 'unknown';
    }
  }

  /// Check if response indicates success
  static bool isSuccessResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    return statusCode >= 200 && statusCode < 300;
  }

  /// Extract pagination info dari parsed response
  static PaginationInfo? extractPaginationInfo(
      Map<String, dynamic> parsedResponse) {
    final pagination = parsedResponse['pagination'];
    if (pagination is Map<String, dynamic>) {
      return PaginationInfo(
        totalItems: pagination['totalItems'] as int?,
        totalPages: pagination['totalPages'] as int?,
        currentPage: pagination['currentPage'] as int?,
      );
    }
    return null;
  }

  /// Extract data dari parsed response dengan type checking
  static T? extractData<T>(Map<String, dynamic> parsedResponse) {
    final data = parsedResponse['data'];
    if (data is T) {
      return data;
    }
    return null;
  }

  /// Extract list data dengan proper casting
  static List<T>? extractListData<T>(
    Map<String, dynamic> parsedResponse,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = parsedResponse['data'];
    if (data is List) {
      return data.map<T>((item) {
        if (item is Map<String, dynamic>) {
          return fromJson(item);
        }
        throw FormatException('Invalid item format in list');
      }).toList();
    }
    return null;
  }

  /// Create standardized API response
  static Map<String, dynamic> createApiResponse({
    required bool success,
    required String message,
    dynamic data,
    String? code,
    Map<String, List<String>>? errors,
    int? statusCode,
    PaginationInfo? pagination,
  }) {
    final result = {
      'success': success,
      'message': message,
      'data': data,
      'statusCode': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (code != null) result['code'] = code;
    if (errors != null) result['errors'] = errors;
    if (pagination != null) result['pagination'] = pagination.toJson();

    return result;
  }
}

/// Pagination Info Class
class PaginationInfo {
  final int? totalItems;
  final int? totalPages;
  final int? currentPage;

  const PaginationInfo({
    this.totalItems,
    this.totalPages,
    this.currentPage,
  });

  bool get hasPagination => totalItems != null && totalPages != null;

  bool get hasNextPage =>
      currentPage != null && totalPages != null && currentPage! < totalPages!;

  bool get hasPreviousPage => currentPage != null && currentPage! > 1;

  Map<String, dynamic> toJson() => {
        'totalItems': totalItems,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
        totalItems: json['totalItems'] as int?,
        totalPages: json['totalPages'] as int?,
        currentPage: json['currentPage'] as int?,
      );

  @override
  String toString() =>
      'PaginationInfo(totalItems: $totalItems, totalPages: $totalPages, currentPage: $currentPage)';
}

/// Extension untuk Response object
extension ResponseExtension on Response {
  /// Check if response is successful
  bool get isSuccess => ResponseParser.isSuccessResponse(this);

  /// Parse response sebagai success response
  Map<String, dynamic> get parsedData =>
      ResponseParser.parseSuccessResponse(this);

  /// Get message dari response
  String get message {
    final parsed = parsedData;
    return parsed['message'] ?? 'Success';
  }

  /// Get data dari response
  dynamic get responseData {
    final parsed = parsedData;
    return parsed['data'];
  }

  /// Get pagination info dari response
  PaginationInfo? get paginationInfo {
    final parsed = parsedData;
    return ResponseParser.extractPaginationInfo(parsed);
  }

  /// Extract typed data dari response
  T? getData<T>() {
    final parsed = parsedData;
    return ResponseParser.extractData<T>(parsed);
  }

  /// Extract list data dengan model conversion
  List<T>? getListData<T>(T Function(Map<String, dynamic>) fromJson) {
    final parsed = parsedData;
    return ResponseParser.extractListData<T>(parsed, fromJson);
  }
}

/// Extension untuk DioException
extension DioExceptionExtension on DioException {
  /// Parse error response
  Map<String, dynamic> get parsedError =>
      ResponseParser.parseErrorResponse(this);

  /// Get error message
  String get errorMessage {
    final parsed = parsedError;
    return parsed['message'] ?? 'Terjadi kesalahan';
  }

  /// Get error code
  String? get errorCode {
    final parsed = parsedError;
    return parsed['code'];
  }

  /// Get validation errors
  Map<String, List<String>>? get validationErrors {
    final parsed = parsedError;
    return parsed['validationErrors'];
  }

  /// Check if error is validation error
  bool get isValidationError {
    final statusCode = response?.statusCode;
    return statusCode == 400 || statusCode == 422;
  }

  /// Check if error is authentication error
  bool get isAuthError {
    final statusCode = response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  /// Check if error is not found error
  bool get isNotFoundError {
    return response?.statusCode == 404;
  }

  /// Check if error is server error
  bool get isServerError {
    final statusCode = response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }
}
