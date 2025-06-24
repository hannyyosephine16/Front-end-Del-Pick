import 'package:del_pick/core/constants/app_constants.dart';
import 'package:get/get.dart';
import '../../core/services/api/api_service.dart';
import '../../core/services/external/connectivity_service.dart';
import '../../core/services/external/location_service.dart';
import '../../core/services/local/storage_service.dart';

class AppConfig {
  // App Information
  static const String appName = AppConstants.appName;
  static const String appVersion = AppConstants.appVersion;
  static const String appBuildNumber = AppConstants.appBuildNumber;
  static const String appPackageName =
      'com.delpick.app'; // Standard package name

  // App settings sesuai backend timeout
  static const int splashDuration = 3;
  static const int requestTimeout = 30; // Sesuai backend (30 seconds)
  static const int connectionTimeout = 30; // Sesuai backend
  static const int maxRetryAttempts = 3;

  // Location Settings (IT Del coordinates)
  static const double defaultLatitude = 2.38349390603264;
  static const double defaultLongitude = 99.14866498216043;
  static const double maxDeliveryRadius =
      5.0; // Sesuai backend euclideanDistance logic
  static const int locationUpdateInterval = 15; // seconds untuk driver tracking

  // Image Settings - SESUAI BACKEND (50MB limit di app.js)
  static const int maxImageSize = 50 * 1024 * 1024; // 50MB sesuai backend
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif' // Tambah gif sesuai backend allowedTypes
  ];

  // Pagination - SESUAI BACKEND default limit
  static const int defaultPageSize = 10; // Sesuai backend queryHelper.js
  static const int maxPageSize = 100; // Sesuai backend rate limiter

  // Order settings - SESUAI BACKEND LOGIC
  static const int orderCancelTimeout = 15 * 60; // 15 menit
  static const int driverRequestTimeout =
      15 * 60; // 15 menit sesuai backend timeout
  static const double deliveryFeePerKm =
      2000; // Sesuai backend: distance_km * 2000

  // Rating settings - SESUAI BACKEND VALIDATION
  static const int minRating = 1; // Sesuai backend validation min: 1
  static const int maxRating = 5; // Sesuai backend validation max: 5

  // Currency
  static const String currency = 'IDR';
  static const String currencySymbol = 'Rp';

  // Date formats - KONSISTEN DENGAN BACKEND
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // Validation rules - SESUAI BACKEND SCHEMAS
  static const int minPasswordLength = 6; // Sesuai backend schemas
  static const int maxPasswordLength = 50; // Sesuai backend schemas
  static const int minNameLength = 3; // Sesuai backend schemas
  static const int maxNameLength = 50; // Sesuai backend schemas
  static const int maxDescriptionLength = 500; // Sesuai backend schemas
  static const int maxAddressLength = 255;
  static const int maxNotesLength = 255;

  // Regular expressions - SESUAI BACKEND VALIDATION
  static const String emailRegex = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  static const String phoneRegex =
      r'^[0-9]{10,13}$'; // Sesuai backend validation
  static const String passwordRegex = r'^.{6,}$'; // Min 6 chars

  // Cache Duration - SESUAI BACKEND CACHE CONFIG
  static const int shortCacheDuration = 300; // 5 minutes
  static const int mediumCacheDuration = 3600; // 1 hour sesuai backend
  static const int longCacheDuration = 86400; // 24 hours sesuai backend
  static const int verylongCacheDuration = 604800; // 1 week sesuai backend

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Languages
  static const String defaultLanguage = 'id';
  static const List<String> supportedLanguages = ['id', 'en'];

  // Maps - UNTUK TRACKING DRIVER
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;

  // Links
  static const String websiteUrl = 'https://delpick.horas-code.my.id';
  static const String supportEmail = 'support@delpick.com';
  static const String privacyPolicyUrl =
      'https://delpick.horas-code.my.id/privacy';
  static const String termsOfServiceUrl =
      'https://delpick.horas-code.my.id/terms';

  // Default placeholders - SESUAI BACKEND IMAGE PATHS
  static const String defaultAvatarUrl = 'https://via.placeholder.com/150';
  static const String defaultStoreImageUrl =
      'https://via.placeholder.com/300x200';
  static const String defaultFoodImageUrl =
      'https://via.placeholder.com/200x150';

  // Feature Flags
  static bool get enableBiometric => true;
  static bool get enablePushNotifications => true; // FCM sesuai backend
  static bool get enableLocationTracking => true; // Untuk driver tracking
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
