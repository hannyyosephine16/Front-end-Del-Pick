// lib/data/services/api/order_api_service.dart
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/order/order_list_response.dart';

class OrderApiService extends ApiService {
  @override
  String get endpoint => '/orders';

  // ✅ FIXED: Place order dengan format yang sesuai backend API
  Future<OrderModel> placeOrder({
    required int storeId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // ✅ Format data sesuai backend API schema
      final requestData = {
        'store_id': storeId,
        'items':
            items, // items sudah dalam format toApiJson() dari CartItemModel
      };

      final response = await post(endpoint, data: requestData);

      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Failed to place order',
        );
      }
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  // Get customer orders
  Future<OrderListResponse> getCustomerOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await get(
        '$endpoint/customer',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return OrderListResponse.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Failed to get orders',
        );
      }
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  // Get order by ID
  Future<OrderModel> getOrderById(int orderId) async {
    try {
      final response = await get('$endpoint/$orderId');

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Order not found',
        );
      }
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  // Cancel order
  Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await delete('$endpoint/$orderId');
      return response.statusCode == 200;
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  // Create review for order
  Future<bool> createReview({
    required int orderId,
    required Map<String, dynamic> orderReview,
    required Map<String, dynamic> driverReview,
  }) async {
    try {
      final requestData = {
        'order_review': orderReview,
        'driver_review': driverReview,
      };

      final response =
          await post('$endpoint/$orderId/review', data: requestData);
      return response.statusCode == 201;
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  // Get tracking data
  Future<Map<String, dynamic>> getTrackingData(int orderId) async {
    try {
      final response = await get('$endpoint/$orderId/tracking');

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Failed to get tracking data',
        );
      }
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  // Get tracking history
  Future<Map<String, dynamic>> getTrackingHistory(int orderId) async {
    try {
      final response = await get('$endpoint/$orderId/tracking/history');

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Failed to get tracking history',
        );
      }
    } catch (e) {
      throw _handleApiError(e);
    }
  }

  // Handle API errors
  Exception _handleApiError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
              'Connection timeout. Please check your internet connection.');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message =
              error.response?.data['message'] ?? 'Server error occurred';

          switch (statusCode) {
            case 400:
              return Exception('Bad request: $message');
            case 401:
              return Exception('Unauthorized. Please login again.');
            case 403:
              return Exception('Access forbidden: $message');
            case 404:
              return Exception('Resource not found: $message');
            case 500:
              return Exception('Server error: $message');
            default:
              return Exception('Error: $message');
          }

        case DioExceptionType.cancel:
          return Exception('Request was cancelled');

        case DioExceptionType.unknown:
        default:
          return Exception(
              'Network error occurred. Please check your connection.');
      }
    }

    return Exception('Unexpected error occurred: ${error.toString()}');
  }
}
// // lib/core/services/api/order_service.dart
// import 'package:dio/dio.dart';
// import 'package:del_pick/core/services/api/api_service.dart';
// import 'package:del_pick/core/constants/api_endpoints.dart';
//
// class OrderApiService {
//   final ApiService _apiService;
//
//   OrderApiService(this._apiService);
//
//   // ✅ FIXED: Create order - sesuai backend POST /orders
//   Future<Response> createOrder(Map<String, dynamic> data) async {
//     return await _apiService.post(ApiEndpoints.createOrder, data: data);
//   }
//
//   // ✅ FIXED: Get customer orders - sesuai backend GET /orders/customer
//   Future<Response> getCustomerOrders(
//       {Map<String, dynamic>? queryParams}) async {
//     return await _apiService.get(
//       ApiEndpoints.customerOrders,
//       queryParameters: queryParams,
//     );
//   }
//
//   // ✅ FIXED: Get store orders - sesuai backend GET /orders/store
//   Future<Response> getStoreOrders({Map<String, dynamic>? queryParams}) async {
//     return await _apiService.get(
//       ApiEndpoints.storeOrders,
//       queryParameters: queryParams,
//     );
//   }
//
//   // ✅ FIXED: Get order detail - sesuai backend GET /orders/:id
//   Future<Response> getOrderDetail(int orderId) async {
//     return await _apiService.get(ApiEndpoints.getOrderById(orderId));
//   }
//
//   // ✅ FIXED: Update order status - sesuai backend PATCH /orders/:id/status
//   Future<Response> updateOrderStatus(
//       int orderId, Map<String, dynamic> data) async {
//     return await _apiService.patch(
//       ApiEndpoints.updateOrderStatus(orderId),
//       data: data,
//     );
//   }
//
//   // ✅ FIXED: Process order by store - sesuai backend POST /orders/:id/process
//   Future<Response> processOrder(int orderId, Map<String, dynamic> data) async {
//     return await _apiService.post(
//       ApiEndpoints.processOrder(orderId),
//       data: data,
//     );
//   }
//
//   // ✅ REMOVED: Cancel order - backend tidak ada endpoint khusus cancel
//   // Gunakan updateOrderStatus dengan status 'cancelled'
//
//   // ✅ FIXED: Create review - sesuai backend POST /orders/:id/review
//   Future<Response> createReview(int orderId, Map<String, dynamic> data) async {
//     return await _apiService.post(
//       ApiEndpoints.createOrderReview(orderId),
//       data: data,
//     );
//   }
//
//   // ✅ ADDED: Tracking endpoints sesuai backend
//   Future<Response> getOrderTracking(int orderId) async {
//     return await _apiService.get(ApiEndpoints.getOrderTracking(orderId));
//   }
//
//   Future<Response> startDelivery(int orderId) async {
//     return await _apiService.post(ApiEndpoints.startDelivery(orderId));
//   }
//
//   Future<Response> completeDelivery(int orderId) async {
//     return await _apiService.post(ApiEndpoints.completeDelivery(orderId));
//   }
//
//   Future<Response> updateDriverLocation(
//       int orderId, Map<String, dynamic> data) async {
//     return await _apiService.put(
//       ApiEndpoints.updateTrackingDriverLocation(orderId),
//       data: data,
//     );
//   }
//
//   Future<Response> getTrackingHistory(int orderId) async {
//     return await _apiService.get(ApiEndpoints.getTrackingHistory(orderId));
//   }
// }
