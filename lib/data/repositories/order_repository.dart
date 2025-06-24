// lib/data/repositories/order_repository.dart - COMPLETE FIXED VERSION
import 'package:del_pick/data/datasources/remote/order_remote_datasource.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';
import 'package:del_pick/data/models/order/order_list_response.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';

class OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepository(this._remoteDataSource);

  // ✅ CORE ORDER METHODS

  Future<Result<OrderModel>> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _remoteDataSource.createOrder(data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          return Result.success(order);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to create order');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ GET CUSTOMER ORDERS - Backend Compatible
  Future<Result<PaginatedResponse<OrderModel>>> getCustomerOrders({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _remoteDataSource.getCustomerOrders(
        page: params?['page'],
        limit: params?['limit'],
        status: params?['status'],
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data')) {
          final data = responseData['data'] as Map<String, dynamic>;

          final orders = (data['orders'] as List? ?? [])
              .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
              .toList();

          final paginatedResponse = PaginatedResponse<OrderModel>(
            items: orders,
            totalItems: data['totalItems'] as int? ?? orders.length,
            totalPages: data['totalPages'] as int? ?? 1,
            currentPage: data['currentPage'] as int? ?? 1,
          );

          return Result.success(paginatedResponse);
        } else {
          return Result.failure(responseData['message'] ?? 'No data found');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ GET STORE ORDERS - Backend Compatible
  Future<Result<PaginatedResponse<OrderModel>>> getStoreOrders({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _remoteDataSource.getStoreOrders(
        page: params?['page'],
        limit: params?['limit'],
        status: params?['status'],
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data')) {
          final data = responseData['data'] as Map<String, dynamic>;

          final orders = (data['orders'] as List? ?? [])
              .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
              .toList();

          final paginatedResponse = PaginatedResponse<OrderModel>(
            items: orders,
            totalItems: data['totalItems'] as int? ?? orders.length,
            totalPages: data['totalPages'] as int? ?? 1,
            currentPage: data['currentPage'] as int? ?? 1,
          );

          return Result.success(paginatedResponse);
        } else {
          return Result.failure(responseData['message'] ?? 'No data found');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ WRAPPER METHOD for getUserOrders (Extension compatibility)
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

      final result = await getCustomerOrders(params: queryParams);

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

  Future<Result<OrderModel>> getOrderById(int orderId) async {
    try {
      final response = await _remoteDataSource.getOrderById(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          return Result.success(order);
        } else {
          return Result.failure(responseData['message'] ?? 'Order not found');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<OrderModel>> processOrder(int orderId, String action) async {
    try {
      final response = await _remoteDataSource.processOrder(orderId, action);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          return Result.success(order);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to process order');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<OrderModel>> updateOrderStatus(
    int orderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDataSource.updateOrderStatus(orderId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          return Result.success(order);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to update order status');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> createOrderReview(
    int orderId,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response =
          await _remoteDataSource.createOrderReview(orderId, reviewData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ CANCEL ORDER METHODS

  /// Cancel order by Store (reject action)
  /// Uses POST /orders/:id/process endpoint with action: 'reject'
  Future<Result<OrderModel>> cancelOrderByStore(
    int orderId, {
    String? reason,
  }) async {
    try {
      final response = await _remoteDataSource.processOrder(orderId, 'reject');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          return Result.success(order);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to cancel order');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Cancel order by Customer
  /// Uses PATCH /orders/:id/status endpoint with order_status: 'cancelled'
  Future<Result<OrderModel>> cancelOrderByCustomer(
    int orderId, {
    String? reason,
  }) async {
    try {
      final data = <String, dynamic>{
        'order_status': 'cancelled',
      };

      if (reason != null && reason.isNotEmpty) {
        data['cancellation_reason'] = reason;
      }

      final response = await _remoteDataSource.updateOrderStatus(orderId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          return Result.success(order);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to cancel order');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Cancel order by Driver
  /// Uses PATCH /orders/:id/status endpoint with order_status: 'cancelled'
  Future<Result<OrderModel>> cancelOrderByDriver(
    int orderId, {
    String? reason,
  }) async {
    try {
      final data = <String, dynamic>{
        'order_status': 'cancelled',
        'delivery_status': 'cancelled',
      };

      if (reason != null && reason.isNotEmpty) {
        data['cancellation_reason'] = reason;
      }

      final response = await _remoteDataSource.updateOrderStatus(orderId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          return Result.success(order);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to cancel order');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Generic cancel order method
  Future<Result<OrderModel>> cancelOrder(
    int orderId, {
    String? reason,
    String? userRole,
  }) async {
    if (userRole == null) {
      return Result.failure('User role is required for cancellation');
    }

    switch (userRole.toLowerCase()) {
      case 'store':
        return cancelOrderByStore(orderId, reason: reason);
      case 'customer':
        return cancelOrderByCustomer(orderId, reason: reason);
      case 'driver':
        return cancelOrderByDriver(orderId, reason: reason);
      default:
        return Result.failure('Invalid user role for cancellation');
    }
  }

  // ✅ STORE SPECIFIC ACTIONS

  /// Approve order by Store
  Future<Result<OrderModel>> approveOrderByStore(int orderId) async {
    try {
      final response = await _remoteDataSource.processOrder(orderId, 'approve');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          return Result.success(order);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to approve order');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Reject order by Store (alias for cancelOrderByStore)
  Future<Result<OrderModel>> rejectOrderByStore(
    int orderId, {
    String? reason,
  }) async {
    return cancelOrderByStore(orderId, reason: reason);
  }

  // ✅ BUSINESS LOGIC HELPERS

  /// Check if order can be cancelled by the given role
  bool canCancelOrder(OrderModel order, String userRole) {
    switch (userRole.toLowerCase()) {
      case 'customer':
        return ['pending', 'confirmed'].contains(order.orderStatus);
      case 'store':
        return order.orderStatus == 'pending';
      case 'driver':
        return ['ready_for_pickup', 'on_delivery']
                .contains(order.orderStatus) &&
            order.driverId != null;
      default:
        return false;
    }
  }

  /// Get cancellation reasons based on user role
  List<String> getCancellationReasons(String userRole) {
    switch (userRole.toLowerCase()) {
      case 'customer':
        return [
          'Changed mind',
          'Found better price elsewhere',
          'Ordered by mistake',
          'Emergency came up',
          'Payment issue',
          'Other'
        ];
      case 'store':
        return [
          'Out of stock',
          'Store closing early',
          'Unable to prepare order',
          'Address unreachable',
          'Technical issue',
          'Other'
        ];
      case 'driver':
        return [
          'Vehicle breakdown',
          'Emergency situation',
          'Unable to reach store',
          'Unable to reach customer',
          'Safety concerns',
          'Other'
        ];
      default:
        return [];
    }
  }

  // ✅ TRACKING METHODS

  Future<Result<Map<String, dynamic>>> getTrackingData(int orderId) async {
    try {
      final response = await _remoteDataSource.getTrackingData(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data')) {
          return Result.success(responseData['data'] as Map<String, dynamic>);
        } else {
          return Result.failure(
              responseData['message'] ?? 'No tracking data found');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> startDelivery(int orderId) async {
    try {
      final response = await _remoteDataSource.startDelivery(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data')) {
          return Result.success(responseData['data'] as Map<String, dynamic>);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to start delivery');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> completeDelivery(int orderId) async {
    try {
      final response = await _remoteDataSource.completeDelivery(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data')) {
          return Result.success(responseData['data'] as Map<String, dynamic>);
        } else {
          return Result.failure(
              responseData['message'] ?? 'Failed to complete delivery');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> updateDriverLocation(
    int orderId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _remoteDataSource.updateDriverLocation(
        orderId,
        latitude,
        longitude,
      );

      if (response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getTrackingHistory(int orderId) async {
    try {
      final response = await _remoteDataSource.getTrackingHistory(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data')) {
          return Result.success(responseData['data'] as Map<String, dynamic>);
        } else {
          return Result.failure(
              responseData['message'] ?? 'No tracking history found');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ ERROR HANDLING

  String _extractErrorMessage(Response response) {
    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 'Request failed';
    }
    return 'Request failed';
  }

  String _handleDioError(DioException e) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      final responseData = response!.data as Map<String, dynamic>;

      if (response.statusCode == 400 && responseData.containsKey('errors')) {
        final errors = responseData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
      }

      return responseData['message'] ?? 'Network error occurred';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timeout';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error occurred';
    }
  }
}
