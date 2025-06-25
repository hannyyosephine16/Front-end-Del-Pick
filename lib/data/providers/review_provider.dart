import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class ReviewProvider {
  final ApiService _apiService;

  ReviewProvider(this._apiService);

  /// Create review for order - POST /orders/:id/review
  Future<Response> createReview(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.createOrderReview(orderId),
      data: data,
    );
  }

  /// Get store reviews (if implemented in backend)
  Future<Response> getStoreReviews(int storeId,
      {Map<String, dynamic>? params}) async {
    return await _apiService.get(
      '/stores/$storeId/reviews',
      queryParameters: params,
    );
  }

  /// Get driver reviews (if implemented in backend)
  Future<Response> getDriverReviews(int driverId,
      {Map<String, dynamic>? params}) async {
    return await _apiService.get(
      '/drivers/$driverId/reviews',
      queryParameters: params,
    );
  }
}
