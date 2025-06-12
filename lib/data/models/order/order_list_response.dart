// lib/data/models/order/order_list_response.dart
import 'order_model.dart';

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
