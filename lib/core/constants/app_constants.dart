// lib/core/constants/app_constants.dart - FIXED TO MATCH BACKEND
class AppConstants {
  // App Information
  static const String appName = 'DelPick';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // USER ROLES
  static const String roleCustomer = 'customer';
  static const String roleDriver = 'driver';
  static const String roleStore = 'store';

  static const List<String> validRoles = [roleCustomer, roleDriver, roleStore];

  // ORDER STATUSES (sesuai backend models/order.js)
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed'; // BUKAN 'approved'
  static const String orderPreparing = 'preparing';
  static const String orderReadyForPickup = 'ready_for_pickup'; // DITAMBAHKAN
  static const String orderOnDelivery = 'on_delivery';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  static const String orderRejected = 'rejected';

  static const List<String> allOrderStatuses = [
    orderPending,
    orderConfirmed,
    orderPreparing,
    orderReadyForPickup,
    orderOnDelivery,
    orderDelivered,
    orderCancelled,
    orderRejected,
  ];

  // DELIVERY STATUSES (sesuai backend models/order.js)
  static const String deliveryPending = 'pending';
  static const String deliveryPickedUp = 'picked_up';
  static const String deliveryOnWay = 'on_way';
  static const String deliveryDelivered = 'delivered';

  static const List<String> allDeliveryStatuses = [
    deliveryPending,
    deliveryPickedUp,
    deliveryOnWay,
    deliveryDelivered,
  ];

  // DRIVER STATUSES (sesuai backend models/driver.js)
  static const String driverActive = 'active';
  static const String driverInactive = 'inactive';
  static const String driverBusy = 'busy';

  static const List<String> allDriverStatuses = [
    driverActive,
    driverInactive,
    driverBusy,
  ];

  // STORE STATUSES (sesuai backend models/store.js)
  static const String storeActive = 'active';
  static const String storeInactive = 'inactive';
  static const String storeClosed = 'closed';

  static const List<String> allStoreStatuses = [
    storeActive,
    storeInactive,
    storeClosed,
  ];

  // DRIVER REQUEST STATUSES (sesuai backend models/driverRequest.js)
  static const String requestPending = 'pending';
  static const String requestAccepted = 'accepted';
  static const String requestRejected = 'rejected';
  static const String requestCompleted = 'completed';
  static const String requestExpired = 'expired';

  static const List<String> allDriverRequestStatuses = [
    requestPending,
    requestAccepted,
    requestRejected,
    requestCompleted,
    requestExpired,
  ];

  // MENU ITEM STATUS
  static const bool menuAvailable = true;
  static const bool menuUnavailable = false;

  // VALIDATION RULES
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxAddressLength = 255;
  static const int maxNotesLength = 255;

  // Regular expressions
  static const String emailRegex = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  static const String phoneRegex = r'^[0-9]{10,13}$'; // sesuai backend
  static const String passwordRegex = r'^.{6,}$'; // minimal 6 karakter

  // IMAGE UPLOAD (sesuai backend)
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // PAGINATION (sesuai backend)
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // LOCATION (sesuai backend)
  static const double defaultLatitude = 2.38349390603264; // IT Del
  static const double defaultLongitude = 99.14866498216043;
  static const double maxDeliveryRadius = 5.0; // km
  static const int locationUpdateInterval = 15; // seconds

  // RATING (sesuai backend)
  static const int minRating = 1;
  static const int maxRating = 5;

  // CURRENCY
  static const String currency = 'IDR';
  static const String currencySymbol = 'Rp';

  // TIME FORMATS (sesuai backend)
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // TIMEOUTS (sesuai backend)
  static const int apiTimeout = 30; // seconds
  static const int connectionTimeout = 10; // seconds
  static const int orderCancelTimeout = 15 * 60; // 15 minutes
  static const int driverRequestTimeout =
      15 * 60; // 15 minutes (sesuai backend)

  // CACHE DURATIONS
  static const int shortCacheDuration = 5 * 60; // 5 minutes
  static const int mediumCacheDuration = 30 * 60; // 30 minutes
  static const int longCacheDuration = 60 * 60; // 1 hour
  static const int verylongCacheDuration = 24 * 60 * 60; // 24 hours

  // ANIMATION DURATIONS
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // NOTIFICATION TYPES
  static const String notificationOrderUpdate = 'order_update';
  static const String notificationDeliveryUpdate = 'delivery_update';
  static const String notificationDriverRequest = 'driver_request';
  static const String notificationPromotion = 'promotion';
  static const String notificationGeneral = 'general';

  // LANGUAGES
  static const String defaultLanguage = 'id'; // Indonesia sebagai default
  static const List<String> supportedLanguages = ['id', 'en'];

  // MAPS
  static const double defaultZoom = 15.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 20.0;

  // ERROR MESSAGES
  static const String errorGeneral = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNetwork =
      'Tidak ada koneksi internet. Periksa koneksi Anda.';
  static const String errorTimeout = 'Permintaan timeout. Silakan coba lagi.';
  static const String errorUnauthorized =
      'Anda tidak memiliki izin untuk melakukan tindakan ini.';
  static const String errorNotFound = 'Data yang diminta tidak ditemukan.';
  static const String errorValidation = 'Periksa input Anda dan coba lagi.';
  static const String errorServer =
      'Kesalahan server. Silakan coba lagi nanti.';

  // SUCCESS MESSAGES
  static const String successLogin = 'Login berhasil';
  static const String successRegister = 'Registrasi berhasil';
  static const String successUpdate = 'Update berhasil';
  static const String successDelete = 'Hapus berhasil';
  static const String successOrderPlaced = 'Pesanan berhasil dibuat';
  static const String successOrderCancelled = 'Pesanan berhasil dibatalkan';

  // UTILITY METHODS
  static bool isValidRole(String? role) {
    return role != null && validRoles.contains(role);
  }

  static bool isValidOrderStatus(String? status) {
    return status != null && allOrderStatuses.contains(status);
  }

  static bool isValidDeliveryStatus(String? status) {
    return status != null && allDeliveryStatuses.contains(status);
  }

  static bool isValidDriverStatus(String? status) {
    return status != null && allDriverStatuses.contains(status);
  }

  static bool isValidStoreStatus(String? status) {
    return status != null && allStoreStatuses.contains(status);
  }

  static bool isValidDriverRequestStatus(String? status) {
    return status != null && allDriverRequestStatuses.contains(status);
  }

  static bool canCancelOrder(String status) {
    return [orderPending, orderConfirmed, orderPreparing].contains(status);
  }

  static bool canTrackOrder(String status) {
    return [orderPreparing, orderReadyForPickup, orderOnDelivery]
        .contains(status);
  }

  static bool canDriverAcceptRequests(String status) {
    return status == driverActive;
  }

  static bool isStoreOperational(String status) {
    return status == storeActive;
  }
}
