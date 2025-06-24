import 'package:dio/dio.dart';
import 'package:del_pick/core/utils/dio_helper.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';
import 'package:del_pick/core/utils/response_parser.dart';

abstract class BaseModel {
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString();
}

/// ✅ UPDATED: ApiResponseModel yang menggunakan ResponseParser
class ApiResponseModel<T> {
  final String message;
  final T? data;
  final dynamic errors;
  final bool success;
  final int? statusCode;
  final PaginationInfo? pagination;

  ApiResponseModel({
    required this.message,
    this.data,
    this.errors,
    required this.success,
    this.statusCode,
    this.pagination,
  });

  /// ✅ UPDATED: Menggunakan ResponseParser untuk parsing yang konsisten
  factory ApiResponseModel.fromResponse(
    Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    final parsed = ResponseParser.parseSuccessResponse(response);

    return ApiResponseModel<T>(
      message: parsed['message'] as String? ?? 'Success',
      data: parsed['data'] != null && fromJsonT != null
          ? fromJsonT(parsed['data'])
          : parsed['data'] as T?,
      errors: null,
      success: parsed['success'] as bool? ?? true,
      statusCode: parsed['statusCode'] as int?,
      pagination: ResponseParser.extractPaginationInfo(parsed),
    );
  }

  /// ✅ UPDATED: Handle error response menggunakan ResponseParser
  factory ApiResponseModel.fromError(DioException error) {
    final parsed = ResponseParser.parseErrorResponse(error);

    return ApiResponseModel<T>(
      message: parsed['message'] as String? ?? 'Terjadi kesalahan',
      data: null,
      errors: parsed['validationErrors'],
      success: false,
      statusCode: parsed['statusCode'] as int?,
      pagination: null,
    );
  }

  /// Legacy factory for backward compatibility
  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT, {
    int? httpStatusCode,
  }) {
    final bool isSuccess = httpStatusCode != null
        ? (httpStatusCode >= 200 && httpStatusCode < 300)
        : (json['success'] as bool? ?? true);

    return ApiResponseModel<T>(
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'],
      success: isSuccess,
      statusCode: httpStatusCode ?? json['statusCode'] as int?,
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
      'errors': errors,
      'success': success,
      'statusCode': statusCode,
      'pagination': pagination?.toJson(),
    };
  }

  bool get isSuccess =>
      success &&
      (statusCode == null || (statusCode! >= 200 && statusCode! < 300));
  bool get isError => !isSuccess;
  bool get hasPagination => pagination != null;

  String get errorMessage {
    if (errors == null) return message;

    if (errors is Map<String, List<String>>) {
      final errorMap = errors as Map<String, List<String>>;
      if (errorMap.isNotEmpty) {
        return errorMap.values.first.first;
      }
    }

    if (errors is List) {
      final errorList = errors as List;
      if (errorList.isNotEmpty) {
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
