// lib/data/repositories/order_repository_extensions.dart
import 'package:del_pick/data/models/order/order_model.dart';

import '../providers/order_provider.dart';
import 'order_repository.dart';

extension OrderRepositoryExtensions on OrderRepository {
  /// Get user orders with pagination and filtering

  Future<ApiResponse<OrderListResponse>> getUserOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        '/orders/user',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final orders = (response.data['data']['orders'] as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();

        final orderListResponse = OrderListResponse(
          orders: orders,
          totalItems: response.data['data']['totalItems'] ?? 0,
          totalPages: response.data['data']['totalPages'] ?? 0,
          currentPage: response.data['data']['currentPage'] ?? 1,
        );

        return ApiResponse.success(
          data: orderListResponse,
          message: response.data['message'] ?? 'Orders retrieved successfully',
        );
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to get orders',
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'Failed to get user orders',
        statusCode: 500,
      );
    }
  }

  /// Get order detail by ID
  Future<ApiResponse<OrderModel>> getOrderDetail(int orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(response.data['data']);
        return ApiResponse.success(
          data: order,
          message:
              response.data['message'] ?? 'Order detail retrieved successfully',
        );
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to get order detail',
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'Failed to get order detail',
        statusCode: 500,
      );
    }
  }

  /// Cancel order
  Future<ApiResponse<OrderModel>> cancelOrder(int orderId) async {
    try {
      final response = await _apiService.put('/orders/$orderId/cancel');

      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(response.data['data']);
        return ApiResponse.success(
          data: order,
          message: response.data['message'] ?? 'Order cancelled successfully',
        );
      } else {
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to cancel order',
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'Failed to cancel order',
        statusCode: 500,
      );
    }
  }
}

// lib/data/models/order/order_list_response.dart
class OrderListResponse {
  final List<OrderModel> orders;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  OrderListResponse({
    required this.orders,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      orders: (json['orders'] as List)
          .map((orderJson) => OrderModel.fromJson(orderJson))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }
}
