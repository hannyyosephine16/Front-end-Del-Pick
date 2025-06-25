// lib/data/providers/driver_request_provider.dart - FIXED
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:get/get.dart' as getx;

class DriverRequestProvider {
  final ApiService _apiService = getx.Get.find<ApiService>();

  /// Get driver requests - GET /driver-requests
  Future<Response> getDriverRequests({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.getDriverRequests,
      queryParameters: params,
    );
  }

  /// Get driver request detail - GET /driver-requests/{id}
  Future<Response> getDriverRequestById(int requestId) async {
    return await _apiService.get(
      ApiEndpoints.getDriverRequestById(requestId),
    );
  }

  /// Respond to driver request - POST /driver-requests/{id}/respond
  Future<Response> respondToDriverRequest(
      int requestId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.respondToDriverRequest(requestId),
      data: data,
    );
  }
}
