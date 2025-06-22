import 'package:del_pick/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';

class StoreStatusConstants {
  // Menu item availability status (menggunakan boolean di backend)
  static const bool available = true;
  static const bool unavailable = false;

  // Status lists
  static const List<String> allStoreStatuses = [
    AppConstants.storeActive,
    AppConstants.storeInactive,
    AppConstants.storeClosed,
  ];

  static const List<bool> allMenuItemStatuses = [
    available,
    unavailable,
  ];

  static const List<String> operationalStatuses = [AppConstants.storeActive];

  static const List<String> nonOperationalStatuses = [
    AppConstants.storeInactive,
    AppConstants.storeClosed,
  ];

  static const List<bool> availableMenuStatuses = [available];

  static const List<bool> unavailableMenuStatuses = [unavailable];

  // Status display names
  static const Map<String, String> storeStatusNames = {
    AppConstants.storeActive: 'Aktif',
    AppConstants.storeInactive: 'Tidak Aktif',
    AppConstants.storeClosed: 'Tutup',
  };

  static const Map<bool, String> menuItemStatusNames = {
    available: 'Tersedia',
    unavailable: 'Tidak Tersedia',
  };

  // Status descriptions
  static const Map<String, String> storeStatusDescriptions = {
    AppConstants.storeActive: 'Toko aktif dan dapat menerima pesanan',
    AppConstants.storeInactive: 'Toko sedang tidak aktif',
    AppConstants.storeClosed: 'Toko tutup dan tidak menerima pesanan',
  };

  static const Map<bool, String> menuItemStatusDescriptions = {
    available: 'Menu tersedia untuk dipesan',
    unavailable: 'Menu sedang tidak tersedia',
  };

  // Status colors
  static const Map<String, Color> storeStatusColors = {
    AppConstants.storeActive: AppColors.storeOpen,
    AppConstants.storeInactive: AppColors.storeClosed,
    AppConstants.storeClosed: AppColors.storeClosed,
  };

  static const Map<bool, Color> menuItemStatusColors = {
    available: AppColors.success,
    unavailable: AppColors.error,
  };

  // Status icons
  static const Map<String, IconData> storeStatusIcons = {
    AppConstants.storeActive: Icons.store,
    AppConstants.storeInactive: Icons.store_mall_directory_outlined,
    AppConstants.storeClosed: Icons.lock,
  };

  static const Map<bool, IconData> menuItemStatusIcons = {
    available: Icons.check_circle,
    unavailable: Icons.cancel,
  };

  // Status priority (for sorting)
  static const Map<String, int> storeStatusPriority = {
    AppConstants.storeActive: 1,
    AppConstants.storeInactive: 2,
    AppConstants.storeClosed: 3,
  };

  static const Map<bool, int> menuItemStatusPriority = {
    available: 1,
    unavailable: 2,
  };

  // Business hours helpers
  static bool isStoreOpenByTime(String openTime, String closeTime) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();

    // Parse open and close times
    final openTimeParts = openTime.split(':');
    final closeTimeParts = closeTime.split(':');

    final openTimeOfDay = TimeOfDay(
      hour: int.parse(openTimeParts[0]),
      minute: int.parse(openTimeParts[1]),
    );

    final closeTimeOfDay = TimeOfDay(
      hour: int.parse(closeTimeParts[0]),
      minute: int.parse(closeTimeParts[1]),
    );

    // Convert to minutes for easier comparison
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final openMinutes = openTimeOfDay.hour * 60 + openTimeOfDay.minute;
    final closeMinutes = closeTimeOfDay.hour * 60 + closeTimeOfDay.minute;

    // Handle cases where store closes after midnight
    if (closeMinutes < openMinutes) {
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    } else {
      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    }
  }

  // Utility methods
  static String getStoreStatusName(String status) {
    return storeStatusNames[status] ?? status;
  }

  static String getMenuItemStatusName(bool status) {
    return menuItemStatusNames[status] ?? status.toString();
  }

  static String getStoreStatusDescription(String status) {
    return storeStatusDescriptions[status] ?? '';
  }

  static String getMenuItemStatusDescription(bool status) {
    return menuItemStatusDescriptions[status] ?? '';
  }

  static Color getStoreStatusColor(String status) {
    return storeStatusColors[status] ?? AppColors.textSecondary;
  }

  static Color getMenuItemStatusColor(bool status) {
    return menuItemStatusColors[status] ?? AppColors.textSecondary;
  }

  static IconData getStoreStatusIcon(String status) {
    return storeStatusIcons[status] ?? Icons.help_outline;
  }

  static IconData getMenuItemStatusIcon(bool status) {
    return menuItemStatusIcons[status] ?? Icons.help_outline;
  }

  static bool isStoreOperational(String status) {
    return operationalStatuses.contains(status);
  }

  static bool isStoreNonOperational(String status) {
    return nonOperationalStatuses.contains(status);
  }

  static bool canAcceptOrders(String status) {
    return status == AppConstants.storeActive;
  }

  static bool isMenuItemAvailable(bool status) {
    return status == available;
  }

  static bool isMenuItemUnavailable(bool status) {
    return status == unavailable;
  }

  static bool canOrderMenuItem(bool status) {
    return status == available;
  }

  static int getStoreStatusPriority(String status) {
    return storeStatusPriority[status] ?? 999;
  }

  static int getMenuItemStatusPriority(bool status) {
    return menuItemStatusPriority[status] ?? 999;
  }

  static String getDefaultStoreStatus() {
    return AppConstants.storeInactive;
  }

  static bool getDefaultMenuItemStatus() {
    return available;
  }

  // Status-based behavior helpers
  static bool shouldShowInSearch(String status) {
    return status == AppConstants.storeActive;
  }

  static bool shouldAcceptNewOrders(String status) {
    return status == AppConstants.storeActive;
  }

  static bool shouldShowClosedMessage(String status) {
    return [AppConstants.storeInactive, AppConstants.storeClosed]
        .contains(status);
  }

  static Duration getStatusUpdateInterval(String status) {
    switch (status) {
      case AppConstants.storeActive:
        return const Duration(minutes: 1);
      default:
        return const Duration(minutes: 5);
    }
  }

  static String getStoreStatusBasedOnTime(String openTime, String closeTime) {
    if (isStoreOpenByTime(openTime, closeTime)) {
      return AppConstants.storeActive;
    } else {
      return AppConstants.storeClosed;
    }
  }
}
