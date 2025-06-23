// lib/data/providers/review_provider.dart
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:get/get.dart' as getx;

class ReviewProvider {
  final ApiService _apiService = getx.Get.find<ApiService>();

  /// Create review for order (both order and driver review)
  /// Backend endpoint: POST /orders/{orderId}/review
  Future<Response> createReview(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.createOrderReview(orderId),
      data: data,
    );
  }

  /// Get reviews for a store (if needed in future)
  Future<Response> getStoreReviews(int storeId,
      {Map<String, dynamic>? params}) async {
    return await _apiService.get(
      '/stores/$storeId/reviews', // Custom endpoint if implemented
      queryParameters: params,
    );
  }

  /// Get reviews for a driver (if needed in future)
  Future<Response> getDriverReviews(int driverId,
      {Map<String, dynamic>? params}) async {
    return await _apiService.get(
      '/drivers/$driverId/reviews', // Custom endpoint if implemented
      queryParameters: params,
    );
  }
}
