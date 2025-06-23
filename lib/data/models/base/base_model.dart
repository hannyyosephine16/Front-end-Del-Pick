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
  final String message;
  final T? data;
  final dynamic errors;
  final bool success;
  final int? statusCode;

  ApiResponseModel({
    required this.message,
    this.data,
    this.errors,
    required this.success,
    this.statusCode,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT, {
    int? httpStatusCode,
  }) {
    final bool isSuccess = httpStatusCode != null
        ? (httpStatusCode >= 200 && httpStatusCode < 300)
        : (json['success'] as bool? ?? true);

    return ApiResponseModel<T>(
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'],
      success: isSuccess,
      statusCode: httpStatusCode,
    );
  }

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

  String get errorMessage {
    if (errors == null) return message;

    if (errors is List) {
      final errorList = errors as List;
      if (errorList.isNotEmpty) {
        if (errorList.first is Map) {
          final firstError = errorList.first as Map<String, dynamic>;
          return firstError['message'] as String? ??
              firstError['msg'] as String? ??
              message;
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

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
    String itemsKey,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final itemsData = data[itemsKey] as List? ?? [];

    return PaginatedResponse<T>(
      items: itemsData
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalItems: data['totalItems'] as int? ?? 0,
      totalPages: data['totalPages'] as int? ?? 0,
      currentPage: data['currentPage'] as int? ?? 1,
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
