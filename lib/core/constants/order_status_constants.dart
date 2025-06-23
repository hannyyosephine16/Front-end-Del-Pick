// lib/core/constants/order_status_constants.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';

class OrderStatusConstants {
  // ✅ SESUAI BACKEND: Order Status Values
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String preparing = 'preparing';
  static const String readyForPickup = 'ready_for_pickup';
  static const String onDelivery = 'on_delivery';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
  static const String rejected = 'rejected';

  // ✅ SESUAI BACKEND: Delivery Status Values
  static const String deliveryPending = 'pending';
  static const String deliveryPickedUp = 'picked_up';
  static const String deliveryOnWay = 'on_way';
  static const String deliveryDelivered = 'delivered';
  static const String deliveryRejected = 'rejected';

  // Status lists
  static const List<String> allOrderStatuses = [
    pending,
    confirmed,
    preparing,
    readyForPickup,
    onDelivery,
    delivered,
    cancelled,
    rejected
  ];

  static const List<String> activeStatuses = [
    pending,
    confirmed,
    preparing,
    readyForPickup,
    onDelivery
  ];

  static const List<String> completedStatuses = [delivered];
  static const List<String> cancelledStatuses = [cancelled, rejected];

  static const List<String> trackableStatuses = [
    confirmed,
    preparing,
    readyForPickup,
    onDelivery,
  ];

  static const List<String> cancellableStatuses = [
    pending,
    confirmed,
  ];

  static const List<String> reviewableStatuses = [
    delivered,
  ];

  static const List<String> reorderableStatuses = [
    delivered,
    cancelled,
    rejected,
  ];

  // Status display names
  static const Map<String, String> statusNames = {
    pending: 'Pending',
    confirmed: 'Confirmed',
    preparing: 'Preparing',
    readyForPickup: 'Ready for Pickup',
    onDelivery: 'On Delivery',
    delivered: 'Delivered',
    cancelled: 'Cancelled',
    rejected: 'Rejected',
  };

  // Status colors
  static const Map<String, Color> statusColors = {
    pending: AppColors.warning,
    confirmed: AppColors.info,
    preparing: AppColors.warning,
    readyForPickup: AppColors.success,
    onDelivery: AppColors.primary,
    delivered: AppColors.success,
    cancelled: AppColors.error,
    rejected: AppColors.error,
  };

  // Helper methods
  // static String getStatusName(String status) => statusNames[status] ?? status;
  // static Color getStatusColor(String status) =>
  // statusColors[status] ?? AppColors.textSecondary;

  static bool isActive(String status) => activeStatuses.contains(status);
  static bool isCompleted(String status) => completedStatuses.contains(status);
  static bool isCancelled(String status) => cancelledStatuses.contains(status);
  static bool canTrack(String status) => trackableStatuses.contains(status);
  static bool canCancel(String status) => cancellableStatuses.contains(status);
  static bool canReview(String status) => reviewableStatuses.contains(status);
  static bool canReorder(String status) => reorderableStatuses.contains(status);

  static String getStatusName(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case confirmed:
        return 'Confirmed';
      case preparing:
        return 'Preparing';
      case readyForPickup:
        return 'Ready for Pickup';
      case onDelivery:
        return 'On Delivery';
      case delivered:
        return 'Delivered';
      case cancelled:
        return 'Cancelled';
      case rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  // ✅ Status colors
  static Color getStatusColor(String status) {
    switch (status) {
      case pending:
        return const Color(0xFFFFA726); // Orange
      case confirmed:
        return const Color(0xFF42A5F5); // Blue
      case preparing:
        return const Color(0xFFFF7043); // Deep Orange
      case readyForPickup:
        return const Color(0xFFAB47BC); // Purple
      case onDelivery:
        return const Color(0xFF5C6BC0); // Indigo
      case delivered:
        return const Color(0xFF66BB6A); // Green
      case cancelled:
      case rejected:
        return const Color(0xFFEF5350); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Status icons
  static IconData getStatusIcon(String status) {
    switch (status) {
      case pending:
        return Icons.schedule;
      case confirmed:
        return Icons.check_circle_outline;
      case preparing:
        return Icons.restaurant;
      case readyForPickup:
        return Icons.shopping_bag_outlined;
      case onDelivery:
        return Icons.delivery_dining;
      case delivered:
        return Icons.check_circle;
      case cancelled:
        return Icons.cancel_outlined;
      case rejected:
        return Icons.close;
      default:
        return Icons.help_outline;
    }
  }

  // ✅ Delivery status display names
  static String getDeliveryStatusName(String status) {
    switch (status) {
      case deliveryPending:
        return 'Waiting for Driver';
      case deliveryPickedUp:
        return 'Driver Assigned';
      case deliveryOnWay:
        return 'On the Way';
      case deliveryDelivered:
        return 'Delivered';
      case deliveryRejected:
        return 'Delivery Rejected';
      default:
        return 'Unknown';
    }
  }

  // ✅ Get next status in workflow
  static String? getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case pending:
        return confirmed;
      case confirmed:
        return preparing;
      case preparing:
        return readyForPickup;
      case readyForPickup:
        return onDelivery;
      case onDelivery:
        return delivered;
      default:
        return null; // No next status (terminal state)
    }
  }

  // ✅ Get previous status in workflow
  static String? getPreviousStatus(String currentStatus) {
    switch (currentStatus) {
      case confirmed:
        return pending;
      case preparing:
        return confirmed;
      case readyForPickup:
        return preparing;
      case onDelivery:
        return readyForPickup;
      case delivered:
        return onDelivery;
      default:
        return null; // No previous status
    }
  }

  // ✅ Check if status transition is valid
  static bool isValidTransition(String fromStatus, String toStatus) {
    if (fromStatus == toStatus) return true;

    // Allow cancellation from certain statuses
    if (toStatus == cancelled && cancellableStatuses.contains(fromStatus)) {
      return true;
    }

    // Allow rejection at any time (store can reject)
    if (toStatus == rejected) {
      return true;
    }

    // Check normal workflow progression
    return getNextStatus(fromStatus) == toStatus;
  }

  // ✅ Get all possible actions for a status
  static List<String> getAvailableActions(String status) {
    final actions = <String>[];

    if (canTrack(status)) actions.add('track');
    if (canCancel(status)) actions.add('cancel');
    if (canReview(status)) actions.add('review');
    if (canReorder(status)) actions.add('reorder');

    // Always allow viewing details
    actions.add('view_details');

    return actions;
  }

  // ✅ Get status priority for sorting
  static int getStatusPriority(String status) {
    switch (status) {
      case onDelivery:
        return 1; // Highest priority
      case readyForPickup:
        return 2;
      case preparing:
        return 3;
      case confirmed:
        return 4;
      case pending:
        return 5;
      case delivered:
        return 6;
      case cancelled:
        return 7;
      case rejected:
        return 8; // Lowest priority
      default:
        return 9;
    }
  }

  // ✅ Check if status requires attention
  static bool needsAttention(String status) {
    return status == rejected;
  }

  // ✅ Get attention message for status
  static String? getAttentionMessage(String status) {
    switch (status) {
      case rejected:
        return 'Order was rejected by the store';
      default:
        return null;
    }
  }
}
