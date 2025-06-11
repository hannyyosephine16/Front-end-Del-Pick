// lib/data/repositories/driver_repository.dart - SESUAI SWAGGER
import 'package:del_pick/data/providers/driver_provider.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/core/utils/result.dart';
import '../datasources/local/auth_local_datasource.dart';

class DriverRepository {
  final DriverProvider _driverProvider;

  DriverRepository(this._driverProvider);

  /// Update driver status - ENDPOINT: PUT /drivers/status
  Future<Result<Map<String, dynamic>>> updateDriverStatus(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _driverProvider.updateDriverStatus(data);

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!);
      } else {
        return Result.failure(
          result.message ?? 'Failed to update driver status',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver profile info - ENDPOINT: GET /auth/profile
  /// NOTE: Swagger tidak punya /drivers/status-info, jadi gunakan /auth/profile
  Future<Result<Map<String, dynamic>>> getDriverStatusInfo() async {
    try {
      final result = await _driverProvider.getDriverProfile();

      if (result.isSuccess && result.data != null) {
        final profileData = result.data!;

        // Extract driver status from profile response
        final driverData = profileData['driver'] as Map<String, dynamic>?;
        if (driverData != null) {
          // Transform profile response to status info format
          final statusInfo = {
            'current': driverData['status'] ?? 'inactive',
            'canTransitionTo':
                _getValidTransitions(driverData['status'] ?? 'inactive'),
            'hasActiveOrders': false, // Will be checked separately
            'activeOrderCount': 0, // Will be checked separately
          };
          return Result.success(statusInfo);
        } else {
          return Result.failure('Driver profile not found');
        }
      } else {
        return Result.failure(
          result.message ?? 'Failed to get driver profile',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Helper method to get valid status transitions
  List<String> _getValidTransitions(String currentStatus) {
    switch (currentStatus) {
      case 'inactive':
        return ['active'];
      case 'active':
        return ['inactive'];
      default:
        return ['active', 'inactive'];
    }
  }

  /// Check if status transition is valid (client-side validation)
  bool isValidStatusTransition(String currentStatus, String newStatus) {
    final validTransitions = _getValidTransitions(currentStatus);
    return validTransitions.contains(newStatus);
  }

  /// Get driver profile - ENDPOINT: GET /auth/profile
  Future<Result<Map<String, dynamic>>> getDriverProfile() async {
    try {
      final result = await _driverProvider.getDriverProfile();

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!);
      } else {
        return Result.failure(
          result.message ?? 'Failed to get driver profile',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Update driver profile - ENDPOINT: PUT /drivers/update
  Future<Result<DriverModel>> updateDriverProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _driverProvider.updateDriverProfile(data);

      if (result.isSuccess && result.data != null) {
        final driverData =
            result.data!['data'] as Map<String, dynamic>? ?? result.data!;
        final driver = DriverModel.fromJson(driverData);
        return Result.success(driver);
      } else {
        return Result.failure(
          result.message ?? 'Failed to update driver profile',
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
      final result = await _driverProvider.updateDriverLocation(data);

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!);
      } else {
        return Result.failure(
          result.message ?? 'Failed to update driver location',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver location - ENDPOINT: GET /drivers/{driverId}/location
  Future<Result<Map<String, dynamic>>> getDriverLocation(int driverId) async {
    try {
      final result = await _driverProvider.getDriverLocation(driverId);

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!);
      } else {
        return Result.failure(
          result.message ?? 'Failed to get driver location',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver requests - ENDPOINT: GET /driver-requests
  Future<Result<List<DriverRequestModel>>> getDriverRequests({
    Map<String, dynamic>? params,
  }) async {
    try {
      final result = await _driverProvider.getDriverRequests(params: params);

      if (result.isSuccess && result.data != null) {
        final data = result.data!['data'] as List? ??
            result.data!['requests'] as List? ??
            [];
        final requests =
            data.map((json) => DriverRequestModel.fromJson(json)).toList();
        return Result.success(requests);
      } else {
        return Result.failure(
          result.message ?? 'Failed to fetch driver requests',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver request by ID - ENDPOINT: GET /driver-requests/{requestId}
  Future<Result<DriverRequestModel>> getDriverRequestById(
    int requestId,
  ) async {
    try {
      final result = await _driverProvider.getDriverRequestById(requestId);

      if (result.isSuccess && result.data != null) {
        final requestData =
            result.data!['data'] as Map<String, dynamic>? ?? result.data!;
        final request = DriverRequestModel.fromJson(requestData);
        return Result.success(request);
      } else {
        return Result.failure(result.message ?? 'Driver request not found');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Respond to driver request - ENDPOINT: PUT /driver-requests/{requestId}
  Future<Result<DriverRequestModel>> respondToDriverRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _driverProvider.respondToDriverRequest(
        requestId,
        data,
      );

      if (result.isSuccess && result.data != null) {
        final requestData =
            result.data!['data'] as Map<String, dynamic>? ?? result.data!;
        final request = DriverRequestModel.fromJson(requestData);
        return Result.success(request);
      } else {
        return Result.failure(
          result.message ?? 'Failed to respond to driver request',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Parse status change response dengan proper error handling
  Map<String, dynamic>? parseStatusChangeResponse(Map<String, dynamic>? data) {
    if (data == null) return null;

    try {
      return data;
    } catch (e) {
      print('Error parsing status change response: $e');
      return null;
    }
  }

  /// Parse status error dengan business rules
  Map<String, dynamic>? parseStatusError(Map<String, dynamic>? errorData) {
    if (errorData == null) return null;

    try {
      return errorData;
    } catch (e) {
      print('Error parsing status error: $e');
      return null;
    }
  }
}
