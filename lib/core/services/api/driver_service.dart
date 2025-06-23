// lib/core/services/api/driver_service.dart - FIXED VERSION (NON-ADMIN ONLY)
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class DriverApiService {
  final ApiService _apiService;

  DriverApiService(this._apiService);

  //Used by customer/store to view driver profile
  Future<Response> getDriverById(int driverId) async {
    return await _apiService.get(ApiEndpoints.getDriverById(driverId));
  }

  //Driver updates own location
  Future<Response> updateDriverLocation(
    int driverId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.patch(
      ApiEndpoints.updateDriverLocation(driverId),
      data: data,
    );
  }

  //Driver views own requests
  Future<Response> getDriverRequests({
    Map<String, dynamic>? queryParams,
  }) async {
    return await _apiService.get(
      ApiEndpoints.getDriverRequests,
      queryParameters: queryParams,
    );
  }

  //Use helper method from ApiEndpoints
  Future<Response> getDriverRequestDetail(int requestId) async {
    return await _apiService.get(ApiEndpoints.getDriverRequestById(requestId));
  }

  //Use helper method and correct HTTP method
  Future<Response> respondToDriverRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.post(
      ApiEndpoints.respondToDriverRequest(requestId),
      data: data,
    );
  }
}
