// lib/data/repositories/driver_repository.dart - Updated dengan status methods
import 'package:del_pick/data/providers/driver_provider.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/data/models/driver/driver_status_model.dart'; // New import
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/core/utils/result.dart';

import '../models/driver/driver_status_change_response.dart';
import '../models/driver/driver_status_error_model.dart';
import '../models/driver/driver_status_summary_model.dart';

class DriverRepository {
  final DriverProvider _driverProvider;

  DriverRepository(this._driverProvider);

  // Existing methods
  Future<Result<PaginatedResponse<DriverModel>>> getAllDrivers({
    Map<String, dynamic>? params,
  }) async {
    try {
      final result = await _driverProvider.getAllDrivers(params: params);

      if (result.isSuccess && result.data != null) {
        final data = result.data!['data'] as Map<String, dynamic>;
        final drivers = (data['drivers'] as List)
            .map((json) => DriverModel.fromJson(json))
            .toList();

        final paginatedResponse = PaginatedResponse<DriverModel>(
          data: drivers,
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          limit: params?['limit'] ?? 10,
        );

        return Result.success(paginatedResponse);
      } else {
        return Result.failure(result.message ?? 'Failed to fetch drivers');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverModel>> getDriverById(int driverId) async {
    try {
      final result = await _driverProvider.getDriverById(driverId);

      if (result.isSuccess && result.data != null) {
        final driver = DriverModel.fromJson(result.data!['data']);
        return Result.success(driver);
      } else {
        return Result.failure(result.message ?? 'Driver not found');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverModel>> createDriver(Map<String, dynamic> data) async {
    try {
      final result = await _driverProvider.createDriver(data);

      if (result.isSuccess && result.data != null) {
        final driver = DriverModel.fromJson(result.data!['data']);
        return Result.success(driver);
      } else {
        return Result.failure(result.message ?? 'Failed to create driver');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverModel>> updateDriver(
    int driverId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _driverProvider.updateDriver(driverId, data);

      if (result.isSuccess && result.data != null) {
        final driver = DriverModel.fromJson(result.data!['data']);
        return Result.success(driver);
      } else {
        return Result.failure(result.message ?? 'Failed to update driver');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverModel>> updateDriverProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _driverProvider.updateDriverProfile(data);

      if (result.isSuccess && result.data != null) {
        final driver = DriverModel.fromJson(result.data!['data']);
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

  Future<Result<Map<String, dynamic>>> updateDriverLocation(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _driverProvider.updateDriverLocation(data);

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!['data']);
      } else {
        return Result.failure(
          result.message ?? 'Failed to update driver location',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getDriverLocation(int driverId) async {
    try {
      final result = await _driverProvider.getDriverLocation(driverId);

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!['data']);
      } else {
        return Result.failure(
          result.message ?? 'Failed to get driver location',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ========================================================================
  // NEW: Enhanced Status Methods dengan Models
  // ========================================================================

  /// Get driver status info dengan valid transitions
  Future<Result<Map<String, dynamic>>> getDriverStatusInfo() async {
    try {
      final result = await _driverProvider.getDriverStatusInfo();

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!);
      } else {
        return Result.failure(
          result.message ?? 'Failed to get driver status info',
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

  /// Parse status change response dengan proper error handling
  DriverStatusChangeResponse? parseStatusChangeResponse(
      Map<String, dynamic>? data) {
    if (data == null) return null;

    try {
      return DriverStatusChangeResponse.fromJson(data);
    } catch (e) {
      print('Error parsing status change response: $e');
      return null;
    }
  }

  /// Parse status error dengan business rules
  DriverStatusErrorModel? parseStatusError(Map<String, dynamic>? errorData) {
    if (errorData == null || !errorData.containsKey('businessRule')) {
      return null;
    }

    try {
      return DriverStatusErrorModel.fromJson(errorData);
    } catch (e) {
      print('Error parsing status error: $e');
      return null;
    }
  }

  /// Check if status transition is valid (client-side validation)
  bool isValidStatusTransition(String currentStatus, String newStatus) {
    const validTransitions = {
      'inactive': ['active'],
      'active': ['inactive', 'busy'],
      'busy': ['active'],
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }

  // ========================================================================
  // Monitoring & Analytics Methods
  // ========================================================================

  /// Get active drivers count untuk monitoring
  Future<Result<Map<String, dynamic>>> getActiveDriversCount() async {
    try {
      final result = await _driverProvider.getActiveDriversCount();

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!['data']);
      } else {
        return Result.failure(
          result.message ?? 'Failed to get active drivers count',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get driver status summary untuk admin dashboard
  Future<Result<DriverStatusSummaryModel>> getDriverStatusSummary() async {
    try {
      final result = await _driverProvider.getDriverStatusSummary();

      if (result.isSuccess && result.data != null) {
        final summary = DriverStatusSummaryModel.fromJson(result.data!['data']);
        return Result.success(summary);
      } else {
        return Result.failure(
          result.message ?? 'Failed to get driver status summary',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> deleteDriver(int driverId) async {
    try {
      final result = await _driverProvider.deleteDriver(driverId);

      if (result.isSuccess) {
        return Result.success(null);
      } else {
        return Result.failure(result.message ?? 'Failed to delete driver');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // Driver Requests
  Future<Result<List<DriverRequestModel>>> getDriverRequests({
    Map<String, dynamic>? params,
  }) async {
    try {
      final result = await _driverProvider.getDriverRequests(params: params);

      if (result.isSuccess && result.data != null) {
        final data = result.data!['data'] as List;
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

  Future<Result<DriverRequestModel>> getDriverRequestById(
    int requestId,
  ) async {
    try {
      final result = await _driverProvider.getDriverRequestById(requestId);

      if (result.isSuccess && result.data != null) {
        final request = DriverRequestModel.fromJson(result.data!['data']);
        return Result.success(request);
      } else {
        return Result.failure(result.message ?? 'Driver request not found');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

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
        final request = DriverRequestModel.fromJson(result.data!['data']);
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
}
