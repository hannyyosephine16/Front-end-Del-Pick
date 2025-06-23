// lib/core/services/api/tracking_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/utils/result.dart';

class TrackingService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // ✅ FIXED: Get tracking data - sesuai backend GET /orders/:id/tracking
  Future<Result<Map<String, dynamic>>> getTrackingData(int orderId) async {
    try {
      final response =
          await _apiService.get(ApiEndpoints.getOrderTracking(orderId));

      if (response.statusCode == 200) {
        return Result.success(response.data['data']);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to get tracking data');
      }
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }

  // ✅ FIXED: Start delivery - sesuai backend POST /orders/:id/tracking/start
  Future<Result<Map<String, dynamic>>> startDelivery(int orderId) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.startDelivery(orderId));

      if (response.statusCode == 200) {
        return Result.success(response.data['data']);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to start delivery');
      }
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }

  // ✅ FIXED: Complete delivery - sesuai backend POST /orders/:id/tracking/complete
  Future<Result<Map<String, dynamic>>> completeDelivery(int orderId) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.completeDelivery(orderId));

      if (response.statusCode == 200) {
        return Result.success(response.data['data']);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to complete delivery');
      }
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }

  // ✅ FIXED: Update driver location - sesuai backend PUT /orders/:id/tracking/location
  Future<Result<Map<String, dynamic>>> updateDriverLocation(
    int orderId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateTrackingDriverLocation(orderId),
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        return Result.success(response.data['data']);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to update location');
      }
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }

  // ✅ ADDED: Get tracking history - sesuai backend GET /orders/:id/tracking/history
  Future<Result<Map<String, dynamic>>> getTrackingHistory(int orderId) async {
    try {
      final response =
          await _apiService.get(ApiEndpoints.getTrackingHistory(orderId));

      if (response.statusCode == 200) {
        return Result.success(response.data['data']);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to get tracking history');
      }
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }
}
