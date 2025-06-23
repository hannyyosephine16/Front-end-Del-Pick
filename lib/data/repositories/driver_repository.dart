// lib/data/repositories/driver_repository.dart - FIXED VERSION
import 'package:del_pick/data/providers/driver_provider.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/core/utils/result.dart';

class DriverRepository {
  final DriverProvider _driverProvider;

  DriverRepository(this._driverProvider);

  Future<Result<Map<String, dynamic>>> updateDriverStatus(
    int driverId,
    Map<String, dynamic> data,
  ) async {
    return await _driverProvider.updateDriverStatus(driverId, data);
  }

  Future<Result<Map<String, dynamic>>> updateDriverLocation(
    int driverId,
    double latitude,
    double longitude,
  ) async {
    return await _driverProvider.updateDriverLocation(
        driverId, latitude, longitude);
  }

  Future<Result<Map<String, dynamic>>> getDriverProfile() async {
    return await _driverProvider.getDriverProfile();
  }

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
            result.message ?? 'Failed to update driver profile');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<DriverRequestModel>>> getDriverRequests({
    Map<String, dynamic>? params,
  }) async {
    try {
      final result = await _driverProvider.getDriverRequests(params: params);

      if (result.isSuccess && result.data != null) {
        final data = result.data!['data']?['requests'] as List? ??
            result.data!['requests'] as List? ??
            [];
        final requests =
            data.map((json) => DriverRequestModel.fromJson(json)).toList();
        return Result.success(requests);
      } else {
        return Result.failure(
            result.message ?? 'Failed to fetch driver requests');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverRequestModel>> getDriverRequestById(int requestId) async {
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

  Future<Result<DriverRequestModel>> respondToDriverRequest(
    int requestId,
    String action,
  ) async {
    try {
      final result =
          await _driverProvider.respondToDriverRequest(requestId, action);

      if (result.isSuccess && result.data != null) {
        final requestData =
            result.data!['data'] as Map<String, dynamic>? ?? result.data!;
        final request = DriverRequestModel.fromJson(requestData);
        return Result.success(request);
      } else {
        return Result.failure(
            result.message ?? 'Failed to respond to driver request');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
