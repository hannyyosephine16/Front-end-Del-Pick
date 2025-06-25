// lib/data/providers/tracking_provider.dart - FIXED
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:get/get.dart' as getx;

class TrackingProvider {
  final ApiService _apiService = getx.Get.find<ApiService>();

  /// Get tracking data - GET /orders/{orderId}/tracking
  Future<Response> getTrackingData(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderTracking(orderId));
  }

  /// Start delivery - POST /orders/{orderId}/tracking/start
  Future<Response> startDelivery(int orderId) async {
    return await _apiService.post(ApiEndpoints.startDelivery(orderId));
  }

  /// Complete delivery - POST /orders/{orderId}/tracking/complete
  Future<Response> completeDelivery(int orderId) async {
    return await _apiService.post(ApiEndpoints.completeDelivery(orderId));
  }

  /// Update driver location - PUT /orders/{orderId}/tracking/location
  Future<Response> updateDriverLocation(
      int orderId, double latitude, double longitude) async {
    return await _apiService.put(
      ApiEndpoints.updateTrackingDriverLocation(orderId),
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }

  /// Get tracking history - GET /orders/{orderId}/tracking/history
  Future<Response> getTrackingHistory(int orderId) async {
    return await _apiService.get(ApiEndpoints.getTrackingHistory(orderId));
  }
}
