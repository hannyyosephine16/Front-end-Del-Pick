// lib/data/repositories/order_repository.dart - CORRECTED VERSION

import 'package:dio/dio.dart';
import 'package:del_pick/data/providers/order_provider.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class OrderRepository {
  final OrderProvider _orderProvider;

  OrderRepository(this._orderProvider);

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
          data: orders,
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          limit: params?['limit'] ?? 10,
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
          data: orders,
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          limit: params?['limit'] ?? 10,
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
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _orderProvider.updateOrderStatus(data);

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

  Future<Result<void>> createReview(Map<String, dynamic> data) async {
    try {
      final response = await _orderProvider.createReview(data);

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
}
