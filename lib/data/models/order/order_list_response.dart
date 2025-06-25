// lib/data/models/order/order_list_response.dart
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';

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

  // ✅ Add items getter for compatibility
  List<OrderModel> get items => orders;

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    List<OrderModel> ordersList = [];

    // Handle different response structures from backend
    if (json['data'] != null) {
      final data = json['data'];

      if (data is Map<String, dynamic>) {
        // Case 1: { data: { orders: [...], totalItems: ..., totalPages: ..., currentPage: ... } }
        if (data['orders'] != null && data['orders'] is List) {
          final ordersData = data['orders'] as List;
          ordersList = ordersData
              .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        // Case 2: data is a Map but orders might be under different key
        else {
          // Look for any List in the data that could be orders
          for (final key in data.keys) {
            if (data[key] is List) {
              final listData = data[key] as List;
              ordersList = listData
                  .map((item) =>
                      OrderModel.fromJson(item as Map<String, dynamic>))
                  .toList();
              break;
            }
          }
        }
      }
      // Case 3: { data: [...] } - Direct array at data level
      else if (data is List) {
        ordersList = data
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    // Extract pagination info with safe parsing
    int totalItems = 0;
    int totalPages = 1;
    int currentPage = 1;

    if (json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      totalItems = ParsingHelper.parseIntWithDefault(
          data['totalItems'], ordersList.length);
      totalPages = ParsingHelper.parseIntWithDefault(data['totalPages'], 1);
      currentPage = ParsingHelper.parseIntWithDefault(data['currentPage'], 1);
    } else {
      // Fallback to root level or use orders length
      totalItems = ParsingHelper.parseIntWithDefault(
          json['totalItems'], ordersList.length);
      totalPages = ParsingHelper.parseIntWithDefault(json['totalPages'], 1);
      currentPage = ParsingHelper.parseIntWithDefault(json['currentPage'], 1);
    }

    return OrderListResponse(
      orders: ordersList,
      totalItems: totalItems,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  // Factory method for creating from direct list
  factory OrderListResponse.fromList(
    List<OrderModel> orders, {
    int? totalItems,
    int? totalPages,
    int? currentPage,
  }) {
    return OrderListResponse(
      orders: orders,
      totalItems: totalItems ?? orders.length,
      totalPages: totalPages ?? 1,
      currentPage: currentPage ?? 1,
    );
  }

  // Factory method for empty response
  factory OrderListResponse.empty() {
    return OrderListResponse(
      orders: [],
      totalItems: 0,
      totalPages: 0,
      currentPage: 1,
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

  // Helper getters
  bool get hasOrders => orders.isNotEmpty;
  bool get isEmpty => orders.isEmpty;
  bool get isNotEmpty => orders.isNotEmpty;
  int get length => orders.length;
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  // Pagination helpers
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage >= totalPages;
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;

  @override
  String toString() {
    return 'OrderListResponse(orders: ${orders.length}, total: $totalItems, page: $currentPage/$totalPages)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderListResponse &&
          runtimeType == other.runtimeType &&
          orders == other.orders &&
          totalItems == other.totalItems &&
          totalPages == other.totalPages &&
          currentPage == other.currentPage;

  @override
  int get hashCode =>
      orders.hashCode ^
      totalItems.hashCode ^
      totalPages.hashCode ^
      currentPage.hashCode;
}
// // lib/data/models/order/order_list_response.dart
// import 'order_model.dart';
//
// class OrderListResponse {
//   final List<OrderModel> orders;
//   final int totalItems;
//   final int totalPages;
//   final int currentPage;
//
//   OrderListResponse({
//     required this.orders,
//     required this.totalItems,
//     required this.totalPages,
//     required this.currentPage,
//   });
//
//   factory OrderListResponse.fromJson(Map<String, dynamic> json) {
//     return OrderListResponse(
//       orders: (json['orders'] as List)
//           .map((orderJson) => OrderModel.fromJson(orderJson))
//           .toList(),
//       totalItems: json['totalItems'] ?? 0,
//       totalPages: json['totalPages'] ?? 0,
//       currentPage: json['currentPage'] ?? 1,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'orders': orders.map((order) => order.toJson()).toList(),
//       'totalItems': totalItems,
//       'totalPages': totalPages,
//       'currentPage': currentPage,
//     };
//   }
// }
