// lib/data/datasources/remote/order_remote_datasource.dart - SESUAI ApiService ANDA
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:dio/dio.dart';

class OrderRemoteDataSource {
  final ApiService _apiService;
  final AuthLocalDataSource _authLocalDataSource;

  OrderRemoteDataSource({
    required ApiService apiService,
    required AuthLocalDataSource authLocalDataSource,
  })  : _apiService = apiService,
        _authLocalDataSource = authLocalDataSource;

  // ========================================================================
  // DRIVER ENDPOINTS - SESUAI SWAGGER
  // ========================================================================

  /// Get driver orders - ENDPOINT: GET /drivers/orders
  Future<Response> getDriverOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;

    return await _apiService.get(
      '/drivers/orders',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get driver active orders - FILTER dari /drivers/orders dengan status
  Future<Response> getDriverActiveOrders() async {
    // Filter orders yang tidak cancelled atau delivered
    return await _apiService.get(
      '/drivers/orders',
      queryParameters: {
        'status': 'approved,preparing,on_delivery', // active statuses
      },
    );
  }

  /// Update order status by driver - ENDPOINT: PUT /orders/status (admin only)
  /// NOTE: Dari swagger, sepertinya driver tidak bisa langsung update order status
  /// Driver menggunakan tracking endpoints untuk start/complete delivery
  Future<Response> updateOrderStatusByDriver({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    return await _apiService.put(
      '/orders/status',
      data: {
        'id': int.parse(orderId),
        'status': data['status'],
      },
    );
  }

  /// Get order details untuk driver - ENDPOINT: GET /orders/{orderId}
  Future<Response> getOrderDetailsForDriver(String orderId) async {
    return await _apiService.get('/orders/$orderId');
  }

  // ========================================================================
  // TRACKING ENDPOINTS untuk Driver - SESUAI SWAGGER
  // ========================================================================

  /// Start delivery - ENDPOINT: PUT /tracking/{orderId}/start
  Future<Response> startDelivery(String orderId) async {
    return await _apiService.put('/tracking/$orderId/start');
  }

  /// Complete delivery - ENDPOINT: PUT /tracking/{orderId}/complete
  Future<Response> completeDelivery(String orderId) async {
    return await _apiService.put('/tracking/$orderId/complete');
  }

  /// Track order - ENDPOINT: GET /tracking/{orderId}
  Future<Response> trackOrder(String orderId) async {
    return await _apiService.get('/tracking/$orderId');
  }

  // ========================================================================
  // CUSTOMER ENDPOINTS - SESUAI SWAGGER
  // ========================================================================

  /// Get orders untuk customer - ENDPOINT: GET /orders/user
  Future<Response> getCustomerOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;

    return await _apiService.get(
      '/orders/user',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Create order by customer - ENDPOINT: POST /orders
  Future<Response> createOrder(Map<String, dynamic> data) async {
    return await _apiService.post(
      '/orders',
      data: data,
    );
  }

  /// Get order details untuk customer - ENDPOINT: GET /orders/{orderId}
  Future<Response> getOrderDetails(String orderId) async {
    return await _apiService.get('/orders/$orderId');
  }

  /// Cancel order by customer - ENDPOINT: PUT /orders/{orderId}/cancel
  Future<Response> cancelOrder(String orderId) async {
    return await _apiService.put('/orders/$orderId/cancel');
  }

  // ========================================================================
  // STORE OWNER ENDPOINTS - SESUAI SWAGGER
  // ========================================================================

  /// Get store orders - ENDPOINT: GET /orders/store
  Future<Response> getStoreOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;

    return await _apiService.get(
      '/orders/store',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Process order - ENDPOINT: PUT /orders/{orderId}/process
  Future<Response> processOrder(
      String orderId, Map<String, dynamic> data) async {
    return await _apiService.put(
      '/orders/$orderId/process',
      data: data, // {action: "approve" atau "reject", rejectionReason?: string}
    );
  }

  // ========================================================================
  // REVIEW ENDPOINTS - SESUAI SWAGGER
  // ========================================================================

  /// Create order review - ENDPOINT: POST /orders/review
  Future<Response> createOrderReview(Map<String, dynamic> data) async {
    return await _apiService.post(
      '/orders/review',
      data: data,
    );
  }
}
