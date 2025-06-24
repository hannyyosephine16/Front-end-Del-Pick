class StorageKeys {
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String userPhone = 'user_phone';
  static const String userAvatar = 'user_avatar';
  static const String isLoggedIn = 'is_logged_in';
  // 🔐 Auth
  static const String authToken = 'auth_token';
  static const String authUser = 'auth_user';
  static const String authUserRole = 'auth_user_role';

  // 👣 Onboarding / App Intro
  static const String onboardingSeen = 'onboarding_seen';

  // 🔔 Notifications
  static const String fcmToken = 'fcm_token';
  static const String notificationPreference = 'notification_enabled';

  // 📍 Location
  static const String selectedLocation = 'selected_location';

  // 🛒 Cart / Store
  static const String lastViewedStore = 'last_store_id';
  static const String lastOrderId = 'last_order_id';

  // 🎨 UI
  static const String themeMode = 'dark_mode';
  static const String lastActiveTab = 'last_tab';

// 🔧 Other (if needed later)
// static const String someCustomKey = 'some_custom_key';
}
