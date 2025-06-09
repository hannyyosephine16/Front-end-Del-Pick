// lib/data/models/order/order_model_extensions.dart
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:intl/intl.dart';

extension OrderModelExtensions on OrderModel {
  // Formatted total amount
  String get formattedTotal {
    return 'Rp ${NumberFormat('#,###').format(total)}';
  }

  // Formatted date
  String get formattedDate {
    return DateFormat('dd MMM yyyy, HH:mm').format(orderDate);
  }

  // Total items count
  int get totalItems {
    return items?.fold(0, (sum, item) => sum! + item.quantity) ?? 0;
  }

  // Store name from store object or fallback
  String get storeName {
    return store?.name ?? 'Unknown Store';
  }

  // Status display name
  String get statusDisplayName {
    switch (orderStatus) {
      case OrderStatusConstants.pending:
        return 'Pending';
      case OrderStatusConstants.preparing:
        return 'Preparing';
      case OrderStatusConstants.onDelivery:
        return 'On Delivery';
      case OrderStatusConstants.delivered:
        return 'Delivered';
      case OrderStatusConstants.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Can track order
  bool get canTrack {
    return orderStatus == OrderStatusConstants.preparing ||
        orderStatus == OrderStatusConstants.onDelivery;
  }

  // Can review order
  bool get canReview {
    return orderStatus == OrderStatusConstants.delivered;
  }

  // Can cancel order
  bool get canCancel {
    return orderStatus == OrderStatusConstants.pending ||
        orderStatus == OrderStatusConstants.preparing;
  }

  // Order status checks
  bool get isPending => orderStatus == OrderStatusConstants.pending;
  bool get isPreparing => orderStatus == OrderStatusConstants.preparing;
  bool get isOnDelivery => orderStatus == OrderStatusConstants.onDelivery;
  bool get isDelivered => orderStatus == OrderStatusConstants.delivered;
  bool get isCancelled => orderStatus == OrderStatusConstants.cancelled;

  // Delivery address
  String get deliveryAddress {
    return deliveryAddress ?? 'Institut Teknologi Del';
  }
}

// Extension for order items
extension OrderItemExtensions on OrderItem {
  String get formattedPrice {
    return 'Rp ${NumberFormat('#,###').format(price)}';
  }
}
