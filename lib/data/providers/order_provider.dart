import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class OrderProvider {
  final ApiService _apiService;

  OrderProvider(this._apiService);

  /// Create order - POST /orders
  Future<Response> createOrder(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createOrder, data: data);
  }

  /// Get customer orders - GET /orders/customer
  Future<Response> getOrdersByUser({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.customerOrders,
      queryParameters: params,
    );
  }

  /// Get store orders - GET /orders/store
  Future<Response> getOrdersByStore({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.storeOrders,
      queryParameters: params,
    );
  }

  /// Get order by ID - GET /orders/:id
  Future<Response> getOrderById(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderById(orderId));
  }

  /// Get order detail (alias)
  Future<Response> getOrderDetail(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderById(orderId));
  }

  /// Update order status - PATCH /orders/:id/status
  Future<Response> updateOrderStatus(
      int orderId, Map<String, dynamic> data) async {
    return await _apiService.patch(
      ApiEndpoints.updateOrderStatus(orderId),
      data: data,
    );
  }

  /// Process order (approve/reject) - POST /orders/:id/process
  Future<Response> processOrder(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.processOrder(orderId),
      data: data,
    );
  }

  /// Cancel order - PATCH /orders/:id/status
  Future<Response> cancelOrder(int orderId) async {
    return await _apiService.patch(
      ApiEndpoints.updateOrderStatus(orderId),
      data: {'order_status': 'cancelled'},
    );
  }

  /// Create review - POST /orders/:id/review
  Future<Response> createReview(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.createOrderReview(orderId),
      data: data,
    );
  }

  /// Get tracking data - GET /orders/:id/tracking
  Future<Response> getOrderTracking(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderTracking(orderId));
  }

  /// Start delivery - POST /orders/:id/tracking/start
  Future<Response> startDelivery(int orderId) async {
    return await _apiService.post(ApiEndpoints.startDelivery(orderId));
  }

  /// Complete delivery - POST /orders/:id/tracking/complete
  Future<Response> completeDelivery(int orderId) async {
    return await _apiService.post(ApiEndpoints.completeDelivery(orderId));
  }

  /// Update driver location - PUT /orders/:id/tracking/location
  Future<Response> updateDriverLocation(
      int orderId, Map<String, dynamic> data) async {
    return await _apiService.put(
      ApiEndpoints.updateTrackingDriverLocation(orderId),
      data: data,
    );
  }

  /// Get tracking history - GET /orders/:id/tracking/history
  Future<Response> getTrackingHistory(int orderId) async {
    return await _apiService.get(ApiEndpoints.getTrackingHistory(orderId));
  }

  /// Track order (alias for getOrderTracking)
  Future<Response> trackOrder(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderTracking(orderId));
  }

  /// Get driver orders (use customer orders with filtering)
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
      ApiEndpoints.customerOrders,
      queryParameters: params.isNotEmpty ? params : null,
    );
  }

  /// Get active orders for driver
  Future<Response> getDriverActiveOrders() async {
    return await _apiService.get(
      ApiEndpoints.customerOrders,
      queryParameters: {
        'status': 'preparing,ready_for_pickup,on_delivery',
      },
    );
  }
}
