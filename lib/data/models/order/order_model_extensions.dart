// lib/data/models/order/order_model_extensions.dart - BEST VERSION (Backend Compatible)
import 'package:flutter/material.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:intl/intl.dart';

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
  // bool get isActive => OrderStatusConstants.isActive(orderStatus);
  // bool get isCompleted => OrderStatusConstants.isCompleted(orderStatus);
  // bool get canCancel => OrderStatusConstants.canCancel(orderStatus);
  // bool get canTrack => OrderStatusConstants.canTrack(orderStatus);

  // ✅ Additional action capabilities
  bool get canReview {
    return orderStatus == OrderStatusConstants.delivered;
  }

  bool get canReorder {
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
  double get total => grandTotal; // Alias for compatibility

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
    final estimatedTime = estimatedDeliveryTime!;

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
    final estimatedTime = estimatedDeliveryTime!;

    return now.isAfter(estimatedTime);
  }

  // ✅ Date formatting helpers
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  // String get formattedDate {
  //   return DateFormat('MMM dd, yyyy').format(createdAt);
  // }

  String get formattedOrderDate {
    return DateFormat('MMM dd, yyyy • HH:mm').format(createdAt);
  }

  String get formattedTime {
    return DateFormat('HH:mm').format(createdAt);
  }

  // ✅ Driver information - Backend Compatible
  // bool get hasDriver => driverId != null && driver != null;

  String get driverName {
    return driver?.name ?? 'No Driver Assigned';
  }

  // ✅ Items information - Backend Compatible
  int get itemsCount {
    if (items == null) return 0;
    return items!.fold(0, (sum, item) => sum + item.quantity);
  }

  int get totalItems => itemsCount; // Alias for compatibility

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

  // ✅ Delivery address - Static sesuai backend (destinasi fixed)
  String get deliveryAddress {
    return 'Institut Teknologi Del, Laguboti, Toba, North Sumatra, Indonesia';
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
    return trackingUpdates;
  }

  bool get hasTrackingUpdates {
    return trackingUpdates.isNotEmpty;
  }

  /// Format tanggal pembuatan order
  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt!);
  }

  /// Format tanggal pembuatan order (hanya tanggal)
  String get formattedDateOnly {
    if (createdAt == null) return '';
    return DateFormat('dd MMM yyyy').format(createdAt!);
  }

  /// Format waktu pembuatan order (hanya waktu)
  String get formattedTimeOnly {
    if (createdAt == null) return '';
    return DateFormat('HH:mm').format(createdAt!);
  }

  /// Format estimasi waktu pickup
  String get formattedEstimatedPickupTime {
    if (estimatedPickupTime == null) return '';
    return DateFormat('HH:mm').format(estimatedPickupTime!);
  }

  /// Format estimasi waktu delivery
  String get formattedEstimatedDeliveryTime {
    if (estimatedDeliveryTime == null) return '';
    return DateFormat('HH:mm').format(estimatedDeliveryTime!);
  }

  /// Format waktu pickup aktual
  String get formattedActualPickupTime {
    if (actualPickupTime == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm').format(actualPickupTime!);
  }

  /// Format waktu delivery aktual
  String get formattedActualDeliveryTime {
    if (actualDeliveryTime == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm').format(actualDeliveryTime!);
  }

  /// Cek apakah order bisa di-track
  bool get canTrack {
    if (orderStatus == null) return false;

    final trackableStatuses = [
      OrderStatusConstants.confirmed,
      OrderStatusConstants.preparing,
      OrderStatusConstants.readyForPickup,
      OrderStatusConstants.onDelivery,
    ];

    return trackableStatuses.contains(orderStatus!.toLowerCase());
  }

  /// Cek apakah order masih aktif (belum selesai)
  bool get isActive {
    if (orderStatus == null) return false;

    final activeStatuses = [
      OrderStatusConstants.pending,
      OrderStatusConstants.confirmed,
      OrderStatusConstants.preparing,
      OrderStatusConstants.readyForPickup,
      OrderStatusConstants.onDelivery,
    ];

    return activeStatuses.contains(orderStatus!.toLowerCase());
  }

  // /// Cek apakah order sudah selesai
  // bool get isCompleted {
  //   return orderStatus?.toLowerCase() == OrderStatusConstants.delivered;
  // }
  //
  // /// Cek apakah order dibatalkan
  // bool get isCancelled {
  //   final cancelledStatuses = [
  //     OrderStatusConstants.cancelled,
  //     OrderStatusConstants.rejected,
  //   ];
  //
  //   return cancelledStatuses.contains(orderStatus?.toLowerCase());
  // }

  /// Cek apakah order bisa direview
  // bool get canReview {
  //   return isCompleted && driverId != null;
  // }

  /// Cek apakah order bisa dibatalkan
  bool get canCancel {
    if (orderStatus == null) return false;

    final cancellableStatuses = [
      OrderStatusConstants.pending,
      OrderStatusConstants.confirmed,
    ];

    return cancellableStatuses.contains(orderStatus!.toLowerCase());
  }

  /// Get status display text
  String get statusDisplayText {
    if (orderStatus == null) return 'Unknown';

    switch (orderStatus!.toLowerCase()) {
      case OrderStatusConstants.pending:
        return 'Waiting for confirmation';
      case OrderStatusConstants.confirmed:
        return 'Order confirmed';
      case OrderStatusConstants.preparing:
        return 'Being prepared';
      case OrderStatusConstants.readyForPickup:
        return 'Ready for pickup';
      case OrderStatusConstants.onDelivery:
        return 'On the way';
      case OrderStatusConstants.delivered:
        return 'Delivered';
      case OrderStatusConstants.cancelled:
        return 'Cancelled';
      case OrderStatusConstants.rejected:
        return 'Rejected';
      default:
        return orderStatus!.toUpperCase();
    }
  }

  /// Get next expected status
  String? get nextExpectedStatus {
    if (orderStatus == null) return null;

    switch (orderStatus!.toLowerCase()) {
      case OrderStatusConstants.pending:
        return 'confirmed';
      case OrderStatusConstants.confirmed:
        return 'preparing';
      case OrderStatusConstants.preparing:
        return 'ready_for_pickup';
      case OrderStatusConstants.readyForPickup:
        return 'on_delivery';
      case OrderStatusConstants.onDelivery:
        return 'delivered';
      default:
        return null;
    }
  }

  /// Get estimated time remaining
  // String get estimatedTimeRemaining {
  //   if (estimatedDeliveryTime == null) return '';
  //
  //   final now = DateTime.now();
  //   final difference = estimatedDeliveryTime!.difference(now);
  //
  //   if (difference.isNegative) {
  //     return 'Overdue';
  //   }
  //
  //   if (difference.inHours > 0) {
  //     return '${difference.inHours}h ${difference.inMinutes % 60}m remaining';
  //   } else {
  //     return '${difference.inMinutes}m remaining';
  //   }
  // }

  /// Get order progress percentage (0.0 to 1.0)
  // double get progressPercentage {
  //   if (orderStatus == null) return 0.0;
  //
  //   switch (orderStatus!.toLowerCase()) {
  //     case OrderStatusConstants.pending:
  //       return 0.1;
  //     case OrderStatusConstants.confirmed:
  //       return 0.25;
  //     case OrderStatusConstants.preparing:
  //       return 0.5;
  //     case OrderStatusConstants.readyForPickup:
  //       return 0.75;
  //     case OrderStatusConstants.onDelivery:
  //       return 0.9;
  //     case OrderStatusConstants.delivered:
  //       return 1.0;
  //     default:
  //       return 0.0;
  //   }
  // }

  /// Get total items count
  int get totalItemsCount {
    if (items == null || items!.isEmpty) return 0;
    return items!.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get display price with delivery fee
  double get totalAmountWithDelivery {
    return totalAmount + (deliveryFee ?? 0);
  }

  /// Check if order has driver assigned
  bool get hasDriver {
    return driverId != null;
  }

  /// Check if order has store info
  bool get hasStore {
    return store != null;
  }

  /// Get short order summary
  String get orderSummary {
    final itemCount = totalItemsCount;
    final storeName = store?.name ?? 'Unknown Store';
    return '$itemCount items from $storeName';
  }

  // ✅ Status description for UI
  String get statusDescription {
    switch (orderStatus) {
      case 'pending':
        return 'Your order is being processed';
      case 'confirmed':
        return 'Order confirmed by store';
      case 'preparing':
        return 'Store is preparing your order';
      case 'ready_for_pickup':
        return 'Order ready for pickup';
      case 'on_delivery':
        return 'Driver is delivering your order';
      case 'delivered':
        return 'Order delivered successfully';
      case 'cancelled':
        return 'Order was cancelled';
      case 'rejected':
        return 'Order was rejected by store';
      default:
        return 'Unknown status';
    }
  }

  IconData get statusIcon {
    switch (orderStatus) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready_for_pickup':
        return Icons.shopping_bag;
      case 'on_delivery':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'rejected':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  // ✅ Special getters for customer experience
  bool get isAwaitingStoreApproval => isPending;
  bool get isBeingPrepared => isPreparing;
  bool get isWaitingForDriver => isReadyForPickup;
  bool get isInDelivery => isOnDelivery;
  bool get isSuccessfullyCompleted => isDelivered;
  bool get isFailed => isCancelled || isRejected;

  // ✅ Time estimates
  String? get estimatedPickupTimeFormatted {
    if (estimatedPickupTime == null) return null;
    return DateFormat('HH:mm').format(estimatedPickupTime!);
  }

  String? get estimatedDeliveryTimeFormatted {
    if (estimatedDeliveryTime == null) return null;
    return DateFormat('HH:mm').format(estimatedDeliveryTime!);
  }

  // ✅ Payment status (if needed in future)
  bool get isPaid => true; // Assuming all orders are paid (cash on delivery)

  String get paymentStatus => 'Cash on Delivery';

  // ✅ Order workflow helpers
  bool get requiresStoreAction => isPending;
  bool get requiresDriverAction => isReadyForPickup && !hasDriver;
  bool get requiresCustomerAction => canReview;

  // ✅ Notification helpers
  String get notificationTitle {
    switch (orderStatus) {
      case 'confirmed':
        return 'Order Confirmed';
      case 'preparing':
        return 'Order Being Prepared';
      case 'ready_for_pickup':
        return 'Order Ready';
      case 'on_delivery':
        return 'Order On The Way';
      case 'delivered':
        return 'Order Delivered';
      case 'cancelled':
        return 'Order Cancelled';
      case 'rejected':
        return 'Order Rejected';
      default:
        return 'Order Update';
    }
  }

  String get notificationMessage {
    switch (orderStatus) {
      case 'confirmed':
        return 'Your order has been confirmed by $storeName';
      case 'preparing':
        return '$storeName is preparing your order';
      case 'ready_for_pickup':
        return 'Your order is ready for pickup';
      case 'on_delivery':
        return 'Your order is on the way';
      case 'delivered':
        return 'Your order has been delivered successfully';
      case 'cancelled':
        return 'Your order has been cancelled';
      case 'rejected':
        return 'Your order was rejected by $storeName';
      default:
        return 'Your order status has been updated';
    }
  }
}
