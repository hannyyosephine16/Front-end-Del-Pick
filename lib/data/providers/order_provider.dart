// lib/data/providers/order_provider.dart - LENGKAP DENGAN METHOD YANG HILANG
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:get/get.dart' as getx;

class OrderProvider {
  final ApiService _apiService = getx.Get.find<ApiService>();

  Future<Response> createOrder(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createOrder, data: data);
  }

  Future<Response> getOrdersByUser({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.userOrders,
      queryParameters: params,
    );
  }

  Future<Response> getUserOrders({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.userOrders,
      queryParameters: params,
    );
  }

  Future<Response> getOrderById(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderById(orderId));
  }

  Future<Response> getOrdersByStore({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.storeOrders,
      queryParameters: params,
    );
  }

  Future<Response> getOrderDetail(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderById(orderId));
  }

  Future<Response> updateOrderStatus(Map<String, dynamic> data) async {
    return await _apiService.put(ApiEndpoints.updateOrderStatus, data: data);
  }

  Future<Response> processOrder(int orderId, Map<String, dynamic> data) async {
    return await _apiService.put(
      ApiEndpoints.processOrder(orderId),
      data: data,
    );
  }

  Future<Response> cancelOrder(int orderId) async {
    return await _apiService.put(ApiEndpoints.cancelOrder(orderId));
  }

  Future<Response> createReview(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createReview, data: data);
  }

  // ========================================================================
  // NEW METHODS - TAMBAHAN UNTUK DRIVER FUNCTIONALITY
  // ========================================================================

  /// Get driver orders - ENDPOINT: GET /drivers/orders
  Future<Response> getDriverOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (status != null) params['status'] = status;

    return await _apiService.get(
      ApiEndpoints.driverOrders, // Add this to ApiEndpoints: '/drivers/orders'
      queryParameters: params.isNotEmpty ? params : null,
    );
  }

  /// Get driver active orders - FILTER dari driver orders
  Future<Response> getDriverActiveOrders() async {
    return await _apiService.get(
      ApiEndpoints.driverOrders, // Add this to ApiEndpoints: '/drivers/orders'
      queryParameters: {
        'status': 'approved,preparing,on_delivery', // active statuses
      },
    );
  }

  // ========================================================================
  // TRACKING METHODS untuk Driver - SESUAI SWAGGER
  // ========================================================================

  /// Start delivery - ENDPOINT: PUT /tracking/{orderId}/start
  Future<Response> startDelivery(int orderId) async {
    return await _apiService.put(
      ApiEndpoints.startDelivery(
          orderId), // Add this to ApiEndpoints: '/tracking/$orderId/start'
    );
  }

  /// Complete delivery - ENDPOINT: PUT /tracking/{orderId}/complete
  Future<Response> completeDelivery(int orderId) async {
    return await _apiService.put(
      ApiEndpoints.completeDelivery(
          orderId), // Add this to ApiEndpoints: '/tracking/$orderId/complete'
    );
  }

  /// Track order - ENDPOINT: GET /tracking/{orderId}
  Future<Response> trackOrder(int orderId) async {
    return await _apiService.get(
      ApiEndpoints.getTrackingData(
          orderId), // Add this to ApiEndpoints: '/tracking/$orderId'
    );
  }
}
