import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

class DriverProvider {
  final DriverRemoteDataSource _remoteDataSource;

  DriverProvider(this._remoteDataSource);

  /// Update driver status - PATCH /drivers/:id/status
  Future<Result<DriverModel>> updateDriverStatus(
    int driverId,
    String status,
  ) async {
    try {
      final data = {'status': status};
      final response =
          await _remoteDataSource.updateDriverStatus(driverId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final driverData = responseData['data'] as Map<String, dynamic>;
        final driver = DriverModel.fromJson(driverData);
        return Result.success(driver);
      } else {
        return Result.failure(_extractErrorMessage(response.data));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  /// Update driver location - PATCH /drivers/:id/location
  Future<Result<Map<String, dynamic>>> updateDriverLocation(
    int driverId,
    double latitude,
    double longitude,
  ) async {
    try {
      final data = {'latitude': latitude, 'longitude': longitude};
      final response =
          await _remoteDataSource.updateDriverLocation(driverId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData['data'] as Map<String, dynamic>);
      } else {
        return Result.failure(_extractErrorMessage(response.data));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get driver profile - GET /auth/profile
  Future<Result<UserModel>> getDriverProfile() async {
    try {
      final response = await _remoteDataSource.getDriverProfile();

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        return Result.success(user);
      } else {
        return Result.failure(_extractErrorMessage(response.data));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  /// Update driver profile - PUT /auth/profile
  Future<Result<UserModel>> updateDriverProfile(
      Map<String, dynamic> data) async {
    try {
      final response = await _remoteDataSource.updateDriverProfile(data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        return Result.success(user);
      } else {
        return Result.failure(_extractErrorMessage(response.data));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get driver requests - GET /driver-requests
  Future<Result<PaginatedResponse<DriverRequestModel>>> getDriverRequests({
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (page != null) params['page'] = page;
      if (limit != null) params['limit'] = limit;
      if (status != null) params['status'] = status;

      final response =
          await _remoteDataSource.getDriverRequests(params: params);

      if (response.statusCode == 200) {
        final paginatedResponse = PaginatedResponse.fromResponse(
          response,
          (json) => DriverRequestModel.fromJson(json),
        );
        return Result.success(paginatedResponse);
      } else {
        return Result.failure(_extractErrorMessage(response.data));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get driver request by ID - GET /driver-requests/:id
  Future<Result<DriverRequestModel>> getDriverRequestById(int requestId) async {
    try {
      final response = await _remoteDataSource.getDriverRequestById(requestId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final requestData = responseData['data'] as Map<String, dynamic>;
        final driverRequest = DriverRequestModel.fromJson(requestData);
        return Result.success(driverRequest);
      } else {
        return Result.failure(_extractErrorMessage(response.data));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  /// Respond to driver request - POST /driver-requests/:id/respond
  Future<Result<DriverRequestModel>> respondToDriverRequest(
    int requestId,
    String action,
  ) async {
    try {
      final data = {'action': action};
      final response =
          await _remoteDataSource.respondToDriverRequest(requestId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final requestData = responseData['data'] as Map<String, dynamic>;
        final driverRequest = DriverRequestModel.fromJson(requestData);
        return Result.success(driverRequest);
      } else {
        return Result.failure(_extractErrorMessage(response.data));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get all drivers (admin only) - GET /drivers
  Future<Result<PaginatedResponse<DriverModel>>> getAllDrivers({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (page != null) params['page'] = page;
      if (limit != null) params['limit'] = limit;
      if (status != null) params['status'] = status;
      if (search != null) params['search'] = search;

      final response = await _remoteDataSource.getAllDrivers(params: params);

      if (response.statusCode == 200) {
        final paginatedResponse = PaginatedResponse.fromResponse(
          response,
          (json) => DriverModel.fromJson(json),
        );
        return Result.success(paginatedResponse);
      } else {
        return Result.failure(_extractErrorMessage(response.data));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 'Unknown error';
    }
    return 'Unknown error';
  }

  String _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data as Map<String, dynamic>?;

    String errorMessage = responseData?['message'] ?? 'Network error';

    switch (statusCode) {
      case 400:
        return 'Invalid request: $errorMessage';
      case 401:
        return 'Unauthorized: Please login again';
      case 403:
        return 'Forbidden: $errorMessage';
      case 404:
        return 'Not found: $errorMessage';
      case 422:
        return 'Validation error: $errorMessage';
      case 429:
        return 'Too many requests. Please try again later';
      case 500:
        return 'Server error. Please try again later';
      default:
        return errorMessage;
    }
  }
}
