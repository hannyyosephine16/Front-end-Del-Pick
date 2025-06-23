// lib/data/datasources/remote/driver_remote_datasource.dart - SESUAI ApiService ANDA
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

  /// Update driver status - ENDPOINT: PATCH /drivers/{id}/status
  Future<Response> updateDriverStatus(int driverId, String status) async {
    return await _apiService.patch(
      // '/drivers/$driverId/status',
      ApiEndpoints.updateDriverStatus(driverId),
      data: {'status': status},
    );
  }

  /// Update driver location - ENDPOINT: PATCH /drivers/{id}/location
  Future<Response> updateDriverLocation(
      int driverId, double latitude, double longitude) async {
    return await _apiService.patch(
      ApiEndpoints.updateDriverLocation(driverId),
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }

  /// Respond to driver request - ENDPOINT: POST /driver-requests/{id}/respond
  Future<Response> respondToDriverRequest(int requestId, String action) async {
    return await _apiService.post(
      // '/driver-requests/$requestId/respond',
      ApiEndpoints.respondToDriverRequest(requestId),
      data: {'action': action}, // accept or reject
    );
  }

  /// Get driver profile - ENDPOINT: GET /auth/profile
  /// NOTE: Swagger tidak punya /drivers/status-info, gunakan /auth/profile
  Future<Response> getDriverProfile() async {
    return await _apiService.get(ApiEndpoints.profile);
  }

  /// Update driver profile - ENDPOINT: PUT /drivers/update
  Future<Response> updateDriverProfile(Map<String, dynamic> data) async {
    return await _apiService.put(
      // '/drivers/update',
      ApiEndpoints.updateProfile,
      data: data,
    );
  }

  /// Get driver location - ENDPOINT: GET /drivers/{driverId}/location
  Future<Response> getDriverLocation(int driverId) async {
    return await _apiService.get(ApiEndpoints.updateDriverLocation(driverId));
  }

  /// Get driver requests - ENDPOINT: GET /driver-requests
  Future<Response> getDriverRequests({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.getDriverRequests,
      queryParameters: params,
    );
  }

  /// Get driver request by ID - ENDPOINT: GET /driver-requests/{requestId}
  Future<Response> getDriverRequestById(int requestId) async {
    return await _apiService.get(
      ApiEndpoints.getDriverRequestById(requestId),
    );
  }
}
