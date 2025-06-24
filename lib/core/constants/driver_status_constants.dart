// lib/core/constants/driver_status_constants.dart - SESUAI BACKEND MIGRATIONS
class DriverStatusConstants {
  // DRIVER STATUSES (sesuai backend models/driver.js)
  static const String driverActive = 'active';
  static const String driverInactive = 'inactive';
  static const String driverBusy = 'busy';

  static const List<String> allDriverStatuses = [
    driverActive,
    driverInactive,
    driverBusy,
  ];

  // DRIVER REQUEST STATUSES (sesuai backend models/driverRequest.js)
  static const String requestPending = 'pending';
  static const String requestAccepted = 'accepted';
  static const String requestRejected = 'rejected';
  static const String requestCompleted = 'completed';
  static const String requestExpired = 'expired';
  static const String requestCancelled = 'cancelled';

  static const List<String> allDriverRequestStatuses = [
    requestPending,
    requestAccepted,
    requestRejected,
    requestCompleted,
    requestExpired,
    requestCancelled,
  ];

  // UTILITY METHODS
  static bool isValidDriverStatus(String? status) {
    return status != null && allDriverStatuses.contains(status);
  }

  static bool isValidDriverRequestStatus(String? status) {
    return status != null && allDriverRequestStatuses.contains(status);
  }

  static bool canDriverAcceptRequests(String status) {
    return status == driverActive;
  }

  static bool isDriverAvailable(String status) {
    return status == driverActive;
  }

  static bool isDriverWorking(String status) {
    return status == driverBusy;
  }

  static bool isRequestPending(String status) {
    return status == requestPending;
  }

  static bool isRequestCompleted(String status) {
    return [requestAccepted, requestCompleted].contains(status);
  }

  static bool canCancelRequest(String status) {
    return status == requestPending;
  }

  // DRIVER STATUS NAMES & DESCRIPTIONS
  static String getDriverStatusName(String status) {
    switch (status) {
      case driverActive:
        return 'Aktif';
      case driverInactive:
        return 'Tidak Aktif';
      case driverBusy:
        return 'Sibuk';
      default:
        return 'Status Tidak Dikenal';
    }
  }

  static String getDriverStatusDescription(String status) {
    switch (status) {
      case driverActive:
        return 'Driver tersedia untuk menerima pesanan';
      case driverInactive:
        return 'Driver tidak aktif dan tidak menerima pesanan';
      case driverBusy:
        return 'Driver sedang mengantarkan pesanan';
      default:
        return 'Status driver tidak dikenal';
    }
  }

  // DRIVER STATUS TRANSITIONS
  static bool canTransitionDriverStatus(String fromStatus, String toStatus) {
    // Business rules untuk perubahan status driver
    switch (fromStatus) {
      case driverInactive:
        return toStatus == driverActive;
      case driverActive:
        return [driverInactive, driverBusy].contains(toStatus);
      case driverBusy:
        return [driverActive, driverInactive].contains(toStatus);
      default:
        return false;
    }
  }

  static List<String> getAvailableDriverStatusTransitions(
      String currentStatus) {
    switch (currentStatus) {
      case driverInactive:
        return [driverActive];
      case driverActive:
        return [driverInactive, driverBusy];
      case driverBusy:
        return [driverActive, driverInactive];
      default:
        return [];
    }
  }

  static int getDriverStatusPriority(String status) {
    switch (status) {
      case driverActive:
        return 1; // Highest priority
      case driverBusy:
        return 2;
      case driverInactive:
        return 3; // Lowest priority
      default:
        return 999;
    }
  }

  // DRIVER REQUEST STATUS NAMES
  static String getRequestStatusName(String status) {
    switch (status) {
      case requestPending:
        return 'Menunggu';
      case requestAccepted:
        return 'Diterima';
      case requestRejected:
        return 'Ditolak';
      case requestCompleted:
        return 'Selesai';
      case requestExpired:
        return 'Kedaluwarsa';
      case requestCancelled:
        return 'Dibatalkan';
      default:
        return 'Status Tidak Dikenal';
    }
  }

  // REQUEST TIMEOUT (sesuai backend worker.js)
  static Duration getRequestTimeout(String status) {
    switch (status) {
      case requestPending:
        return const Duration(minutes: 15); // Sesuai backend timeout
      default:
        return const Duration(minutes: 5);
    }
  }
}
