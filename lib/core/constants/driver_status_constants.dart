import 'package:del_pick/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';

class DriverStatusConstants {
  // Driver status values
  static const String driverActive = 'active';
  static const String driverInactive = 'inactive';
  static const String driverBusy = 'busy';

  // DRIVER REQUEST STATUSES (sesuai backend models/driverRequest.js)
  static const String requestPending = 'pending';
  static const String requestAccepted = 'accepted';
  static const String requestRejected = 'rejected';
  static const String requestCompleted = 'completed';
  static const String requestExpired = 'expired';

  // Status lists
  static const List<String> allDriverStatuses = [
    DriverStatusConstants.driverActive,
    DriverStatusConstants.driverInactive,
    DriverStatusConstants.driverBusy
  ];

  static const List<String> allDriverRequestStatuses = [
    requestPending,
    requestAccepted,
    requestRejected,
    requestCompleted,
    requestExpired,
  ];

  static const List<String> availableStatuses = [driverActive];

  static const List<String> unavailableStatuses = [driverInactive, driverBusy];

  static const List<String> activeRequestStatuses = [
    requestPending,
    requestAccepted,
  ];

  static const List<String> completedRequestStatuses = [
    requestRejected,
    requestExpired,
    requestCompleted,
  ];

  // Status display names
  static const Map<String, String> driverStatusNames = {
    driverActive: 'Aktif',
    driverInactive: 'Tidak Aktif',
    driverBusy: 'Sibuk',
  };

  static const Map<String, String> requestStatusNames = {
    requestPending: 'Menunggu Respons',
    requestAccepted: 'Diterima',
    requestRejected: 'Ditolak',
    requestExpired: 'Kedaluwarsa',
    requestCompleted: 'Selesai',
  };

  // Status descriptions
  static const Map<String, String> driverStatusDescriptions = {
    driverActive: 'Driver siap menerima pesanan',
    driverInactive: 'Driver sedang tidak tersedia',
    driverBusy: 'Driver sedang mengantarkan pesanan',
  };

  static const Map<String, String> requestStatusDescriptions = {
    requestPending: 'Permintaan pengantaran sedang menunggu respons driver',
    requestAccepted: 'Driver telah menerima permintaan pengantaran',
    requestRejected: 'Driver menolak permintaan pengantaran',
    requestExpired: 'Permintaan pengantaran telah kedaluwarsa',
    requestCompleted: 'Pengantaran telah selesai',
  };

  // Status colors
  static const Map<String, Color> driverStatusColors = {
    driverActive: AppColors.driverActive,
    driverInactive: AppColors.driverInactive,
    driverBusy: AppColors.driverBusy,
  };

  static const Map<String, Color> requestStatusColors = {
    requestPending: AppColors.orderPending,
    requestAccepted: AppColors.success,
    requestRejected: AppColors.error,
    requestExpired: AppColors.textSecondary,
    requestCompleted: AppColors.orderDelivered,
  };

  // Status icons
  static const Map<String, IconData> driverStatusIcons = {
    driverActive: Icons.check_circle,
    driverInactive: Icons.cancel,
    driverBusy: Icons.delivery_dining,
  };

  static const Map<String, IconData> requestStatusIcons = {
    requestPending: Icons.access_time,
    requestAccepted: Icons.check_circle,
    requestRejected: Icons.cancel,
    requestExpired: Icons.schedule,
    requestCompleted: Icons.done_all,
  };

  // Status priority (for sorting)
  static const Map<String, int> driverStatusPriority = {
    driverActive: 1,
    driverBusy: 2,
    driverInactive: 3,
  };

  static const Map<String, int> requestStatusPriority = {
    requestPending: 1,
    requestAccepted: 2,
    requestCompleted: 3,
    requestRejected: 4,
    requestExpired: 5,
  };

  // Status transitions
  static const Map<String, List<String>> allowedDriverStatusTransitions = {
    driverInactive: [driverActive],
    driverActive: [driverInactive, driverBusy],
    driverBusy: [driverActive, driverInactive],
  };

  static const Map<String, List<String>> allowedRequestStatusTransitions = {
    requestPending: [requestAccepted, requestRejected, requestExpired],
    requestAccepted: [requestCompleted],
    requestRejected: [],
    requestExpired: [],
    requestCompleted: [],
  };

  // Utility methods
  static String getDriverStatusName(String status) {
    return driverStatusNames[status] ?? status;
  }

  static String getRequestStatusName(String status) {
    return requestStatusNames[status] ?? status;
  }

  static String getDriverStatusDescription(String status) {
    return driverStatusDescriptions[status] ?? '';
  }

  static String getRequestStatusDescription(String status) {
    return requestStatusDescriptions[status] ?? '';
  }

  static Color getDriverStatusColor(String status) {
    return driverStatusColors[status] ?? AppColors.textSecondary;
  }

  static Color getRequestStatusColor(String status) {
    return requestStatusColors[status] ?? AppColors.textSecondary;
  }

  static IconData getDriverStatusIcon(String status) {
    return driverStatusIcons[status] ?? Icons.help_outline;
  }

  static IconData getRequestStatusIcon(String status) {
    return requestStatusIcons[status] ?? Icons.help_outline;
  }

  static bool isDriverAvailable(String status) {
    return availableStatuses.contains(status);
  }

  static bool isDriverUnavailable(String status) {
    return unavailableStatuses.contains(status);
  }

  static bool isRequestActive(String status) {
    return activeRequestStatuses.contains(status);
  }

  static bool isRequestCompleted(String status) {
    return completedRequestStatuses.contains(status);
  }

  static bool canAcceptOrders(String status) {
    return status == driverActive;
  }

  static bool canRejectRequest(String status) {
    return status == requestPending;
  }

  static bool canAcceptRequest(String status) {
    return status == requestPending;
  }

  static bool canCompleteRequest(String status) {
    return status == requestAccepted;
  }

  static int getDriverStatusPriority(String status) {
    return driverStatusPriority[status] ?? 999;
  }

  static int getRequestStatusPriority(String status) {
    return requestStatusPriority[status] ?? 999;
  }

  static bool canTransitionDriverStatus(String from, String to) {
    return allowedDriverStatusTransitions[from]?.contains(to) ?? false;
  }

  static bool canTransitionRequestStatus(String from, String to) {
    return allowedRequestStatusTransitions[from]?.contains(to) ?? false;
  }

  static List<String> getAvailableDriverStatusTransitions(
    String currentStatus,
  ) {
    return allowedDriverStatusTransitions[currentStatus] ?? [];
  }

  static List<String> getAvailableRequestStatusTransitions(
    String currentStatus,
  ) {
    return allowedRequestStatusTransitions[currentStatus] ?? [];
  }

  static String getDefaultDriverStatus() {
    return driverInactive;
  }

  static String getDefaultRequestStatus() {
    return requestPending;
  }

  // Status-based behavior helpers
  static bool shouldShowLocationUpdate(String status) {
    return [driverActive, driverBusy].contains(status);
  }

  static bool shouldReceiveOrderRequests(String status) {
    return status == driverActive;
  }

  static bool shouldShowDeliveryUI(String status) {
    return status == driverBusy;
  }

  static Duration getStatusUpdateInterval(String status) {
    switch (status) {
      case driverActive:
        return const Duration(seconds: 30);
      case driverBusy:
        return const Duration(seconds: 15);
      default:
        return const Duration(minutes: 5);
    }
  }

  static Duration getRequestTimeout(String status) {
    switch (status) {
      case requestPending:
        return const Duration(minutes: 15); // sesuai backend 15 menit
      default:
        return const Duration(minutes: 5);
    }
  }
}
