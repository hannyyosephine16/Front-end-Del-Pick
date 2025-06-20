import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';

class OrderStatusConstants {
  // Order status values
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String preparing = 'preparing';
  static const String onDelivery = 'on_delivery';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  // Delivery status values
  static const String waiting = 'waiting';
  static const String pickingUp = 'picking_up';
  // static const String onDelivery = 'on_delivery';
  static const String deliveryDelivered = 'delivered';

  // Status lists
  static const List<String> allOrderStatuses = [
    pending,
    approved,
    preparing,
    onDelivery,
    delivered,
    cancelled,
  ];

  static const List<String> allDeliveryStatuses = [
    waiting,
    pickingUp,
    onDelivery,
    delivered,
  ];
  // Helper methods
  static bool isActiveStatus(String status) {
    return [pending, approved, preparing, onDelivery].contains(status);
  }

  static bool isCompletedStatus(String status) {
    return status == delivered;
  }

  static bool isCancelledStatus(String status) {
    return status == cancelled;
  }

  static bool canTrack(String status) {
    return [preparing, onDelivery].contains(status);
  }

  static bool canCancel(String status) {
    return [pending, approved, preparing].contains(status);
  }

  static bool canReview(String status) {
    return status == delivered;
  }

  static const List<String> activeOrderStatuses = [
    pending,
    approved,
    preparing,
    onDelivery,
  ];

  static const List<String> completedOrderStatuses = [delivered, cancelled];

  static const List<String> cancellableStatuses = [pending, approved];

  // Status display names
  // Status display names
  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case approved:
        return 'Approved';
      case preparing:
        return 'Preparing';
      case onDelivery:
        return 'On Delivery';
      case delivered:
        return 'Delivered';
      case cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Status colors (for UI)
  static String getStatusColor(String status) {
    switch (status) {
      case pending:
      case approved:
        return 'warning';
      case preparing:
        return 'info';
      case onDelivery:
        return 'secondary';
      case delivered:
        return 'success';
      case cancelled:
        return 'error';
      default:
        return 'default';
    }
  }

  static const Map<String, String> orderStatusNames = {
    pending: 'Menunggu Konfirmasi',
    approved: 'Dikonfirmasi',
    preparing: 'Sedang Disiapkan',
    onDelivery: 'Dalam Pengiriman',
    delivered: 'Selesai',
    cancelled: 'Dibatalkan',
  };

  static const Map<String, String> deliveryStatusNames = {
    waiting: 'Menunggu Driver',
    pickingUp: 'Driver Menuju Toko',
    onDelivery: 'Dalam Perjalanan',
    delivered: 'Terkirim',
  };

  // Status descriptions
  static const Map<String, String> orderStatusDescriptions = {
    pending: 'Pesanan Anda sedang menunggu konfirmasi dari toko',
    approved: 'Pesanan telah dikonfirmasi dan sedang mencari driver',
    preparing: 'Toko sedang menyiapkan pesanan Anda',
    onDelivery: 'Driver sedang mengirimkan pesanan Anda',
    delivered: 'Pesanan telah berhasil dikirimkan',
    cancelled: 'Pesanan telah dibatalkan',
  };

  static const Map<String, String> deliveryStatusDescriptions = {
    waiting: 'Sedang mencari driver untuk mengantarkan pesanan Anda',
    pickingUp: 'Driver sedang menuju ke toko untuk mengambil pesanan',
    onDelivery: 'Driver sedang dalam perjalanan menuju alamat pengiriman',
    delivered: 'Pesanan telah sampai di tujuan',
  };

  // Status colors
  static const Map<String, Color> orderStatusColors = {
    pending: AppColors.orderPending,
    approved: AppColors.orderApproved,
    preparing: AppColors.orderPreparing,
    onDelivery: AppColors.orderOnDelivery,
    delivered: AppColors.orderDelivered,
    cancelled: AppColors.orderCancelled,
  };

  static const Map<String, Color> deliveryStatusColors = {
    waiting: AppColors.orderPending,
    pickingUp: AppColors.orderApproved,
    onDelivery: AppColors.orderOnDelivery,
    delivered: AppColors.orderDelivered,
  };

  // Status icons
  static const Map<String, IconData> orderStatusIcons = {
    pending: Icons.access_time,
    approved: Icons.check_circle_outline,
    preparing: Icons.restaurant,
    onDelivery: Icons.delivery_dining,
    delivered: Icons.check_circle,
    cancelled: Icons.cancel,
  };

  static const Map<String, IconData> deliveryStatusIcons = {
    waiting: Icons.search,
    pickingUp: Icons.directions_car,
    onDelivery: Icons.delivery_dining,
    delivered: Icons.check_circle,
  };

  // Status progression
  static const Map<String, int> orderStatusOrder = {
    pending: 0,
    approved: 1,
    preparing: 2,
    onDelivery: 3,
    delivered: 4,
    cancelled: -1, // Special case for cancelled
  };

  static const Map<String, int> deliveryStatusOrder = {
    waiting: 0,
    pickingUp: 1,
    onDelivery: 2,
    delivered: 3,
  };

  static String getStatusName(String status) {
    return orderStatusNames[status] ?? status;
  }

  static String getStatusDescription(String status) {
    return orderStatusDescriptions[status] ?? '';
  }

  // Utility methods
  static String getOrderStatusName(String status) {
    return orderStatusNames[status] ?? status;
  }

  static String getDeliveryStatusName(String status) {
    return deliveryStatusNames[status] ?? status;
  }

  static String getOrderStatusDescription(String status) {
    return orderStatusDescriptions[status] ?? '';
  }

  static String getDeliveryStatusDescription(String status) {
    return deliveryStatusDescriptions[status] ?? '';
  }

  static Color getOrderStatusColor(String status) {
    return orderStatusColors[status] ?? AppColors.textSecondary;
  }

  static Color getDeliveryStatusColor(String status) {
    return deliveryStatusColors[status] ?? AppColors.textSecondary;
  }

  static IconData getOrderStatusIcon(String status) {
    return orderStatusIcons[status] ?? Icons.help_outline;
  }

  static IconData getDeliveryStatusIcon(String status) {
    return deliveryStatusIcons[status] ?? Icons.help_outline;
  }

  static bool isOrderActive(String status) {
    return activeOrderStatuses.contains(status);
  }

  static bool isOrderCompleted(String status) {
    return completedOrderStatuses.contains(status);
  }

  static bool canCancelOrder(String status) {
    return cancellableStatuses.contains(status);
  }

  static bool canTrackOrder(String status) {
    return [preparing, onDelivery].contains(status);
  }

  static bool canReviewOrder(String status) {
    return status == delivered;
  }

  static int getOrderStatusProgress(String status) {
    return orderStatusOrder[status] ?? 0;
  }

  static int getDeliveryStatusProgress(String status) {
    return deliveryStatusOrder[status] ?? 0;
  }

  static String getNextOrderStatus(String currentStatus) {
    switch (currentStatus) {
      case pending:
        return approved;
      case approved:
        return preparing;
      case preparing:
        return onDelivery;
      case onDelivery:
        return delivered;
      default:
        return currentStatus;
    }
  }

  static String getNextDeliveryStatus(String currentStatus) {
    switch (currentStatus) {
      case waiting:
        return pickingUp;
      case pickingUp:
        return onDelivery;
      case onDelivery:
        return delivered;
      default:
        return currentStatus;
    }
  }

  static List<String> getOrderStatusTimeline() {
    return [pending, approved, preparing, onDelivery, delivered];
  }

  static List<String> getDeliveryStatusTimeline() {
    return [waiting, pickingUp, onDelivery, delivered];
  }
}
