// lib/core/services/api/review_service.dart
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class ReviewApiService {
  final ApiService _apiService;

  ReviewApiService(this._apiService);

  // ✅ FIXED: Create review sesuai backend POST /orders/:id/review
  Future<Response> createOrderReview(
      int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.createOrderReview(orderId),
      data: data,
    );
  }

// ✅ Backend tidak memiliki endpoint khusus untuk get reviews
// Reviews diambil melalui order detail atau store/driver detail
}
