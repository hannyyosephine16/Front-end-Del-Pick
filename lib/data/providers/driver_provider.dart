// lib/data/providers/driver_provider.dart - FIXED VERSION
import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

class DriverProvider {
  final DriverRemoteDataSource _remoteDataSource;

  DriverProvider({
    required DriverRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ✅ Update driver status - Backend: PATCH /drivers/:id/status
  Future<Result<Map<String, dynamic>>> updateDriverStatus(
    int driverId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await _remoteDataSource.updateDriverStatus(driverId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(
          responseData['data'] as Map<String, dynamic>? ?? responseData,
          responseData['message'] as String?,
        );
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
        return Result.success(
          responseData['data'] as Map<String, dynamic>? ?? responseData,
          responseData['message'] as String?,
        );
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
  Future<Result<Map<String, dynamic>>> getDriverProfile() async {
    try {
      final response = await _remoteDataSource.getDriverProfile();

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(
          responseData['data'] as Map<String, dynamic>? ?? responseData,
          responseData['message'] as String?,
        );
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
  Future<Result<Map<String, dynamic>>> updateDriverProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDataSource.updateDriverProfile(data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(
          responseData['data'] as Map<String, dynamic>? ?? responseData,
          responseData['message'] as String?,
        );
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
  Future<Result<Map<String, dynamic>>> getDriverRequests({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response =
          await _remoteDataSource.getDriverRequests(params: params);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData);
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
  Future<Result<Map<String, dynamic>>> getDriverRequestById(
      int requestId) async {
    try {
      final response = await _remoteDataSource.getDriverRequestById(requestId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData);
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
  Future<Result<Map<String, dynamic>>> respondToDriverRequest(
    int requestId,
    String action,
  ) async {
    try {
      final data = {'action': action};
      final response =
          await _remoteDataSource.respondToDriverRequest(requestId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(
          responseData['data'] as Map<String, dynamic>? ?? responseData,
          responseData['message'] as String?,
        );
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
  Future<Result<Map<String, dynamic>>> getAllDrivers({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _remoteDataSource.getAllDrivers(params: params);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData);
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

  // ✅ Create driver (for admin) - Backend: POST /drivers
  Future<Result<Map<String, dynamic>>> createDriver(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDataSource.createDriver(data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(
          responseData['data'] as Map<String, dynamic>? ?? responseData,
          responseData['message'] as String?,
        );
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to create driver';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Failed to create driver');
    } catch (e) {
      return Result.failure('Unexpected error: ${e.toString()}');
    }
  }

  // ✅ Handle Dio errors with proper backend error parsing
  Result<Map<String, dynamic>> _handleDioError(
      DioException e, String defaultMessage) {
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
