// lib/data/providers/driver_provider.dart - Updated dengan status methods
import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/core/utils/result.dart';

class DriverProvider {
  final DriverRemoteDataSource remoteDataSource;

  DriverProvider({required this.remoteDataSource});

  // Existing methods
  Future<Result<Map<String, dynamic>>> getAllDrivers({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await remoteDataSource.getAllDrivers(params: params);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch drivers',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getDriverById(int driverId) async {
    try {
      final response = await remoteDataSource.getDriverById(driverId);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Driver not found',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> createDriver(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDataSource.createDriver(data);

      if (response.statusCode == 201) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to create driver',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> updateDriver(
    int driverId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDataSource.updateDriver(driverId, data);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to update driver',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

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

  // ========================================================================
  // NEW: Status-related methods
  // ========================================================================

  /// Get driver status info dengan valid transitions
  Future<Result<Map<String, dynamic>>> getDriverStatusInfo() async {
    try {
      final response = await remoteDataSource.getDriverStatusInfo();

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to get driver status info',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Update driver status dengan comprehensive validation
  Future<Result<Map<String, dynamic>>> updateDriverStatus(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDataSource.updateDriverStatus(data);

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        // Handle business rule errors
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

  /// Get active drivers count untuk monitoring
  Future<Result<Map<String, dynamic>>> getActiveDriversCount() async {
    try {
      final response = await remoteDataSource.getActiveDriversCount();

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to get active drivers count',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver status summary untuk admin dashboard
  Future<Result<Map<String, dynamic>>> getDriverStatusSummary() async {
    try {
      final response = await remoteDataSource.getDriverStatusSummary();

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to get driver status summary',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ========================================================================
  // Existing methods (unchanged)
  // ========================================================================

  Future<Result<void>> deleteDriver(int driverId) async {
    try {
      final response = await remoteDataSource.deleteDriver(driverId);

      if (response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to delete driver',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // Driver Requests
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
}
