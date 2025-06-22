import 'package:del_pick/app/app.dart';
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';

class OrderStatusConstants {
  // Order status values (SESUAI BACKEND models/order.js)
  static const String pending = AppConstants.orderPending;
  static const String confirmed = AppConstants.orderConfirmed;
  static const String preparing = AppConstants.orderPreparing;
  static const String readyForPickup = AppConstants.orderReadyForPickup;
  static const String onDelivery = AppConstants.orderOnDelivery;
  static const String delivered = AppConstants.orderDelivered;
  static const String cancelled = AppConstants.orderCancelled;
  static const String rejected = AppConstants.orderRejected;

  // Delivery status values (SESUAI BACKEND models/order.js)
  static const String deliveryPending = AppConstants.deliveryPending;
  static const String pickedUp = AppConstants.deliveryPickedUp;
  static const String onWay = AppConstants.deliveryOnWay;
  static const String deliveryDelivered = AppConstants.deliveryDelivered;

  // Status lists
  static const List<String> allOrderStatuses = [
    pending,
    confirmed,
    preparing,
    readyForPickup,
    onDelivery,
    delivered,
    cancelled,
    rejected,
  ];

  static const List<String> allDeliveryStatuses = [
    deliveryPending,
    pickedUp, // FIXED
    onWay, // FIXED
    deliveryDelivered,
  ];

  static const List<String> activeOrderStatuses = [
    pending,
    confirmed, // FIXED
    preparing,
    readyForPickup, // DITAMBAHKAN
    onDelivery,
  ];

  static const List<String> completedOrderStatuses = [
    delivered,
    cancelled,
    rejected
  ];

  static const List<String> cancellableStatuses = [pending, confirmed]; // FIXED

  // Status display names
  static const Map<String, String> orderStatusNames = {
    pending: 'Menunggu Konfirmasi',
    confirmed: 'Dikonfirmasi',
    preparing: 'Sedang Disiapkan',
    readyForPickup: 'Siap Diambil',
    onDelivery: 'Dalam Pengiriman',
    delivered: 'Selesai',
    cancelled: 'Dibatalkan',
    rejected: 'Ditolak',
  };

  static const Map<String, String> deliveryStatusNames = {
    deliveryPending: 'Menunggu Driver',
    pickedUp: 'Telah Diambil',
    onWay: 'Dalam Perjalanan',
    deliveryDelivered: 'Terkirim',
  };

  // Status descriptions
  static const Map<String, String> orderStatusDescriptions = {
    pending: 'Pesanan Anda sedang menunggu konfirmasi dari toko',
    confirmed: 'Pesanan telah dikonfirmasi dan sedang mencari driver',
    preparing: 'Toko sedang menyiapkan pesanan Anda',
    readyForPickup: 'Pesanan siap diambil oleh driver',
    onDelivery: 'Driver sedang mengirimkan pesanan Anda',
    delivered: 'Pesanan telah berhasil dikirimkan',
    cancelled: 'Pesanan telah dibatalkan',
    rejected: 'Pesanan ditolak oleh toko',
  };

  static const Map<String, String> deliveryStatusDescriptions = {
    deliveryPending: 'Sedang mencari driver untuk mengantarkan pesanan Anda',
    pickedUp: 'Driver telah mengambil pesanan dari toko', // FIXED
    onWay: 'Driver sedang dalam perjalanan menuju alamat pengiriman', // FIXED
    deliveryDelivered: 'Pesanan telah sampai di tujuan',
  };

  // Status colors
  static const Map<String, Color> orderStatusColors = {
    pending: AppColors.orderPending,
    confirmed: AppColors.orderApproved,
    preparing: AppColors.orderPreparing,
    readyForPickup: AppColors.info,
    onDelivery: AppColors.orderOnDelivery,
    delivered: AppColors.orderDelivered,
    cancelled: AppColors.orderCancelled,
    rejected: AppColors.error,
  };

  static const Map<String, Color> deliveryStatusColors = {
    deliveryPending: AppColors.orderPending,
    pickedUp: AppColors.orderApproved,
    onWay: AppColors.orderOnDelivery,
    deliveryDelivered: AppColors.orderDelivered,
  };

  // Status icons
  static const Map<String, IconData> orderStatusIcons = {
    pending: Icons.access_time,
    confirmed: Icons.check_circle_outline,
    preparing: Icons.restaurant,
    readyForPickup: Icons.shopping_bag,
    onDelivery: Icons.delivery_dining,
    delivered: Icons.check_circle,
    cancelled: Icons.cancel,
    rejected: Icons.close,
  };

  static const Map<String, IconData> deliveryStatusIcons = {
    deliveryPending: Icons.search,
    pickedUp: Icons.check,
    onWay: Icons.delivery_dining,
    deliveryDelivered: Icons.check_circle,
  };

  // Status progression
  static const Map<String, int> orderStatusOrder = {
    pending: 0,
    confirmed: 1, // FIXED
    preparing: 2,
    readyForPickup: 3,
    onDelivery: 4,
    delivered: 5,
    cancelled: -1,
    rejected: -2,
  };

  static const Map<String, int> deliveryStatusOrder = {
    deliveryPending: 0,
    pickedUp: 1,
    onWay: 2,
    deliveryDelivered: 3,
  };

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
    return [preparing, readyForPickup, onDelivery].contains(status);
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
        return confirmed; // FIXED
      case confirmed: // FIXED
        return preparing;
      case preparing:
        return readyForPickup; // FIXED
      case readyForPickup: // DITAMBAHKAN
        return onDelivery;
      case onDelivery:
        return delivered;
      default:
        return currentStatus;
    }
  }

  static String getNextDeliveryStatus(String currentStatus) {
    switch (currentStatus) {
      case deliveryPending:
        return pickedUp;
      case pickedUp:
        return onWay;
      case onWay:
        return deliveryDelivered;
      default:
        return currentStatus;
    }
  }

  static List<String> getOrderStatusTimeline() {
    return [
      pending,
      confirmed,
      preparing,
      readyForPickup,
      onDelivery,
      delivered
    ];
  }

  static List<String> getDeliveryStatusTimeline() {
    return [deliveryPending, pickedUp, onWay, deliveryDelivered];
  }

  // Helper methods
  static bool isActiveStatus(String status) {
    return activeOrderStatuses.contains(status);
  }

  static bool isCompletedStatus(String status) {
    return status == delivered;
  }

  static bool isCancelledStatus(String status) {
    return [cancelled, rejected].contains(status);
  }

  static bool canTrack(String status) {
    return canTrackOrder(status);
  }

  static bool canCancel(String status) {
    return canCancelOrder(status);
  }

  static bool canReview(String status) {
    return canReviewOrder(status);
  }

  static String getDisplayName(String status) {
    return getOrderStatusName(status);
  }

  static String getStatusColor(String status) {
    final color = getOrderStatusColor(status);
    if (color == AppColors.orderPending || color == AppColors.orderApproved) {
      return 'warning';
    } else if (color == AppColors.info) {
      return 'info';
    } else if (color == AppColors.orderOnDelivery) {
      return 'secondary';
    } else if (color == AppColors.orderDelivered) {
      return 'success';
    } else if (color == AppColors.orderCancelled || color == AppColors.error) {
      return 'error';
    } else {
      return 'default';
    }
  }

  static String getStatusName(String status) {
    return getOrderStatusName(status);
  }

  static String getStatusDescription(String status) {
    return getOrderStatusDescription(status);
  }
}
