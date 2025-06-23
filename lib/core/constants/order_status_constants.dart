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
  static const String pickedUp = 'picked_up';
  static const String onWay = 'on_way';
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
  static String getStatusName(String status) => statusNames[status] ?? status;
  static Color getStatusColor(String status) =>
      statusColors[status] ?? AppColors.textSecondary;

  static bool isActive(String status) => activeStatuses.contains(status);
  static bool isCompleted(String status) => completedStatuses.contains(status);
  static bool isCancelled(String status) => cancelledStatuses.contains(status);
  static bool canCancel(String status) => [pending, confirmed].contains(status);
  static bool canTrack(String status) =>
      [preparing, readyForPickup, onDelivery].contains(status);
}
