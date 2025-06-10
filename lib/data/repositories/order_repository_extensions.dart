// lib/data/repositories/order_repository_extensions.dart - FIXED
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'order_repository.dart';

extension OrderRepositoryExtensions on OrderRepository {
  /// Get user orders with pagination and filtering
  Future<Result<OrderListResponse>> getUserOrders({
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

      // Use the existing getOrdersByUser method
      final result = await getOrdersByUser(params: queryParams);

      if (result.isSuccess && result.data != null) {
        final paginatedResponse = result.data!;

        final orderListResponse = OrderListResponse(
          orders: paginatedResponse.data,
          totalItems: paginatedResponse.totalItems,
          totalPages: paginatedResponse.totalPages,
          currentPage: paginatedResponse.currentPage,
        );

        return Result.success(orderListResponse);
      } else {
        return Result.failure(result.message ?? 'Failed to get orders');
      }
    } catch (e) {
      return Result.failure('Failed to get user orders: ${e.toString()}');
    }
  }

  /// Cancel order - use existing method
  Future<Result<OrderModel>> cancelOrderById(int orderId) async {
    try {
      final result = await cancelOrder(orderId);

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!);
      } else {
        return Result.failure(result.message ?? 'Failed to cancel order');
      }
    } catch (e) {
      return Result.failure('Failed to cancel order: ${e.toString()}');
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
