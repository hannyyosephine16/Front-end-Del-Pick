/// ✅ StorageConstants yang sesuai dengan backend DelPick
class StorageConstants {
  // ======================== AUTHENTICATION ========================
  static const String authToken = 'auth_token';
  static const String refreshToken =
      'refresh_token'; // DelPick tidak pakai, tapi keep untuk compatibility

  // User data keys - sesuai response backend
  static const String userDataKey = 'user_data'; // Complete user object
  static const String driverDataKey =
      'driver_data'; // Driver specific data from login response
  static const String storeDataKey =
      'store_data'; // Store specific data from login response

  // Individual user fields for quick access
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userPhone = 'user_phone';
  static const String userAvatar = 'user_avatar';
  static const String fcmToken = 'fcm_token';

  // Auth state
  static const String isLoggedIn = 'is_logged_in';
  static const String lastLoginTime = 'last_login_time';
  static const String rememberMe = 'remember_me';

  // ======================== USER PREFERENCES ========================
  static const String language = 'language';
  static const String theme = 'theme';
  static const String isDarkMode = 'is_dark_mode';
  static const String isFirstTime = 'is_first_time';
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // ======================== NOTIFICATIONS ========================
  static const String notificationsEnabled = 'notifications_enabled';
  static const String orderNotifications = 'order_notifications';
  static const String promotionNotifications = 'promotion_notifications';
  static const String deliveryNotifications = 'delivery_notifications';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';

  // ======================== LOCATION ========================
  static const String locationPermissionGranted = 'location_permission_granted';
  static const String lastKnownLatitude = 'last_known_latitude';
  static const String lastKnownLongitude = 'last_known_longitude';
  static const String defaultDeliveryAddress = 'default_delivery_address';
  static const String savedAddresses = 'saved_addresses';

  // ======================== CART & ORDERS ========================
  // Cart data - sesuai dengan backend order structure
  static const String cartItems = 'cart_items';
  static const String cartStoreId = 'cart_store_id';
  static const String cartStoreName = 'cart_store_name';
  static const String cartTotal = 'cart_total';
  static const String cartUpdatedAt = 'cart_updated_at';

  // Order drafts and temporary data
  static const String draftOrderData = 'draft_order_data';
  static const String tempOrderData = 'temp_order_data';
  static const String lastOrderId = 'last_order_id';

  // ======================== DRIVER SPECIFIC ========================
  // Driver settings - sesuai dengan backend driver model
  static const String driverStatus = 'driver_status'; // active, inactive, busy
  static const String driverVehicleNumber = 'driver_vehicle_number';
  static const String driverLicenseNumber = 'driver_license_number';
  static const String driverLocationUpdateInterval =
      'driver_location_update_interval';
  static const String acceptOrdersAutomatically = 'accept_orders_automatically';
  static const String workingHoursStart = 'working_hours_start';
  static const String workingHoursEnd = 'working_hours_end';
  static const String driverLatitude = 'driver_latitude';
  static const String driverLongitude = 'driver_longitude';

  // ======================== STORE SPECIFIC ========================
  // Store settings - sesuai dengan backend store model
  static const String storeId = 'store_id';
  static const String storeName = 'store_name';
  static const String storeStatus = 'store_status'; // active, inactive
  static const String storeOpenTime = 'store_open_time';
  static const String storeCloseTime = 'store_close_time';
  static const String storeLatitude = 'store_latitude';
  static const String storeLongitude = 'store_longitude';
  static const String storeAddress = 'store_address';
  static const String storeDescription = 'store_description';
  static const String storeImageUrl = 'store_image_url';
  static const String storePhone = 'store_phone';
  static const String storeRating = 'store_rating';
  static const String storeTotalProducts = 'store_total_products';
  static const String autoAcceptOrders = 'auto_accept_orders';
  static const String preparationTime = 'preparation_time';

  // ======================== CUSTOMER SPECIFIC ========================
  static const String favoriteStores = 'favorite_stores';
  static const String favoriteMenuItems = 'favorite_menu_items';
  static const String orderHistory = 'order_history';
  static const String recentSearches = 'recent_searches';
  static const String paymentMethods = 'payment_methods';
  static const String defaultPaymentMethod = 'default_payment_method';

  // ======================== APP SETTINGS ========================
  static const String autoLocationUpdate = 'auto_location_update';
  static const String offlineMode = 'offline_mode';
  static const String dataUsageOptimization = 'data_usage_optimization';
  static const String cacheSize = 'cache_size';
  static const String maxCacheSize = 'max_cache_size';

  // ======================== OFFLINE DATA ========================
  static const String offlineOrders = 'offline_orders';
  static const String pendingSyncData = 'pending_sync_data';
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedStores = 'cached_stores';
  static const String cachedMenuItems = 'cached_menu_items';

  // ======================== ANALYTICS & TRACKING ========================
  static const String analyticsEnabled = 'analytics_enabled';
  static const String crashReportingEnabled = 'crash_reporting_enabled';
  static const String usageStatistics = 'usage_statistics';
  static const String sessionCount = 'session_count';
  static const String totalAppUsageTime = 'total_app_usage_time';

  // ======================== SECURITY ========================
  static const String biometricEnabled = 'biometric_enabled';
  static const String pinEnabled = 'pin_enabled';
  static const String autoLockEnabled = 'auto_lock_enabled';
  static const String autoLockDuration = 'auto_lock_duration';
  static const String lastSecurityCheck = 'last_security_check';

  // ======================== FEATURE FLAGS ========================
  static const String betaFeaturesEnabled = 'beta_features_enabled';
  static const String debugModeEnabled = 'debug_mode_enabled';
  static const String developerOptionsEnabled = 'developer_options_enabled';

  // ======================== APP VERSION TRACKING ========================
  static const String currentAppVersion = 'current_app_version';
  static const String lastAppVersion = 'last_app_version';
  static const String installDate = 'install_date';
  static const String lastUpdateDate = 'last_update_date';

  // ======================== NETWORK SETTINGS ========================
  static const String preferredNetworkType = 'preferred_network_type';
  static const String cacheNetworkRequests = 'cache_network_requests';
  static const String retryFailedRequests = 'retry_failed_requests';
  static const String maxRetryAttempts = 'max_retry_attempts';

  // ======================== UI PREFERENCES ========================
  static const String fontSize = 'font_size';
  static const String animationsEnabled = 'animations_enabled';
  static const String hapticFeedbackEnabled = 'haptic_feedback_enabled';
  static const String showTutorials = 'show_tutorials';
  static const String compactMode = 'compact_mode';

  // ======================== TEMPORARY DATA ========================
  static const String tempImagePath = 'temp_image_path';
  static const String tempFilterSettings = 'temp_filter_settings';
  static const String tempSearchQuery = 'temp_search_query';

  // ======================== ERROR HANDLING ========================
  static const String lastErrorMessage = 'last_error_message';
  static const String lastErrorTime = 'last_error_time';
  static const String errorReportingEnabled = 'error_reporting_enabled';
  static const String automaticErrorReporting = 'automatic_error_reporting';

  // ======================== TRACKING & DELIVERY ========================
  // Tracking specific data
  static const String lastTrackingData = 'last_tracking_data';
  static const String trackingHistory = 'tracking_history';
  static const String activeOrderTracking = 'active_order_tracking';

  // Delivery specific
  static const String deliveryInstructions = 'delivery_instructions';
  static const String defaultDeliveryNotes = 'default_delivery_notes';

  // ======================== API & SYNC ========================
  static const String apiBaseUrl = 'api_base_url';
  static const String lastApiSync = 'last_api_sync';
  static const String pendingApiCalls = 'pending_api_calls';
  static const String apiRetryQueue = 'api_retry_queue';

  // ======================== MENU & CATEGORIES ========================
  static const String lastViewedCategory = 'last_viewed_category';
  static const String menuItemFilters = 'menu_item_filters';
  static const String lastMenuSync = 'last_menu_sync';

  // ======================== REVIEW & RATING ========================
  static const String pendingReviews = 'pending_reviews';
  static const String reviewHistory = 'review_history';
  static const String skipReviewReminder = 'skip_review_reminder';
}
