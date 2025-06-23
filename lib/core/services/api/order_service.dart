// lib/core/services/api/order_service.dart
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class OrderApiService {
  final ApiService _apiService;

  OrderApiService(this._apiService);

  // ✅ FIXED: Create order - sesuai backend POST /orders
  Future<Response> createOrder(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createOrder, data: data);
  }

  // ✅ FIXED: Get customer orders - sesuai backend GET /orders/customer
  Future<Response> getCustomerOrders(
      {Map<String, dynamic>? queryParams}) async {
    return await _apiService.get(
      ApiEndpoints.customerOrders,
      queryParameters: queryParams,
    );
  }

  // ✅ FIXED: Get store orders - sesuai backend GET /orders/store
  Future<Response> getStoreOrders({Map<String, dynamic>? queryParams}) async {
    return await _apiService.get(
      ApiEndpoints.storeOrders,
      queryParameters: queryParams,
    );
  }

  // ✅ FIXED: Get order detail - sesuai backend GET /orders/:id
  Future<Response> getOrderDetail(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderById(orderId));
  }

  // ✅ FIXED: Update order status - sesuai backend PATCH /orders/:id/status
  Future<Response> updateOrderStatus(
      int orderId, Map<String, dynamic> data) async {
    return await _apiService.patch(
      ApiEndpoints.updateOrderStatus(orderId),
      data: data,
    );
  }

  // ✅ FIXED: Process order by store - sesuai backend POST /orders/:id/process
  Future<Response> processOrder(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.processOrder(orderId),
      data: data,
    );
  }

  // ✅ REMOVED: Cancel order - backend tidak ada endpoint khusus cancel
  // Gunakan updateOrderStatus dengan status 'cancelled'

  // ✅ FIXED: Create review - sesuai backend POST /orders/:id/review
  Future<Response> createReview(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.createOrderReview(orderId),
      data: data,
    );
  }

  // ✅ ADDED: Tracking endpoints sesuai backend
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
}
