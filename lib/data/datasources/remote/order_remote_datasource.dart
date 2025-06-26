import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:dio/dio.dart';

import '../../../core/utils/result.dart';
import '../../models/order/create_order_request.dart';
import '../../models/order/place_order_response.dart';

class OrderRemoteDataSource {
  final ApiService _apiService;

  OrderRemoteDataSource(this._apiService);

  // CUSTOMER ENDPOINTS
  Future<Response> getCustomerOrders(
      {int? page, int? limit, String? status}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;

    return await _apiService.get(
      ApiEndpoints.customerOrders,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  // Future<Response> createOrder(Map<String, dynamic> data) async {
  //   return await _apiService.post(ApiEndpoints.createOrder, data: data);
  // }
  Future<PlaceOrderResponse> placeOrder(CreateOrderRequest request) async {
    final response = await _apiService.post(
      ApiEndpoints.createOrder,
      data: request.toJson(),
    );

    return PlaceOrderResponse.fromJson(response.data);
  }

  // ✅ DEPRECATED: Keep for backward compatibility but use placeOrder instead
  @Deprecated('Use placeOrder(CreateOrderRequest) instead')
  Future<Response> createOrder(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createOrder, data: data);
  }

  Future<Response> getOrderById(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderById(orderId));
  }

  // STORE ENDPOINTS
  Future<Response> getStoreOrders(
      {int? page, int? limit, String? status}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;

    return await _apiService.get(
      ApiEndpoints.storeOrders,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  Future<Response> processOrder(int orderId, String action) async {
    return await _apiService.post(
      ApiEndpoints.processOrder(orderId),
      data: {'action': action},
    );
  }

  Future<Response> updateOrderStatus(
      int orderId, Map<String, dynamic> data) async {
    return await _apiService.patch(
      ApiEndpoints.updateOrderStatus(orderId),
      data: data,
    );
  }

  // TRACKING ENDPOINTS
  Future<Response> getTrackingData(int orderId) async {
    return await _apiService.get(ApiEndpoints.getOrderTracking(orderId));
  }

  Future<Response> startDelivery(int orderId) async {
    return await _apiService.post(ApiEndpoints.startDelivery(orderId));
  }

  Future<Response> completeDelivery(int orderId) async {
    return await _apiService.post(ApiEndpoints.completeDelivery(orderId));
  }

  Future<Response> updateDriverLocation(
      int orderId, double latitude, double longitude) async {
    return await _apiService.put(
      ApiEndpoints.updateTrackingDriverLocation(orderId),
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }

  Future<Response> getTrackingHistory(int orderId) async {
    return await _apiService.get(ApiEndpoints.getTrackingHistory(orderId));
  }

  // REVIEW ENDPOINTS
  Future<Response> createOrderReview(
      int orderId, Map<String, dynamic> reviewData) async {
    return await _apiService.post(
      ApiEndpoints.createOrderReview(orderId),
      data: reviewData,
    );
  }

  // lib/data/datasources/remote/order_remote_datasource.dart - ADD DRIVER REQUEST METHODS
// Tambahkan method-method ini ke dalam class OrderRemoteDataSource yang sudah ada

  // ✅ DRIVER REQUEST ENDPOINTS - untuk mendapatkan orders dari driver requests

  /// Get driver requests - Backend: GET /driver-requests
  Future<Response> getDriverRequests({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;

    return await _apiService.get(
      '/driver-requests', // Sesuai dengan backend endpoint
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get driver request detail - Backend: GET /driver-requests/:id
  Future<Response> getDriverRequestDetail(int driverRequestId) async {
    return await _apiService.get('/driver-requests/$driverRequestId');
  }

  /// Respond to driver request - Backend: POST /driver-requests/:id/respond
  Future<Response> respondToDriverRequest(
    int driverRequestId,
    String action, // 'accept' or 'reject'
  ) async {
    return await _apiService.post(
      '/driver-requests/$driverRequestId/respond',
      data: {'action': action},
    );
  }

  // ✅ Fallback methods jika tidak ada driver request endpoints

  /// Get driver orders (fallback) - uses general orders endpoint
  Future<Response> getDriverOrdersFallback({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;

    // Backend filters by driver role automatically based on authentication
    return await _apiService.get(
      '/orders',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }
}
