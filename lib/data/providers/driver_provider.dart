// lib/data/providers/driver_provider.dart - SESUAI SWAGGER
import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/core/utils/result.dart';

class DriverProvider {
  final DriverRemoteDataSource remoteDataSource;

  DriverProvider({required this.remoteDataSource});

  /// Update driver status - ENDPOINT: PUT /drivers/status
  Future<Result<Map<String, dynamic>>> updateDriverStatus(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDataSource.updateDriverStatus(data);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        // Handle business rule errors if any
        final errorData = response.data;
        if (errorData != null && errorData.containsKey('businessRule')) {
          return Result.failure(
            errorData['message'] ?? 'Business rule violation',
          );
        }
        return Result.failure(
          response.data['message'] ?? 'Failed to update driver status',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver profile - ENDPOINT: GET /auth/profile
  /// NOTE: Swagger tidak punya /drivers/status-info, gunakan /auth/profile
  Future<Result<Map<String, dynamic>>> getDriverProfile() async {
    try {
      final response = await remoteDataSource.getDriverProfile();

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to get driver profile',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Update driver profile - ENDPOINT: PUT /drivers/update
  Future<Result<Map<String, dynamic>>> updateDriverProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDataSource.updateDriverProfile(data);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to update driver profile',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Update driver location - ENDPOINT: PUT /drivers/location
  Future<Result<Map<String, dynamic>>> updateDriverLocation(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDataSource.updateDriverLocation(data);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to update driver location',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver location - ENDPOINT: GET /drivers/{driverId}/location
  Future<Result<Map<String, dynamic>>> getDriverLocation(int driverId) async {
    try {
      final response = await remoteDataSource.getDriverLocation(driverId);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to get driver location',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver requests - ENDPOINT: GET /driver-requests
  Future<Result<Map<String, dynamic>>> getDriverRequests({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await remoteDataSource.getDriverRequests(params: params);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch driver requests',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver request by ID - ENDPOINT: GET /driver-requests/{requestId}
  Future<Result<Map<String, dynamic>>> getDriverRequestById(
    int requestId,
  ) async {
    try {
      final response = await remoteDataSource.getDriverRequestById(requestId);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Driver request not found',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Respond to driver request - ENDPOINT: PUT /driver-requests/{requestId}
  Future<Result<Map<String, dynamic>>> respondToDriverRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDataSource.respondToDriverRequest(
        requestId,
        data,
      );

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to respond to driver request',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver status info - DEPRECATED, gunakan getDriverProfile()
  @Deprecated(
      'Use getDriverProfile() instead. Endpoint /drivers/status-info does not exist.')
  Future<Result<Map<String, dynamic>>> getDriverStatusInfo() async {
    // Redirect to getDriverProfile and transform response
    return await getDriverProfile();
  }

  /// Get active drivers count - DEPRECATED, tidak ada di swagger
  @Deprecated('Endpoint /drivers/active-count does not exist in backend.')
  Future<Result<Map<String, dynamic>>> getActiveDriversCount() async {
    return Result.failure(
        'Endpoint not available. Use getAllDrivers() and filter in client.');
  }

  /// Get driver status summary - DEPRECATED, tidak ada di swagger
  @Deprecated('Endpoint /drivers/status-summary does not exist in backend.')
  Future<Result<Map<String, dynamic>>> getDriverStatusSummary() async {
    return Result.failure(
        'Endpoint not available. Use getAllDrivers() and calculate in client.');
  }
}
