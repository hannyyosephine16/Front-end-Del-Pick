// lib/data/repositories/order_repository.dart - FIXED VERSION
import 'package:del_pick/data/datasources/remote/order_remote_datasource.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';
import 'package:del_pick/data/models/order/order_list_response.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';

import '../models/menu/create_menu_item_model.dart';
import '../models/order/cart_item_model.dart';
import '../models/order/create_order_request.dart';
import '../models/order/place_order_response.dart';

class OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepository(this._remoteDataSource);

  // ✅ FIXED: Added missing getOrdersByUser method
  Future<Result<OrderListResponse>> getOrdersByUser({
    Map<String, dynamic>? params,
  }) async {
    try {
      final result = await getCustomerOrders(params: params);

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

  // ✅ CORE ORDER METHODS - Backend Compatible

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

  // ✅ GET ORDER DETAIL - Match backend endpoint: GET /orders/:id
  Future<Result<OrderModel>> getOrderDetail(int orderId) async {
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

  // ✅ ALIAS METHOD - For backward compatibility
  Future<Result<OrderModel>> getOrderById(int orderId) async {
    return getOrderDetail(orderId);
  }

  // ✅ GET CUSTOMER ORDERS - Backend: GET /orders/customer
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

  // ✅ GET STORE ORDERS - Backend: GET /orders/store
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

  // ✅ WRAPPER METHOD for getUserOrders (Backward compatibility)
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

  // ✅ PROCESS ORDER - Backend: POST /orders/:id/process with action
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

  // ✅ UPDATE ORDER STATUS - Backend: PATCH /orders/:id/status
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

  // ✅ CREATE ORDER REVIEW - Backend: POST /orders/:id/review
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

  // ✅ CANCEL ORDER METHODS - Backend Compatible

  /// Cancel order with automatic role detection
  /// Backend automatically determines action based on user role:
  /// - Customer: Uses PATCH /orders/:id/status with order_status: 'cancelled'
  /// - Store: Uses POST /orders/:id/process with action: 'reject'
  Future<Result<OrderModel>> cancelOrder(
    int orderId, {
    String? reason,
    String? userRole,
  }) async {
    try {
      // For customer cancellation: update status to cancelled
      if (userRole?.toLowerCase() == 'customer') {
        return cancelOrderByCustomer(orderId, reason: reason);
      }
      // For store cancellation: reject order
      else if (userRole?.toLowerCase() == 'store') {
        return cancelOrderByStore(orderId, reason: reason);
      }
      // Generic cancellation - let backend determine
      else {
        final data = <String, dynamic>{
          'order_status': 'cancelled',
        };

        if (reason != null && reason.isNotEmpty) {
          data['cancellation_reason'] = reason;
        }

        final response =
            await _remoteDataSource.updateOrderStatus(orderId, data);

        if (response.statusCode == 200) {
          final responseData = response.data as Map<String, dynamic>;

          if (responseData.containsKey('data') &&
              responseData['data'] != null) {
            final order = OrderModel.fromJson(
                responseData['data'] as Map<String, dynamic>);
            return Result.success(order);
          } else {
            return Result.failure(
                responseData['message'] ?? 'Failed to cancel order');
          }
        } else {
          return Result.failure(_extractErrorMessage(response));
        }
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Cancel order by Customer - Backend: PATCH /orders/:id/status
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

  /// Cancel order by Store - Backend: POST /orders/:id/process with action: 'reject'
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

  // ✅ STORE SPECIFIC ACTIONS

  /// Approve order by Store - Backend: POST /orders/:id/process with action: 'approve'
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
// lib/data/repositories/order_repository.dart - ADD PLACE ORDER METHOD
// Tambahkan method ini ke dalam class OrderRepository yang sudah ada

// ✅ ADD: Place Order method - Backend Compatible
  Future<Result<PlaceOrderResponse>> placeOrder(
      CreateOrderRequest request) async {
    try {
      final response = await _remoteDataSource.placeOrder(request);
      return Result.success(response);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Failed to place order: ${e.toString()}');
    }
  }

// ✅ CONVENIENCE METHOD: Place order from cart items
  Future<Result<PlaceOrderResponse>> placeOrderFromCart({
    required int storeId,
    required List<CartItemModel> items,
  }) async {
    try {
      final request = CreateOrderRequest.fromCartItems(
        storeId: storeId,
        cartItems: items,
      );

      return await placeOrder(request);
    } catch (e) {
      return Result.failure('Failed to prepare order: ${e.toString()}');
    }
  }
// lib/data/repositories/order_repository.dart - FIXED DRIVER METHODS
// Ganti method driver yang sebelumnya dengan yang ini:

  // ✅ DRIVER SPECIFIC METHODS - Menggunakan Driver Requests sebagai sumber data

  /// Get driver orders from driver requests - Returns Result<List<Map<String, dynamic>>>
  Future<Result<List<Map<String, dynamic>>>> getDriverOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      // Driver orders didapat dari driver requests, bukan dari orders langsung
      // Kita perlu memanggil driver request repository atau endpoint

      // Jika menggunakan driver request endpoint
      final response = await _remoteDataSource.getDriverRequests(
        page: page,
        limit: limit,
        status: status,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          // Extract requests array from the response
          final requests = data['requests'] as List? ?? [];

          // Convert driver requests ke order format untuk compatibility
          final orderMaps = <Map<String, dynamic>>[];

          for (final requestMap in requests) {
            final request = requestMap as Map<String, dynamic>;

            // Extract order data dari driver request
            if (request.containsKey('order') && request['order'] != null) {
              final orderData = request['order'] as Map<String, dynamic>;

              // Tambahkan informasi driver request ke order data
              orderData['driver_request_id'] = request['id'];
              orderData['driver_request_status'] = request['status'];
              orderData['estimated_pickup_time'] =
                  request['estimated_pickup_time'];
              orderData['estimated_delivery_time'] =
                  request['estimated_delivery_time'];

              orderMaps.add(orderData);
            }
          }

          return Result.success(orderMaps);
        } else {
          return Result.failure(
              responseData['message'] ?? 'No driver requests found');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure('Failed to get driver orders: ${e.toString()}');
    }
  }

  /// Get active driver orders from accepted driver requests
  Future<Result<List<Map<String, dynamic>>>> getDriverActiveOrders() async {
    try {
      // Get driver requests dengan status yang active
      final response = await _remoteDataSource.getDriverRequests(
        limit: 100,
        status: 'accepted', // Hanya ambil yang sudah accepted
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          final requests = data['requests'] as List? ?? [];
          final orderMaps = <Map<String, dynamic>>[];

          for (final requestMap in requests) {
            final request = requestMap as Map<String, dynamic>;

            if (request.containsKey('order') && request['order'] != null) {
              final orderData = request['order'] as Map<String, dynamic>;
              final orderStatus = orderData['order_status'] as String?;

              // Filter hanya order yang benar-benar active untuk driver
              if (['preparing', 'ready_for_pickup', 'on_delivery']
                  .contains(orderStatus)) {
                orderData['driver_request_id'] = request['id'];
                orderData['driver_request_status'] = request['status'];
                orderData['estimated_pickup_time'] =
                    request['estimated_pickup_time'];
                orderData['estimated_delivery_time'] =
                    request['estimated_delivery_time'];

                orderMaps.add(orderData);
              }
            }
          }

          return Result.success(orderMaps);
        } else {
          return Result.failure(
              responseData['message'] ?? 'No active orders found');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(
          'Failed to get driver active orders: ${e.toString()}');
    }
  }

  /// Get driver order detail from driver request detail
  Future<Result<OrderModel>> getDriverOrderDetail(int driverRequestId) async {
    try {
      // Get driver request detail yang include order data
      final response =
          await _remoteDataSource.getDriverRequestDetail(driverRequestId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final requestData = responseData['data'] as Map<String, dynamic>;

          // Extract order dari driver request
          if (requestData.containsKey('order') &&
              requestData['order'] != null) {
            final orderData = requestData['order'] as Map<String, dynamic>;

            // Tambahkan informasi driver request
            orderData['driver_request_id'] = requestData['id'];
            orderData['driver_request_status'] = requestData['status'];
            orderData['estimated_pickup_time'] =
                requestData['estimated_pickup_time'];
            orderData['estimated_delivery_time'] =
                requestData['estimated_delivery_time'];

            final order = OrderModel.fromJson(orderData);
            return Result.success(order);
          } else {
            return Result.failure('Order data not found in driver request');
          }
        } else {
          return Result.failure(
              responseData['message'] ?? 'Driver request not found');
        }
      } else {
        return Result.failure(_extractErrorMessage(response));
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(
          'Failed to get driver order detail: ${e.toString()}');
    }
  }

  // ✅ Alias method untuk backward compatibility dengan order ID
  Future<Result<OrderModel>> getDriverOrderDetailByOrderId(int orderId) async {
    try {
      // Fallback ke getOrderDetail untuk order ID
      return await getOrderDetail(orderId);
    } catch (e) {
      return Result.failure('Failed to get order detail: ${e.toString()}');
    }
  }

  /// Get driver earnings dari completed driver requests
  Future<Result<Map<String, dynamic>>> getDriverEarnings({
    String? period,
  }) async {
    try {
      // Get all driver requests untuk calculate earnings
      final result = await getDriverOrders(limit: 1000);

      if (result.isSuccess && result.data != null) {
        final orders = result.data!;

        // Filter completed orders
        final completedOrders = orders.where((orderMap) {
          final status = orderMap['order_status'] as String?;
          final requestStatus = orderMap['driver_request_status'] as String?;
          return status == 'delivered' && requestStatus == 'completed';
        }).toList();

        // Calculate earnings
        double totalEarnings = 0.0;
        int deliveryCount = completedOrders.length;

        for (final orderMap in completedOrders) {
          final deliveryFee = orderMap['delivery_fee'];
          if (deliveryFee != null) {
            totalEarnings +=
                (deliveryFee is num) ? deliveryFee.toDouble() : 0.0;
          }
        }

        final earnings = {
          'total_earnings': totalEarnings,
          'delivery_count': deliveryCount,
          'completed_orders': completedOrders,
          'average_per_delivery':
              deliveryCount > 0 ? totalEarnings / deliveryCount : 0.0,
        };

        return Result.success(earnings);
      } else {
        return Result.failure(result.message ?? 'Failed to get earnings');
      }
    } catch (e) {
      return Result.failure('Failed to get driver earnings: ${e.toString()}');
    }
  }

  /// Get driver statistics dari driver requests
  Future<Result<Map<String, dynamic>>> getDriverStatistics() async {
    try {
      final result = await getDriverOrders(limit: 1000);

      if (result.isSuccess && result.data != null) {
        final orders = result.data!;

        final stats = <String, dynamic>{
          'total_orders': orders.length,
          'pending': orders
              .where((o) => o['driver_request_status'] == 'pending')
              .length,
          'accepted': orders
              .where((o) => o['driver_request_status'] == 'accepted')
              .length,
          'preparing':
              orders.where((o) => o['order_status'] == 'preparing').length,
          'ready_for_pickup': orders
              .where((o) => o['order_status'] == 'ready_for_pickup')
              .length,
          'on_delivery':
              orders.where((o) => o['order_status'] == 'on_delivery').length,
          'delivered':
              orders.where((o) => o['order_status'] == 'delivered').length,
          'completed': orders
              .where((o) => o['driver_request_status'] == 'completed')
              .length,
        };

        return Result.success(stats);
      } else {
        return Result.failure(result.message ?? 'Failed to get statistics');
      }
    } catch (e) {
      return Result.failure('Failed to get driver statistics: ${e.toString()}');
    }
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

  // ✅ TRACKING METHODS - Backend Compatible

  /// Get tracking data - Backend: GET /orders/:id/tracking
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

  /// Start delivery - Backend: POST /orders/:id/tracking/start (Driver only)
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

  /// Complete delivery - Backend: POST /orders/:id/tracking/complete (Driver only)
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

  /// Update driver location - Backend: PUT /orders/:id/tracking/location (Driver only)
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

  /// Get tracking history - Backend: GET /orders/:id/tracking/history
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
