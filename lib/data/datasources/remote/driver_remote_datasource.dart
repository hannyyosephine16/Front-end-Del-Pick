// lib/data/datasources/remote/driver_remote_datasource.dart - FIXED
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:dio/dio.dart';

class DriverRemoteDataSource {
  final ApiService _apiService;
  final AuthLocalDataSource _authLocalDataSource;

  DriverRemoteDataSource({
    required ApiService apiService,
    required AuthLocalDataSource authLocalDataSource,
  })  : _apiService = apiService,
        _authLocalDataSource = authLocalDataSource;

  // ✅ FIXED: Get all drivers - sesuai backend GET /drivers
  Future<Response> getAllDrivers({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.getAllDrivers,
      queryParameters: params,
    );
  }

  Future<Response> getDriverById(int driverId) async {
    return await _apiService.get(ApiEndpoints.getDriverById(driverId));
  }

  Future<Response> createDriver(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createDriver, data: data);
  }

  Future<Response> updateDriver(int driverId, Map<String, dynamic> data) async {
    return await _apiService.put(
      ApiEndpoints.updateDriverbyAdmin(driverId),
      data: data,
    );
  }

  Future<Response> deleteDriver(int driverId) async {
    return await _apiService.delete(ApiEndpoints.deleteDriver(driverId));
  }

  Future<Response> updateDriverStatus(
      int driverId, Map<String, dynamic> data) async {
    return await _apiService.patch(
      ApiEndpoints.updateDriverStatus(driverId),
      data: data,
    );
  }

  Future<Response> updateDriverLocation(
      int driverId, Map<String, dynamic> data) async {
    return await _apiService.patch(
      ApiEndpoints.updateDriverLocation(driverId),
      data: data,
    );
  }

  Future<Response> getDriverRequests({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.getDriverRequests,
      queryParameters: params,
    );
  }

  Future<Response> getDriverRequestById(int requestId) async {
    return await _apiService.get(
      ApiEndpoints.getDriverRequestById(requestId),
    );
  }

  Future<Response> respondToDriverRequest(
      int requestId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.respondToDriverRequest(requestId),
      data: data,
    );
  }

  Future<Response> getDriverProfile() async {
    return await _apiService.get(ApiEndpoints.profile);
  }

  Future<Response> updateDriverProfile(Map<String, dynamic> data) async {
    return await _apiService.put(ApiEndpoints.updateProfile, data: data);
  }
}
