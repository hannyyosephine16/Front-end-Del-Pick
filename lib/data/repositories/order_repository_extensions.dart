// lib/data/repositories/order_repository_extensions.dart - FIXED
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/utils/result.dart';
import '../models/order/order_list_response.dart';
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
          orders: paginatedResponse.items,
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
