// lib/data/models/order/order_model_extensions.dart
import 'package:flutter/material.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';

extension OrderModelExtensions on OrderModel {
  // ✅ Individual status checking methods - Backend Compatible
  bool get isPending => orderStatus == OrderStatusConstants.pending;
  bool get isConfirmed => orderStatus == OrderStatusConstants.confirmed;
  bool get isPreparing => orderStatus == OrderStatusConstants.preparing;
  bool get isReadyForPickup =>
      orderStatus == OrderStatusConstants.readyForPickup;
  bool get isOnDelivery => orderStatus == OrderStatusConstants.onDelivery;
  bool get isDelivered => orderStatus == OrderStatusConstants.delivered;
  bool get isCancelled => orderStatus == OrderStatusConstants.cancelled;
  bool get isRejected => orderStatus == OrderStatusConstants.rejected;

  // ✅ Helper status methods using constants
  bool get isActive => OrderStatusConstants.isActive(orderStatus);
  bool get isCompleted => OrderStatusConstants.isCompleted(orderStatus);
  bool get canCancel => OrderStatusConstants.canCancel(orderStatus);
  bool get canTrack => OrderStatusConstants.canTrack(orderStatus);

  // ✅ Additional action capabilities
  bool get canReview {
    // Can only review delivered orders
    return orderStatus == OrderStatusConstants.delivered;
  }

  bool get canReorder {
    // Can reorder delivered or cancelled orders
    return orderStatus == OrderStatusConstants.delivered ||
        orderStatus == OrderStatusConstants.cancelled ||
        orderStatus == OrderStatusConstants.rejected;
  }

  // ✅ Status display helpers
  String get statusDisplayName =>
      OrderStatusConstants.getStatusName(orderStatus);
  Color get statusColor => OrderStatusConstants.getStatusColor(orderStatus);

  // ✅ Generate order code dari ID
  String get code => 'ORD${id.toString().padLeft(6, '0')}';

  // ✅ Total calculations - Backend Compatible
  double get grandTotal => totalAmount + deliveryFee;

  String get formattedTotal =>
      'Rp ${grandTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  String get formattedTotalAmount =>
      'Rp ${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  String get formattedDeliveryFee =>
      'Rp ${deliveryFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  // ✅ Store name from relationship
  String get storeName => store?.name ?? 'Unknown Store';

  // ✅ Delivery status helpers - Backend Compatible
  bool get isDeliveryPending => deliveryStatus == 'pending';
  bool get isDeliveryPickedUp => deliveryStatus == 'picked_up';
  bool get isDeliveryOnWay => deliveryStatus == 'on_way';
  bool get isDeliveryDelivered => deliveryStatus == 'delivered';
  bool get isDeliveryRejected => deliveryStatus == 'rejected';

  String get deliveryStatusText {
    switch (deliveryStatus) {
      case 'pending':
        return 'Waiting for Driver';
      case 'picked_up':
        return 'Driver Assigned';
      case 'on_way':
        return 'On the Way';
      case 'delivered':
        return 'Delivered';
      case 'rejected':
        return 'Delivery Rejected';
      default:
        return 'Unknown';
    }
  }

  // ✅ Timing helpers - Backend Compatible
  String? get estimatedTimeRemaining {
    if (estimatedDeliveryTime == null) return null;

    final now = DateTime.now();
    final estimatedTime = DateTime.parse(estimatedDeliveryTime!);

    if (estimatedTime.isBefore(now)) {
      return 'Overdue';
    }

    final difference = estimatedTime.difference(now);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m remaining';
    } else {
      return '${difference.inMinutes}m remaining';
    }
  }

  bool get isLate {
    if (estimatedDeliveryTime == null || isDelivered) {
      return false;
    }

    final now = DateTime.now();
    final estimatedTime = DateTime.parse(estimatedDeliveryTime!);

    return now.isAfter(estimatedTime);
  }

  String get formattedCreatedAt {
    final date = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // ✅ Driver information - Backend Compatible
  bool get hasDriver => driverId != null;
  String get driverName => driver?.user?.name ?? 'No Driver Assigned';

  // ✅ Items information - Backend Compatible
  int get itemsCount {
    if (items == null) return 0;
    return items!.fold(0, (sum, item) => sum + item.quantity);
  }

  String get itemsSummary {
    if (items == null || items!.isEmpty) return 'No items';

    if (items!.length == 1) {
      final item = items!.first;
      return '${item.quantity}x ${item.name}';
    } else {
      final totalItems = itemsCount;
      return '$totalItems items from ${items!.length} products';
    }
  }

  // ✅ Priority and attention helpers
  String get priorityLevel {
    if (isLate) return 'high';
    if (isActive && hasDriver) return 'medium';
    return 'normal';
  }

  bool get needsAttention {
    return isLate || isRejected;
  }

  String? get attentionMessage {
    if (isRejected) {
      return 'Order was rejected by the store';
    }
    if (isLate) {
      return 'Order is running late';
    }
    return null;
  }

  // ✅ Progress tracking
  double get progressPercentage {
    switch (orderStatus) {
      case 'pending':
        return 0.1;
      case 'confirmed':
        return 0.3;
      case 'preparing':
        return 0.5;
      case 'ready_for_pickup':
        return 0.7;
      case 'on_delivery':
        return 0.9;
      case 'delivered':
        return 1.0;
      case 'cancelled':
      case 'rejected':
        return 0.0;
      default:
        return 0.0;
    }
  }

  // ✅ Available actions for UI
  List<String> get availableActions {
    final actions = <String>[];

    if (canTrack) actions.add('track');
    if (canCancel) actions.add('cancel');
    if (canReview) actions.add('review');
    if (canReorder) actions.add('reorder');

    // Always allow viewing details
    actions.add('view_details');

    return actions;
  }

  // ✅ Tracking updates helper - Backend Compatible
  List<Map<String, dynamic>> get formattedTrackingUpdates {
    if (trackingUpdates == null) return [];

    return trackingUpdates!.map((update) {
      if (update is Map<String, dynamic>) {
        return Map<String, dynamic>.from(update);
      }
      return <String, dynamic>{};
    }).toList();
  }

  bool get hasTrackingUpdates {
    return trackingUpdates != null && trackingUpdates!.isNotEmpty;
  }
}

// // lib/data/models/order/order_model_extensions.dart - NEW FILE
// import 'package:flutter/material.dart';
// import 'package:del_pick/data/models/order/order_model.dart';
// import 'package:del_pick/core/constants/order_status_constants.dart';
//
// extension OrderModelExtensions on OrderModel {
//   // ✅ Status checking methods
//   bool get isPending => orderStatus == OrderStatusConstants.pending;
//   bool get isConfirmed => orderStatus == OrderStatusConstants.confirmed;
//   bool get isPreparing => orderStatus == OrderStatusConstants.preparing;
//   bool get isReadyForPickup =>
//       orderStatus == OrderStatusConstants.readyForPickup;
//   bool get isOnDelivery => orderStatus == OrderStatusConstants.onDelivery;
//   bool get isDelivered => orderStatus == OrderStatusConstants.delivered;
//   bool get isCancelled => orderStatus == OrderStatusConstants.cancelled;
//   bool get isRejected => orderStatus == OrderStatusConstants.rejected;
//
//   // Helper methods
//   bool get isActive => OrderStatusConstants.isActive(orderStatus);
//   bool get isCompleted => OrderStatusConstants.isCompleted(orderStatus);
//   bool get canCancel => OrderStatusConstants.canCancel(orderStatus);
//   bool get canTrack => OrderStatusConstants.canTrack(orderStatus);
//
//   String get statusDisplayName =>
//       OrderStatusConstants.getStatusName(orderStatus);
//   Color get statusColor => OrderStatusConstants.getStatusColor(orderStatus);
//
//   // ✅ Generate order code dari ID
//   String get code => 'ORD${id.toString().padLeft(6, '0')}';
//
//   // ✅ Total calculations
//   double get total => totalAmount + deliveryFee;
//   String get formattedTotal =>
//       'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
//
//   // Store name from relationship
//   String get storeName => store?.name ?? 'Unknown Store';
// }
