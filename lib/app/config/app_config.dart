// lib/app/config/app_config.dart
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:get/get.dart';

import '../../core/services/api/api_service.dart';
import '../../core/services/external/connectivity_service.dart';
import '../../core/services/external/location_service.dart';
import '../../core/services/external/notification_service.dart';
import '../../core/services/external/permission_service.dart';
import '../../core/services/local/storage_service.dart';

class AppConfig {
  // App Information
  static const String appName = AppConstants.appName;
  static const String appVersion = AppConstants.appVersion;
  static const String appBuildNumber = AppConstants.appBuildNumber;
  static const String appPackageName = 'frontend_delpick';

  // App settings
  static const int splashDuration = 3; // seconds
  static const int requestTimeout = AppConstants.apiTimeout;
  static const int connectionTimeout = AppConstants.connectionTimeout;
  static const int maxRetryAttempts = 3;

  // Location Settings
  static const double defaultLatitude = 2.38349390603264; // IT Del coordinates
  static const double defaultLongitude = 99.14866498216043;
  static const double maxDeliveryRadius = 5.0; // kilometers
  static const int locationUpdateInterval = 15; // seconds

  // Image Settings
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png'
  ]; // sesuai backend

  // Pagination
  static const int defaultPageSize = 10; // sesuai backend
  static const int maxPageSize = 50;

  // Order settings
  static const int orderCancelTimeout = 15 * 60; // 15 minutes
  static const int driverRequestTimeout = 15 * 60; // 15 minutes
  static const double serviceChargeRate = 0.1; // 10%

  // Rating settings
  static const int minRating = 1;
  static const int maxRating = 5;

  // Currency
  static const String currency = 'IDR';
  static const String currencySymbol = 'Rp';

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // Validation rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 100;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxAddressLength = 255;
  static const int maxNotesLength = 255;

  // Regular expressions (sesuai backend validation)
  static const String emailRegex = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  static const String phoneRegex = r'^[0-9]{10,13}$';
  static const String passwordRegex = r'^.{6,}$';

  // Cache Duration (in seconds)
  static const int shortCacheDuration = 300; // 5 minutes
  static const int mediumCacheDuration = 3600; // 1 hour
  static const int longCacheDuration = 86400; // 24 hours
  static const int verylongCacheDuration = 604800; // 1 week

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Languages
  static const String defaultLanguage = 'id';
  static const List<String> supportedLanguages = ['id', 'en'];

  // Maps
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;

  // Social media links
  static const String websiteUrl = 'https://delpick.horas-code.my.id';
  static const String supportEmail = 'support@delpick.com';
  static const String privacyPolicyUrl =
      'https://delpick.horas-code.my.id/privacy';
  static const String termsOfServiceUrl =
      'https://delpick.horas-code.my.id/terms';
  static const String facebookUrl = 'https://facebook.com/delpick';
  static const String instagramUrl = 'https://instagram.com/delpick';
  static const String twitterUrl = 'https://twitter.com/delpick';

  // Default placeholders
  static const String defaultAvatarUrl = 'https://via.placeholder.com/150';
  static const String defaultStoreImageUrl =
      'https://via.placeholder.com/300x200';
  static const String defaultFoodImageUrl =
      'https://via.placeholder.com/200x150';

  // File paths
  static const String documentsPath = '/documents';
  static const String imagesPath = '/images';
  static const String cachePath = '/cache';
  static const String logsPath = '/logs';

  // Feature Flags
  static bool get enableBiometric => true;
  static bool get enablePushNotifications => true;
  static bool get enableLocationTracking => true;
  static bool get enableOfflineMode => true;
  static bool get enableAnalytics => false;
  static bool get enableCrashReporting => false;

  // Development Settings
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static bool get isReleaseMode => !isDebugMode;
  static bool get enableLogging => isDebugMode;

  static Future<void> initialize() async {
    try {
      // Initialize core services
      Get.put<StorageService>(StorageService(), permanent: true);
      Get.put<ApiService>(ApiService(), permanent: true);
      Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
      Get.put<LocationService>(LocationService(), permanent: true);

      // Initialize services
      await Get.find<StorageService>().onInit();
      Get.find<ApiService>().onInit();
      await Get.find<ConnectivityService>().onInit();
      await Get.find<LocationService>().onInit();

      await Future.delayed(Duration.zero);
    } catch (e) {
      print('Error initializing app: $e');
    }
  }
}
