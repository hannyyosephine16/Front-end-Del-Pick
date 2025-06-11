// lib/data/datasources/remote/driver_remote_datasource.dart - SESUAI ApiService ANDA
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

  /// Update driver status - ENDPOINT: PUT /drivers/status
  Future<Response> updateDriverStatus(Map<String, dynamic> data) async {
    return await _apiService.put(
      '/drivers/status',
      data: data, // {status: "active" atau "inactive"}
    );
  }

  /// Get driver profile - ENDPOINT: GET /auth/profile
  /// NOTE: Swagger tidak punya /drivers/status-info, gunakan /auth/profile
  Future<Response> getDriverProfile() async {
    return await _apiService.get('/auth/profile');
  }

  /// Update driver profile - ENDPOINT: PUT /drivers/update
  Future<Response> updateDriverProfile(Map<String, dynamic> data) async {
    return await _apiService.put(
      '/drivers/update',
      data: data,
    );
  }

  /// Update driver location - ENDPOINT: PUT /drivers/location
  Future<Response> updateDriverLocation(Map<String, dynamic> data) async {
    return await _apiService.put(
      '/drivers/location',
      data: data, // {latitude: double, longitude: double}
    );
  }

  /// Get driver location - ENDPOINT: GET /drivers/{driverId}/location
  Future<Response> getDriverLocation(int driverId) async {
    return await _apiService.get('/drivers/$driverId/location');
  }

  /// Get driver requests - ENDPOINT: GET /driver-requests
  Future<Response> getDriverRequests({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      '/driver-requests',
      queryParameters: params,
    );
  }

  /// Get driver request by ID - ENDPOINT: GET /driver-requests/{requestId}
  Future<Response> getDriverRequestById(int requestId) async {
    return await _apiService.get('/driver-requests/$requestId');
  }

  /// Respond to driver request - ENDPOINT: PUT /driver-requests/{requestId}
  Future<Response> respondToDriverRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.put(
      '/driver-requests/$requestId',
      data: data, // {action: "accept" atau "reject"}
    );
  }
}
