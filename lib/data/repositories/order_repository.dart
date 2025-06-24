import 'package:del_pick/data/datasources/remote/order_remote_datasource.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';

class OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepository(this._remoteDataSource);

  Future<Result<OrderModel>> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _remoteDataSource.createOrder(data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final order =
            OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(order);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to create order');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

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
        final paginatedResponse = PaginatedResponse.fromResponse(
          response,
          (json) => OrderModel.fromJson(json),
        );
        return Result.success(paginatedResponse);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to fetch orders');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

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
        final paginatedResponse = PaginatedResponse.fromResponse(
          response,
          (json) => OrderModel.fromJson(json),
        );
        return Result.success(paginatedResponse);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to fetch store orders');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<OrderModel>> getOrderById(int orderId) async {
    try {
      final response = await _remoteDataSource.getOrderById(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final order =
            OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(order);
      } else {
        return Result.failure(response.data['message'] ?? 'Order not found');
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
        final order =
            OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(order);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to process order');
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
        final order =
            OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(order);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to update order status');
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
        return Result.failure(
            response.data['message'] ?? 'Failed to create review');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // Tracking methods
  Future<Result<Map<String, dynamic>>> getTrackingData(int orderId) async {
    try {
      final response = await _remoteDataSource.getTrackingData(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData['data'] as Map<String, dynamic>);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to get tracking data');
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
        return Result.success(responseData['data'] as Map<String, dynamic>);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to start delivery');
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
        return Result.success(responseData['data'] as Map<String, dynamic>);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to complete delivery');
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
        return Result.failure(
            response.data['message'] ?? 'Failed to update driver location');
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
        return Result.success(responseData['data'] as Map<String, dynamic>);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to get tracking history');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  String _handleDioError(DioException e) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      return response!.data['message'] ?? 'Network error occurred';
    }
    return 'Network error occurred';
  }
}
