// lib/data/repositories/order_repository_extensions.dart - FINAL FIXED VERSION
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/utils/result.dart';
import '../models/order/order_list_response.dart';
import 'order_repository.dart';

extension OrderRepositoryExtensions on OrderRepository {
  /// Cancel order by ID - automatically detects role and uses appropriate method
  Future<Result<OrderModel>> cancelOrderById(
    int orderId, {
    String? reason,
    required String userRole,
  }) async {
    try {
      // Use the base repository's cancelOrder method
      final result = await cancelOrder(
        orderId,
        reason: reason,
        userRole: userRole,
      );

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!);
      } else {
        return Result.failure(result.message ?? 'Failed to cancel order');
      }
    } catch (e) {
      return Result.failure('Failed to cancel order: ${e.toString()}');
    }
  }

  /// Get user orders with status filtering
  Future<Result<OrderListResponse>> getOrdersByStatus({
    required String status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await getUserOrders(
        page: page,
        limit: limit,
        status: status,
      );
    } catch (e) {
      return Result.failure('Failed to get orders by status: ${e.toString()}');
    }
  }

  /// Get pending orders for user
  Future<Result<OrderListResponse>> getPendingOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return getOrdersByStatus(
      status: 'pending',
      page: page,
      limit: limit,
    );
  }

  /// Get active orders (non-completed orders)
  Future<Result<OrderListResponse>> getActiveOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await getUserOrders(page: page, limit: limit);

      if (result.isSuccess && result.data != null) {
        final orderList = result.data!;

        // Filter active orders (not delivered, cancelled, or rejected)
        final activeOrders = orderList.orders.where((order) {
          return !['delivered', 'cancelled', 'rejected']
              .contains(order.orderStatus);
        }).toList();

        final filteredResponse = OrderListResponse(
          orders: activeOrders,
          totalItems: activeOrders.length,
          totalPages: (activeOrders.length / limit).ceil(),
          currentPage: page,
        );

        return Result.success(filteredResponse);
      } else {
        return Result.failure(result.message ?? 'Failed to get active orders');
      }
    } catch (e) {
      return Result.failure('Failed to get active orders: ${e.toString()}');
    }
  }

  /// Get completed orders (delivered)
  Future<Result<OrderListResponse>> getCompletedOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return getOrdersByStatus(
      status: 'delivered',
      page: page,
      limit: limit,
    );
  }

  /// Get cancelled orders
  Future<Result<OrderListResponse>> getCancelledOrders({
    int page = 1,
    int limit = 10,
  }) async {
    return getOrdersByStatus(
      status: 'cancelled',
      page: page,
      limit: limit,
    );
  }

  /// Check if user can cancel specific order
  Future<Result<bool>> canUserCancelOrder(
    int orderId,
    String userRole,
  ) async {
    try {
      final orderResult = await getOrderById(orderId);

      if (orderResult.isSuccess && orderResult.data != null) {
        final order = orderResult.data!;
        final canCancel = this.canCancelOrder(order, userRole);
        return Result.success(canCancel);
      } else {
        return Result.failure(orderResult.message ?? 'Order not found');
      }
    } catch (e) {
      return Result.failure(
          'Failed to check cancellation eligibility: ${e.toString()}');
    }
  }

  /// Get appropriate cancellation reasons for user role
  List<String> getOrderCancellationReasons(String userRole) {
    return getCancellationReasons(userRole);
  }

  /// Bulk cancel multiple orders (for admin/store operations)
  Future<Result<List<OrderModel>>> cancelMultipleOrders(
    List<int> orderIds, {
    String? reason,
    required String userRole,
  }) async {
    try {
      final List<OrderModel> cancelledOrders = [];
      final List<String> errors = [];

      for (final orderId in orderIds) {
        final result = await cancelOrder(
          orderId,
          reason: reason,
          userRole: userRole,
        );

        if (result.isSuccess && result.data != null) {
          cancelledOrders.add(result.data!);
        } else {
          errors.add('Order $orderId: ${result.message}');
        }
      }

      if (errors.isNotEmpty) {
        return Result.failure(
            'Some orders failed to cancel: ${errors.join(', ')}');
      }

      return Result.success(cancelledOrders);
    } catch (e) {
      return Result.failure(
          'Failed to cancel multiple orders: ${e.toString()}');
    }
  }

  /// Get order summary statistics
  Future<Result<Map<String, int>>> getOrderStatistics() async {
    try {
      final result = await getUserOrders(limit: 1000); // Get all orders

      if (result.isSuccess && result.data != null) {
        final orders = result.data!.orders;

        final stats = <String, int>{
          'total': orders.length,
          'pending': orders.where((o) => o.orderStatus == 'pending').length,
          'confirmed': orders.where((o) => o.orderStatus == 'confirmed').length,
          'preparing': orders.where((o) => o.orderStatus == 'preparing').length,
          'ready_for_pickup':
              orders.where((o) => o.orderStatus == 'ready_for_pickup').length,
          'on_delivery':
              orders.where((o) => o.orderStatus == 'on_delivery').length,
          'delivered': orders.where((o) => o.orderStatus == 'delivered').length,
          'cancelled': orders.where((o) => o.orderStatus == 'cancelled').length,
          'rejected': orders.where((o) => o.orderStatus == 'rejected').length,
        };

        return Result.success(stats);
      } else {
        return Result.failure(result.message ?? 'Failed to get orders');
      }
    } catch (e) {
      return Result.failure('Failed to get order statistics: ${e.toString()}');
    }
  }

  /// Search orders by query (order code, store name, etc.)
  Future<Result<OrderListResponse>> searchOrders({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await getUserOrders(page: page, limit: limit);

      if (result.isSuccess && result.data != null) {
        final orderList = result.data!;

        // Filter orders based on search query
        final filteredOrders = orderList.orders.where((order) {
          final queryLower = query.toLowerCase();
          return order.code.toLowerCase().contains(queryLower) ||
              order.storeName.toLowerCase().contains(queryLower) ||
              order.orderStatus.toLowerCase().contains(queryLower);
        }).toList();

        final searchResponse = OrderListResponse(
          orders: filteredOrders,
          totalItems: filteredOrders.length,
          totalPages: (filteredOrders.length / limit).ceil(),
          currentPage: page,
        );

        return Result.success(searchResponse);
      } else {
        return Result.failure(result.message ?? 'Failed to search orders');
      }
    } catch (e) {
      return Result.failure('Failed to search orders: ${e.toString()}');
    }
  }
}
