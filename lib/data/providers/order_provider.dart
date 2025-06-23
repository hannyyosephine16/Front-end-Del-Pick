// lib/data/providers/order_provider.dart - FIXED VERSION
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
      ApiEndpoints.customerOrders,
      queryParameters: params,
    );
  }

  Future<Response> getOrdersByStore({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.storeOrders,
      queryParameters: params,
    );
  }

  Future<Response> getOrderById(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderById(orderId));
  }

  Future<Response> getOrderDetail(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderById(orderId));
  }

  Future<Response> updateOrderStatus(
      int orderId, Map<String, dynamic> data) async {
    return await _apiService.patch(
      ApiEndpoints.updateOrderStatus(orderId),
      data: data,
    );
  }

  Future<Response> processOrder(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.processOrder(orderId),
      data: data,
    );
  }

  Future<Response> cancelOrder(int orderId) async {
    return await _apiService.patch(
      ApiEndpoints.updateOrderStatus(orderId),
      data: {'order_status': 'cancelled'},
    );
  }

  Future<Response> createReview(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.createOrderReview(orderId),
      data: data,
    );
  }

  // Driver-specific methods
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
      ApiEndpoints.customerOrders, // Use customer orders endpoint
      queryParameters: params.isNotEmpty ? params : null,
    );
  }

  Future<Response> getDriverActiveOrders() async {
    return await _apiService.get(
      ApiEndpoints.customerOrders,
      queryParameters: {
        'status': 'preparing,ready_for_pickup,on_delivery',
      },
    );
  }

  // Tracking methods
  Future<Response> getOrderTracking(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderTracking(orderId));
  }

  Future<Response> startDelivery(int orderId) async {
    return await _apiService.post(ApiEndpoints.startDelivery(orderId));
  }

  Future<Response> completeDelivery(int orderId) async {
    return await _apiService.post(ApiEndpoints.completeDelivery(orderId));
  }

  Future<Response> updateDriverLocation(
      int orderId, Map<String, dynamic> data) async {
    return await _apiService.put(
      ApiEndpoints.updateTrackingDriverLocation(orderId),
      data: data,
    );
  }

  Future<Response> getTrackingHistory(int orderId) async {
    return await _apiService.get(ApiEndpoints.getTrackingHistory(orderId));
  }

  Future<Response> trackOrder(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderTracking(orderId));
  }
}
