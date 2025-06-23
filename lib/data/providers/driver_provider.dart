// lib/data/providers/driver_provider.dart - FIXED
import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/core/utils/result.dart';

class DriverProvider {
  final DriverRemoteDataSource remoteDataSource;

  DriverProvider({required this.remoteDataSource});

  // ✅ FIXED: Get all drivers
  Future<Result<Map<String, dynamic>>> getAllDrivers({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await remoteDataSource.getAllDrivers(params: params);
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ FIXED: Get driver by ID
  Future<Result<Map<String, dynamic>>> getDriverById(int driverId) async {
    try {
      final response = await remoteDataSource.getDriverById(driverId);
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ FIXED: Update driver status - PATCH /drivers/:id/status (admin only)
  Future<Result<Map<String, dynamic>>> updateDriverStatus(
    int driverId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await remoteDataSource.updateDriverStatus(driverId, data);
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ FIXED: Update driver location - PATCH /drivers/:id/location (driver only)
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
          await remoteDataSource.updateDriverLocation(driverId, data);
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ FIXED: Get driver profile - GET /auth/profile
  Future<Result<Map<String, dynamic>>> getDriverProfile() async {
    try {
      final response = await remoteDataSource.getDriverProfile();
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ FIXED: Update driver profile - PUT /auth/profile
  Future<Result<Map<String, dynamic>>> updateDriverProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await remoteDataSource.updateDriverProfile(data);
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ FIXED: Get driver requests - GET /driver-requests (driver only)
  Future<Result<Map<String, dynamic>>> getDriverRequests({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await remoteDataSource.getDriverRequests(params: params);
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ FIXED: Get driver request by ID - GET /driver-requests/:id (driver only)
  Future<Result<Map<String, dynamic>>> getDriverRequestById(
      int requestId) async {
    try {
      final response = await remoteDataSource.getDriverRequestById(requestId);
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ FIXED: Respond to driver request - POST /driver-requests/:id/respond (driver only)
  Future<Result<Map<String, dynamic>>> respondToDriverRequest(
    int requestId,
    String action, // 'accept' or 'reject'
  ) async {
    try {
      final data = {'action': action};
      final response =
          await remoteDataSource.respondToDriverRequest(requestId, data);
      return Result.success(response.data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
