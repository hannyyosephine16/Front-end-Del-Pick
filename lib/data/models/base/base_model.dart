// // lib/data/models/base/base_model.dart - Fixed ApiResponseModel
//
// abstract class BaseModel {
//   Map<String, dynamic> toJson();
//
//   @override
//   bool operator ==(Object other);
//
//   @override
//   int get hashCode;
//
//   @override
//   String toString();
// }
//
// class ApiResponseModel<T> {
//   final int statusCode;
//   final String message;
//   final T? data;
//   final dynamic errors; // Changed from String? to dynamic to handle arrays
//   final bool success;
//
//   ApiResponseModel({
//     required this.statusCode,
//     required this.message,
//     this.data,
//     this.errors,
//     bool? success,
//   }) : success = success ?? (statusCode >= 200 && statusCode < 300);
//
//   factory ApiResponseModel.fromJson(
//     Map<String, dynamic> json,
//     T Function(dynamic)? fromJsonT, {
//     int? httpStatusCode, // Add HTTP status code parameter
//   }) {
//     // ✅ Handle backend response format
//     final bool responseSuccess = json['success'] as bool? ?? true;
//     final int responseStatusCode = httpStatusCode ??
//         (responseSuccess ? 200 : 400); // Default based on success flag
//
//     return ApiResponseModel<T>(
//       statusCode: responseStatusCode, // Use HTTP status or derive from success
//       message: json['message'] as String,
//       data: json['data'] != null && fromJsonT != null
//           ? fromJsonT(json['data'])
//           : json['data'] as T?,
//       errors: json['errors'], // Can be String, List, or null
//       success: responseSuccess,
//     );
//   }
//
//   // Factory for HTTP responses with explicit status codes
//   factory ApiResponseModel.fromHttpResponse(
//     Map<String, dynamic> json,
//     int httpStatusCode,
//     T Function(dynamic)? fromJsonT,
//   ) {
//     return ApiResponseModel.fromJson(json, fromJsonT,
//         httpStatusCode: httpStatusCode);
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'statusCode': statusCode,
//       'message': message,
//       'data': data,
//       'errors': errors,
//       'success': success,
//     };
//   }
//
//   bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
//   bool get isError => !isSuccess;
//
//   // ✅ Better error message handling
//   String get errorMessage {
//     if (errors == null) return message;
//
//     if (errors is List) {
//       final errorList = errors as List;
//       if (errorList.isNotEmpty) {
//         // Handle validation errors from backend
//         if (errorList.first is Map) {
//           final firstError = errorList.first as Map<String, dynamic>;
//           return firstError['msg'] as String? ?? message;
//         }
//         return errorList.join(', ');
//       }
//     }
//
//     if (errors is String) {
//       return errors as String;
//     }
//
//     return message;
//   }
//
//   @override
//   String toString() {
//     return 'ApiResponseModel{statusCode: $statusCode, message: $message, success: $success}';
//   }
// }
//
// // Keep PaginatedResponse unchanged as it looks correct
// class PaginatedResponse<T> {
//   final List<T> items;
//   final int totalItems;
//   final int totalPages;
//   final int currentPage;
//
//   PaginatedResponse({
//     required this.items,
//     required this.totalItems,
//     required this.totalPages,
//     required this.currentPage,
//   });
//
//   // Factory untuk parsing dari backend response
//   factory PaginatedResponse.fromJson(
//     Map<String, dynamic> json,
//     T Function(Map<String, dynamic>) fromJsonT,
//     String itemsKey, // e.g., 'stores', 'menuItems', 'orders'
//   ) {
//     return PaginatedResponse<T>(
//       items: (json[itemsKey] as List?)
//               ?.map((item) => fromJsonT(item as Map<String, dynamic>))
//               .toList() ??
//           [],
//       totalItems: json['totalItems'] as int? ?? 0,
//       totalPages: json['totalPages'] as int? ?? 0,
//       currentPage: json['currentPage'] as int? ?? 1,
//     );
//   }
//
//   bool get hasNextPage => currentPage < totalPages;
//   bool get hasPreviousPage => currentPage > 1;
//   bool get isEmpty => items.isEmpty;
//   bool get isNotEmpty => items.isNotEmpty;
//
//   @override
//   String toString() {
//     return 'PaginatedResponse(items: ${items.length}, total: $totalItems, page: $currentPage/$totalPages)';
//   }
// }
// lib/data/models/base/api_response_model.dart - FIXED VERSION

abstract class BaseModel {
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString();
}

// ✅ FIXED: Match backend response structure exactly
class ApiResponseModel<T> {
  final String message; // ✅ Backend always returns message
  final T? data; // ✅ Backend data field (can be null)
  final dynamic errors; // ✅ Backend errors field (can be String, List, or null)
  final bool success; // ✅ Derived from HTTP status or explicit field
  final int? statusCode; // ✅ HTTP status code

  ApiResponseModel({
    required this.message,
    this.data,
    this.errors,
    required this.success,
    this.statusCode,
  });

  // ✅ FIXED: Handle backend response format exactly
  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT, {
    int? httpStatusCode,
  }) {
    // Backend doesn't always send 'success' field, derive from HTTP status
    final bool isSuccess = httpStatusCode != null
        ? (httpStatusCode >= 200 && httpStatusCode < 300)
        : (json['success'] as bool? ?? true);

    return ApiResponseModel<T>(
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'], // Can be String, List, or null
      success: isSuccess,
      statusCode: httpStatusCode,
    );
  }

  // Factory for explicit HTTP responses
  factory ApiResponseModel.fromHttpResponse(
    Map<String, dynamic> json,
    int httpStatusCode,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponseModel.fromJson(
      json,
      fromJsonT,
      httpStatusCode: httpStatusCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
      'errors': errors,
      'success': success,
      'statusCode': statusCode,
    };
  }

  bool get isSuccess =>
      success &&
      (statusCode == null || (statusCode! >= 200 && statusCode! < 300));
  bool get isError => !isSuccess;

  // ✅ BETTER: Handle different error formats from backend
  String get errorMessage {
    if (errors == null) return message;

    if (errors is List) {
      final errorList = errors as List;
      if (errorList.isNotEmpty) {
        // Handle validation errors: [{ field: 'email', message: 'Invalid email' }]
        if (errorList.first is Map) {
          final firstError = errorList.first as Map<String, dynamic>;
          return firstError['message'] as String? ??
              firstError['msg'] as String? ??
              message;
        }
        // Handle simple string array: ['Error 1', 'Error 2']
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

// ✅ FIXED: Match backend pagination structure
class PaginatedResponse<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  // ✅ FIXED: Handle backend pagination structure
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
    String itemsKey, // e.g., 'orders', 'stores', 'drivers'
  ) {
    // Backend can return items directly or nested in data
    final itemsData =
        json[itemsKey] as List? ?? json['data'][itemsKey] as List?;

    return PaginatedResponse<T>(
      items: itemsData
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalItems:
          json['totalItems'] as int? ?? json['data']['totalItems'] as int? ?? 0,
      totalPages:
          json['totalPages'] as int? ?? json['data']['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ??
          json['data']['currentPage'] as int? ??
          1,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() {
    return 'PaginatedResponse(items: ${items.length}, total: $totalItems, page: $currentPage/$totalPages)';
  }
}
