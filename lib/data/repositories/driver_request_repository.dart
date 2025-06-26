// lib/data/repositories/base/driver_request_repository.dart
import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';

abstract class DriverRequestRepository {
  Future<Result<DriverRequestListResponse>> getDriverRequests({
    int page = 1,
    int limit = 10,
  });

  Future<Result<DriverRequestModel>> respondToDriverRequest(
    int requestId,
    String action,
  );

  Future<Result<DriverRequestModel>> getDriverRequestDetail(int requestId);
}

class DriverRequestRepositoryImpl implements DriverRequestRepository {
  final DriverRemoteDataSource _remoteDataSource;

  DriverRequestRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<DriverRequestListResponse>> getDriverRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getDriverRequests(
        params: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final driverRequestResponse =
            DriverRequestListResponse.fromJson(responseData);
        return Result.success(driverRequestResponse);
      } else {
        return Result.failure(
          response.data?['message'] ?? 'Failed to get driver requests',
        );
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<DriverRequestModel>> respondToDriverRequest(
    int requestId,
    String action,
  ) async {
    try {
      final response = await _remoteDataSource.respondToDriverRequest(
        requestId,
        {'action': action},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final request = DriverRequestModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
        return Result.success(request);
      } else {
        return Result.failure(
          response.data?['message'] ?? 'Failed to respond to driver request',
        );
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<DriverRequestModel>> getDriverRequestDetail(
      int requestId) async {
    try {
      final response = await _remoteDataSource.getDriverRequestById(requestId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final request = DriverRequestModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
        return Result.success(request);
      } else {
        return Result.failure(
          response.data?['message'] ?? 'Driver request not found',
        );
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  String _handleDioError(DioException e) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      return response!.data['message'] ?? 'Network error occurred';
    }
    return 'Network error occurred';
  }
}

// Response model untuk list driver requests
class DriverRequestListResponse {
  final String message;
  final DriverRequestData data;

  DriverRequestListResponse({
    required this.message,
    required this.data,
  });

  factory DriverRequestListResponse.fromJson(Map<String, dynamic> json) {
    return DriverRequestListResponse(
      message: json['message'] ?? '',
      data: DriverRequestData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

class DriverRequestData {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final List<DriverRequestModel> requests;

  DriverRequestData({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.requests,
  });

  factory DriverRequestData.fromJson(Map<String, dynamic> json) {
    return DriverRequestData(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      requests: (json['requests'] as List?)
              ?.map((item) =>
                  DriverRequestModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'requests': requests.map((request) => request.toJson()).toList(),
    };
  }
}
