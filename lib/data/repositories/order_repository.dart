// lib/data/repositories/order_repository.dart - FIXED VERSION
import 'package:dio/dio.dart';
import 'package:del_pick/data/providers/order_provider.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class OrderRepository {
  final OrderProvider _orderProvider;

  OrderRepository(this._orderProvider);

  // EXISTING METHODS - JANGAN DIUBAH

  Future<Result<OrderModel>> createOrder(Map<String, dynamic> data) async {
    try {
      print('OrderRepository: Sending createOrder request');
      print('OrderRepository: Data: $data');

      final response = await _orderProvider.createOrder(data);

      print('OrderRepository: Response status: ${response.statusCode}');
      print('OrderRepository: Response data: ${response.data}');

      // ✅ Handle response sesuai backend format
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Backend success response: { "message": "...", "data": {...} }
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['data'] != null) {
          final order =
              OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
          print('OrderRepository: Order created successfully');
          return Result.success(order, responseData['message'] as String?);
        } else {
          print('OrderRepository: Response data is null');
          return Result.failure('Invalid response format');
        }
      } else {
        // Handle non-success status codes
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to create order';
        print('OrderRepository: API error: $message');
        return Result.failure(message);
      }
    } on DioException catch (e) {
      print('OrderRepository: DioException: ${e.message}');
      print('OrderRepository: Response: ${e.response?.data}');

      // ✅ Use ErrorHandler untuk handle DioException
      final failure = ErrorHandler.handleException(e);

      // ✅ Extract user-friendly error message
      String errorMessage = ErrorHandler.getErrorMessage(failure);

      // ✅ Handle backend validation errors specifically
      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;

          // Handle backend validation errors
          if (errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              // Extract first validation error message
              final firstError = errors.first;
              if (firstError is Map<String, dynamic> &&
                  firstError['msg'] != null) {
                errorMessage = firstError['msg'] as String;
              }
            }
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'] as String;
          }
        } catch (parseError) {
          print('OrderRepository: Error parsing error response: $parseError');
          // Keep the default error message from ErrorHandler
        }
      }

      return Result.failure(errorMessage);
    } catch (e) {
      print('OrderRepository: Unexpected error: $e');

      // ✅ Handle unexpected exceptions
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  Future<Result<PaginatedResponse<OrderModel>>> getOrdersByUser({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _orderProvider.getOrdersByUser(params: params);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;

        final orders = (data['orders'] as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();

        final paginatedResponse = PaginatedResponse<OrderModel>(
          // data: orders,
          items: orders,
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          // limit: params?['limit'] ?? 10,
        );

        return Result.success(
            paginatedResponse, responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to fetch orders';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  Future<Result<PaginatedResponse<OrderModel>>> getOrdersByStore({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _orderProvider.getOrdersByStore(params: params);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;

        final orders = (data['orders'] as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();

        final paginatedResponse = PaginatedResponse<OrderModel>(
          items: orders,
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          // limit: params?['limit'] ?? 10,
        );

        return Result.success(
            paginatedResponse, responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to fetch store orders';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  Future<Result<OrderModel>> getOrderDetail(int orderId) async {
    try {
      final response = await _orderProvider.getOrderDetail(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final order =
            OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(order, responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Order not found';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  Future<Result<OrderModel>> updateOrderStatus(
    int orderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _orderProvider.updateOrderStatus(orderId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final order =
            OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(order, responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to update order status';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  Future<Result<OrderModel>> processOrder(
    int orderId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _orderProvider.processOrder(orderId, data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final order =
            OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(order, responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to process order';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  Future<Result<OrderModel>> cancelOrder(int orderId) async {
    try {
      final response = await _orderProvider.cancelOrder(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final order =
            OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(order, responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to cancel order';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

// lib/data/repositories/order_repository.dart - FIXED createReview method
  Future<Result<void>> createReview(
      int orderId, Map<String, dynamic> data) async {
    try {
      final response = await _orderProvider.createReview(orderId, data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(null, responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to create review';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }
  // ========================================================================
  // DRIVER METHODS - FIXED VERSION (menggunakan Response pattern)
  // ========================================================================

  /// Get active orders untuk driver - FILTER dari driver orders
  Future<Result<List<Map<String, dynamic>>>> getDriverActiveOrders() async {
    try {
      print('OrderRepository: Loading driver active orders...');

      // ✅ Get Response object dari provider, bukan Result object
      final response = await _orderProvider.getDriverActiveOrders();

      print(
          'OrderRepository: Driver active orders response status: ${response.statusCode}');
      print(
          'OrderRepository: Driver active orders response data: ${response.data}');

      // ✅ Check response.statusCode, bukan result.isSuccess
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Handle different response formats
        final ordersData = responseData['data']?['orders'] ??
            responseData['orders'] ??
            responseData['data'] ??
            [];

        final orders = (ordersData as List)
            .map((order) => Map<String, dynamic>.from(order))
            .toList();

        print('OrderRepository: Found ${orders.length} active orders');
        return Result.success(orders);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to load active orders';
        print('OrderRepository: API error: $message');
        return Result.failure(message);
      }
    } on DioException catch (e) {
      print(
          'OrderRepository: DioException in getDriverActiveOrders: ${e.message}');
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      print('OrderRepository: Unexpected error in getDriverActiveOrders: $e');
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  /// Get count of active orders untuk driver - CALCULATE dari active orders
  Future<Result<int>> getDriverActiveOrderCount() async {
    try {
      print('OrderRepository: Getting driver active order count...');

      final result = await getDriverActiveOrders();

      if (result.isSuccess) {
        final activeOrders = result.data ?? [];
        final count = activeOrders.length;
        print('OrderRepository: Active order count: $count');
        return Result.success(count);
      } else {
        print(
            'OrderRepository: Failed to get active orders: ${result.errorMessage}');
        return Result.failure(result.errorMessage);
      }
    } catch (e) {
      print('OrderRepository: Error getting active order count: $e');
      return Result.failure('Network error: ${e.toString()}');
    }
  }

  /// Get all driver orders - ENDPOINT: GET /drivers/orders
  Future<Result<List<Map<String, dynamic>>>> getDriverOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      print('OrderRepository: Loading driver orders...');

      // ✅ Get Response object dari provider
      final response = await _orderProvider.getDriverOrders(
        page: page,
        limit: limit,
        status: status,
      );

      print(
          'OrderRepository: Driver orders response status: ${response.statusCode}');

      // ✅ Check response.statusCode
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Handle different response formats
        final ordersData = responseData['data']?['orders'] ??
            responseData['orders'] ??
            responseData['data'] ??
            [];

        final orders = (ordersData as List)
            .map((order) => Map<String, dynamic>.from(order))
            .toList();

        print('OrderRepository: Found ${orders.length} driver orders');
        return Result.success(orders);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to load driver orders';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      print('OrderRepository: DioException in getDriverOrders: ${e.message}');
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      print('OrderRepository: Unexpected error in getDriverOrders: $e');
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  // ========================================================================
  // TRACKING METHODS untuk Driver - SESUAI SWAGGER
  // ========================================================================

  /// Start delivery - ENDPOINT: PUT /tracking/{orderId}/start
  Future<Result<Map<String, dynamic>>> startDelivery(int orderId) async {
    try {
      print('OrderRepository: Starting delivery for order: $orderId');

      // ✅ Get Response object dari provider
      final response = await _orderProvider.startDelivery(orderId);

      print(
          'OrderRepository: Start delivery response status: ${response.statusCode}');

      // ✅ Check response.statusCode
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        print('OrderRepository: Delivery started successfully');
        return Result.success(responseData);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to start delivery';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      print('OrderRepository: DioException in startDelivery: ${e.message}');
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      print('OrderRepository: Unexpected error in startDelivery: $e');
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  /// Complete delivery - ENDPOINT: PUT /tracking/{orderId}/complete
  Future<Result<Map<String, dynamic>>> completeDelivery(int orderId) async {
    try {
      print('OrderRepository: Completing delivery for order: $orderId');

      // ✅ Get Response object dari provider
      final response = await _orderProvider.completeDelivery(orderId);

      print(
          'OrderRepository: Complete delivery response status: ${response.statusCode}');

      // ✅ Check response.statusCode
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        print('OrderRepository: Delivery completed successfully');
        return Result.success(responseData);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to complete delivery';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      print('OrderRepository: DioException in completeDelivery: ${e.message}');
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      print('OrderRepository: Unexpected error in completeDelivery: $e');
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  /// Track order - ENDPOINT: GET /tracking/{orderId}
  Future<Result<Map<String, dynamic>>> trackOrder(int orderId) async {
    try {
      print('OrderRepository: Tracking order: $orderId');

      // ✅ Get Response object dari provider
      final response = await _orderProvider.trackOrder(orderId);

      print(
          'OrderRepository: Track order response status: ${response.statusCode}');

      // ✅ Check response.statusCode
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        print('OrderRepository: Order tracking data retrieved successfully');
        return Result.success(responseData);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to track order';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      print('OrderRepository: DioException in trackOrder: ${e.message}');
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      print('OrderRepository: Unexpected error in trackOrder: $e');
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  /// Get order details untuk driver - Use existing method
  Future<Result<Map<String, dynamic>>> getOrderDetails(String orderId) async {
    try {
      // Convert string to int and use existing method
      final orderIdInt = int.parse(orderId);
      final result = await getOrderDetail(orderIdInt);

      if (result.isSuccess && result.data != null) {
        // Convert OrderModel back to Map for consistency
        final orderMap = result.data!.toJson();
        return Result.success(orderMap);
      } else {
        return Result.failure(result.errorMessage);
      }
    } catch (e) {
      return Result.failure('Failed to get order details: ${e.toString()}');
    }
  }
}
