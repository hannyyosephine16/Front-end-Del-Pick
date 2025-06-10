// lib/data/models/base/base_model.dart - Fixed ApiResponseModel

abstract class BaseModel {
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString();
}

class ApiResponseModel<T> {
  final int statusCode;
  final String message;
  final T? data;
  final dynamic errors; // Changed from String? to dynamic to handle arrays
  final bool success;

  ApiResponseModel({
    required this.statusCode,
    required this.message,
    this.data,
    this.errors,
    bool? success,
  }) : success = success ?? (statusCode >= 200 && statusCode < 300);

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT, {
    int? httpStatusCode, // Add HTTP status code parameter
  }) {
    // ✅ Handle backend response format
    final bool responseSuccess = json['success'] as bool? ?? true;
    final int responseStatusCode = httpStatusCode ??
        (responseSuccess ? 200 : 400); // Default based on success flag

    return ApiResponseModel<T>(
      statusCode: responseStatusCode, // Use HTTP status or derive from success
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'], // Can be String, List, or null
      success: responseSuccess,
    );
  }

  // Factory for HTTP responses with explicit status codes
  factory ApiResponseModel.fromHttpResponse(
    Map<String, dynamic> json,
    int httpStatusCode,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponseModel.fromJson(json, fromJsonT,
        httpStatusCode: httpStatusCode);
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data,
      'errors': errors,
      'success': success,
    };
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get isError => !isSuccess;

  // ✅ Better error message handling
  String get errorMessage {
    if (errors == null) return message;

    if (errors is List) {
      final errorList = errors as List;
      if (errorList.isNotEmpty) {
        // Handle validation errors from backend
        if (errorList.first is Map) {
          final firstError = errorList.first as Map<String, dynamic>;
          return firstError['msg'] as String? ?? message;
        }
        return errorList.join(', ');
      }
    }

    if (errors is String) {
      return errors as String;
    }

    return message;
  }

  @override
  String toString() {
    return 'ApiResponseModel{statusCode: $statusCode, message: $message, success: $success}';
  }
}

// Keep PaginatedResponse unchanged as it looks correct
class PaginatedResponse<T> {
  final List<T> data;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int limit;

  PaginatedResponse({
    required this.data,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'limit': limit,
    };
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;

  @override
  String toString() {
    return 'PaginatedResponse{totalItems: $totalItems, currentPage: $currentPage, totalPages: $totalPages}';
  }
}
