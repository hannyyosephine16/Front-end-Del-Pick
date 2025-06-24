// lib/data/providers/driver_provider.dart - FIXED VERSION
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

  DriverProvider({
    required DriverRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ✅ Update driver status - Backend: PATCH /drivers/:id/status
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
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to update status';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to update driver status');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Update driver location - Backend: PATCH /drivers/:id/location
  Future<Result<Map<String, dynamic>>> updateDriverLocation(
    int driverId,
    double latitude,
    double longitude,
  ) async {
    try {
      final data = {
        'latitude': latitude,
        'longitude': longitude,
      };

      final response =
          await _remoteDataSource.updateDriverLocation(driverId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final locationData = responseData['data'] as Map<String, dynamic>;
        return Result.success(locationData);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to update location';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to update driver location');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Get driver profile - Backend: GET /auth/profile (for driver user)
  Future<Result<UserModel>> getDriverProfile() async {
    try {
      final response = await _remoteDataSource.getDriverProfile();

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        return Result.success(user);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to get profile';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to get driver profile');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Update driver profile - Backend: PUT /auth/profile
  Future<Result<UserModel>> updateDriverProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDataSource.updateDriverProfile(data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        return Result.success(user);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to update profile';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to update driver profile');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Get driver requests - Backend: GET /driver-requests
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
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to get driver requests';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to get driver requests');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Get driver request by ID - Backend: GET /driver-requests/:id
  Future<Result<DriverRequestModel>> getDriverRequestById(int requestId) async {
    try {
      final response = await _remoteDataSource.getDriverRequestById(requestId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final requestData = responseData['data'] as Map<String, dynamic>;
        final driverRequest = DriverRequestModel.fromJson(requestData);
        return Result.success(driverRequest);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Driver request not found';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to get driver request');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Respond to driver request - Backend: POST /driver-requests/:id/respond
  Future<Result<DriverRequestModel>> respondToDriverRequest(
    int requestId,
    String action, // 'accept' or 'reject'
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
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to respond to request';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to respond to driver request');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Get all drivers (for admin) - Backend: GET /drivers
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
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to get drivers';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to get drivers');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Handle Dio errors with proper backend error parsing
  Result<T> _handleDioError<T>(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data as Map<String, dynamic>?;

    // Extract backend error message
    String errorMessage = defaultMessage;

    if (responseData != null) {
      if (responseData['message'] != null) {
        errorMessage = responseData['message'] as String;
      } else if (responseData['errors'] != null) {
        final errors = responseData['errors'];
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors.join(', ');
        } else if (errors is Map) {
          errorMessage = errors.values.join(', ');
        }
      }
    }

    // Handle specific HTTP status codes
    switch (statusCode) {
      case 400:
        return Result.failure('Invalid request: $errorMessage');
      case 401:
        return Result.failure('Unauthorized: Please login again');
      case 403:
        return Result.failure('Forbidden: $errorMessage');
      case 404:
        return Result.failure('Not found: $errorMessage');
      case 422:
        return Result.failure('Validation error: $errorMessage');
      case 429:
        return Result.failure('Too many requests. Please try again later');
      case 500:
        return Result.failure('Server error. Please try again later');
      default:
        return Result.failure(errorMessage);
    }
  }
}
