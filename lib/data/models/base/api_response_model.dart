// // lib/data/models/api/api_response.dart
// class ApiResponse<T> {
//   final bool success;
//   final String message;
//   final T? data;
//   final dynamic errors;
//   final int? statusCode;
//
//   ApiResponse({
//     required this.success,
//     required this.message,
//     this.data,
//     this.errors,
//     this.statusCode,
//   });
//
//   factory ApiResponse.success({
//     required T data,
//     String? message,
//     int? statusCode,
//   }) {
//     return ApiResponse<T>(
//       success: true,
//       message: message ?? 'Success',
//       data: data,
//       statusCode: statusCode ?? 200,
//     );
//   }
//
//   factory ApiResponse.error({
//     required String message,
//     dynamic errors,
//     int? statusCode,
//   }) {
//     return ApiResponse<T>(
//       success: false,
//       message: message,
//       errors: errors,
//       statusCode: statusCode ?? 400,
//     );
//   }
//
//   factory ApiResponse.fromJson(
//     Map<String, dynamic> json,
//     T Function(dynamic)? fromJsonT,
//   ) {
//     return ApiResponse<T>(
//       success: json['success'] as bool? ?? true,
//       message: json['message'] as String,
//       data: json['data'] != null && fromJsonT != null
//           ? fromJsonT(json['data'])
//           : json['data'] as T?,
//       errors: json['errors'],
//       statusCode: json['statusCode'] as int?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'message': message,
//       'data': data,
//       'errors': errors,
//       'statusCode': statusCode,
//     };
//   }
//
//   bool get isSuccess => success;
//   bool get isError => !success;
//
//   String get errorMessage {
//     if (errors == null) return message;
//
//     if (errors is List) {
//       final errorList = errors as List;
//       if (errorList.isNotEmpty) {
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
// }
// lib/data/models/api/api_response.dart - FIXED without ApiException
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message ?? 'Success',
      data: data,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error({
    required String message,
    dynamic errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode ?? 400,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'],
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'statusCode': statusCode,
    };
  }

  bool get isSuccess => success;
  bool get isError => !success;

  String get errorMessage {
    if (errors == null) return message;

    if (errors is List) {
      final errorList = errors as List;
      if (errorList.isNotEmpty) {
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
}
