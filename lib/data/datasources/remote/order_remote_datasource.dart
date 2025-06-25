import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:dio/dio.dart';

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
}
