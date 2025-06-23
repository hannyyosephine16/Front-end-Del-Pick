// lib/data/models/order/order_model_extensions.dart - FIXED
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/order/order_item_model.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

extension OrderModelExtensions on OrderModel {
  String get formattedTotalAmount {
    return 'Rp ${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get storeName => store?.name ?? 'Unknown Store';
  String get customerName => customer?.name ?? 'Unknown Customer';
  String get driverName => driver?.name ?? 'No Driver';

  int get totalItems =>
      items?.fold(0, (sum, item) => sum! + item.quantity) ?? 0;

  // Formatted date - Fixed to use existing property
  String get formattedDate {
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
  }

  // Store name from store object or fallback
  // String get storeName {
  //   return store?.name ?? 'Unknown Store';
  // }

  // Status display name
  String get statusDisplayName {
    switch (orderStatus) {
      case AppConstants.orderPending:
        return 'Pending';
      case AppConstants.orderConfirmed:
        return 'Confirmed';
      case AppConstants.orderPreparing:
        return 'Preparing';
      case AppConstants.orderReadyForPickup:
        return 'Ready for Pickup';
      case AppConstants.orderOnDelivery:
        return 'On Delivery';
      case AppConstants.orderDelivered:
        return 'Delivered';
      case AppConstants.orderCancelled:
        return 'Cancelled';
      case AppConstants.orderRejected:
        return 'Reject';
      default:
        return 'Unknown';
    }
  }

  // Can track order
  bool get canTrack {
    return orderStatus == AppConstants.orderPreparing ||
        orderStatus == AppConstants.orderOnDelivery;
  }

  // Can review order
  bool get canReview {
    return orderStatus == AppConstants.orderDelivered;
  }

  // Can cancel order
  bool get canCancel {
    return orderStatus == AppConstants.orderPending ||
        orderStatus == AppConstants.orderPreparing;
  }

  // Order status checks
  bool get isPending => orderStatus == AppConstants.orderPending;
  bool get isConfirmed => orderStatus == AppConstants.orderConfirmed;
  bool get isPreparing => orderStatus == AppConstants.orderPreparing;
  bool get isReadyForPickup => orderStatus == AppConstants.orderReadyForPickup;
  bool get isOnDelivery => orderStatus == AppConstants.orderOnDelivery;
  bool get isDelivered => orderStatus == AppConstants.orderDelivered;
  bool get isCancelled => orderStatus == AppConstants.orderCancelled;
  bool get isRejected => orderStatus == AppConstants.orderRejected;
}

// Extension for order items - Fixed to use OrderItemModel
extension OrderItemModelExtensions on OrderItemModel {
  String get formattedPrice {
    return 'Rp ${NumberFormat('#,###').format(price)}';
  }
}
