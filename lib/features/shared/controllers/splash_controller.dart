// 1. lib/features/shared/controllers/splash_controller.dart (UPDATED)
import 'package:del_pick/app/config/storage_config.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/external/permission_service.dart';
import '../../../core/services/external/notification_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/services/local/storage_service.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final StorageService _storageService = Get.find<StorageService>();

  final RxBool isLoading = true.obs;
  final RxString loadingText = 'Memulai aplikasi...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate splash screen delay
      await Future.delayed(const Duration(seconds: 2));

      // Update loading text
      loadingText.value = 'Memeriksa koneksi...';
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize services
      loadingText.value = 'Menginisialisasi layanan...';
      await _initializeServices();

      // Check permissions
      loadingText.value = 'Memeriksa izin...';
      await _checkPermissions();

      // Check authentication status
      loadingText.value = 'Memeriksa autentikasi...';
      await _checkAuthStatus();
    } catch (e) {
      print('Error during initialization: $e');
      _navigateToOnboarding();
    }
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize analytics if enabled
      final analyticsEnabled = _storageService.readBoolWithDefault(
          StorageConstants.analyticsEnabled, true);

      if (analyticsEnabled) {
        // Initialize analytics service here if needed
        print('Analytics initialized');
      }

      // Update session count
      final sessionCount =
          _storageService.readIntWithDefault(StorageConstants.sessionCount, 0);
      await _storageService.writeInt(
          StorageConstants.sessionCount, sessionCount + 1);

      // Clean up expired cache if needed
      await _cleanupExpiredData();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  Future<void> _cleanupExpiredData() async {
    try {
      // Clear temporary data from previous session
      await _storageService.remove(StorageConstants.tempImagePath);
      await _storageService.remove(StorageConstants.tempOrderData);
      await _storageService.remove(StorageConstants.tempFilterSettings);
      await _storageService.remove(StorageConstants.tempSearchQuery);

      print('Temporary data cleaned up');
    } catch (e) {
      print('Error cleaning up temporary data: $e');
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Request notification permission
      await _notificationService.requestPermission();

      // Check location permission status
      final hasLocationPermission =
          await _permissionService.hasLocationPermission();
      await _storageService.writeBool(
          StorageConstants.locationPermissionGranted, hasLocationPermission);

      if (!hasLocationPermission) {
        print(
            'Location permission not granted, will request later when needed');
      }
    } catch (e) {
      print('Error checking permissions: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Check if this is first time opening the app
      final isFirstTime = _storageService.readBoolWithDefault(
          StorageConstants.isFirstTime, true);

      // Check if user has seen onboarding
      final hasSeenOnboarding = _storageService.readBoolWithDefault(
          StorageConstants.hasSeenOnboarding, false);

      // If first time or hasn't seen onboarding, show onboarding
      if (isFirstTime || !hasSeenOnboarding) {
        _navigateToOnboarding();
        return;
      }

      // Check if user is logged in
      final isLoggedIn = _storageService.readBoolWithDefault(
          StorageConstants.isLoggedIn, false);

      final token = _storageService.readString(StorageConstants.authToken);

      if (isLoggedIn && token != null && token.isNotEmpty) {
        // Verify token with backend
        loadingText.value = 'Memverifikasi sesi...';
        final result = await _authRepository.getProfile();

        result.fold(
          (failure) {
            // Token invalid, clear session and navigate to login
            _clearInvalidSession();
            _navigateToLogin();
          },
          (user) {
            // Token valid, update user data and navigate based on role
            _updateUserSession(user);
            _navigateBasedOnRole(user.role);
          },
        );
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      print('Error checking auth status: $e');
      _navigateToLogin();
    }
  }

  void _clearInvalidSession() {
    _storageService.clearLoginSession();
  }

  void _updateUserSession(dynamic user) {
    // Update last login time
    _storageService.writeString(
        StorageConstants.lastLoginTime, DateTime.now().toIso8601String());

    // Update user data in storage
    _storageService.writeInt(StorageConstants.userId, user.id);
    _storageService.writeString(StorageConstants.userName, user.name);
    _storageService.writeString(StorageConstants.userEmail, user.email);
    _storageService.writeString(StorageConstants.userRole, user.role);
    _storageService.writeString(StorageConstants.userPhone, user.phone ?? '');
    _storageService.writeString(StorageConstants.userAvatar, user.avatar ?? '');
  }

  void _navigateToOnboarding() {
    isLoading.value = false;
    Get.offAllNamed(Routes.ONBOARDING);
  }

  void _navigateToLogin() {
    isLoading.value = false;
    Get.offAllNamed(Routes.LOGIN);
  }

  void _navigateBasedOnRole(String role) {
    isLoading.value = false;

    // Clear last active tab when switching roles
    _storageService.remove(StorageKeys.lastActiveTab);

    switch (role.toLowerCase()) {
      case 'customer':
        Get.offAllNamed(Routes.CUSTOMER_HOME);
        break;
      case 'driver':
        // Check driver status and navigate accordingly
        _navigateToDriverHome();
        break;
      case 'store':
        // Check store status and navigate accordingly
        _navigateToStoreHome();
        break;
      default:
        print('Unknown role: $role, navigating to login');
        Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _navigateToDriverHome() {
    // Check if driver has set working hours
    final workingHoursStart =
        _storageService.readString(StorageConstants.workingHoursStart);
    final workingHoursEnd =
        _storageService.readString(StorageConstants.workingHoursEnd);

    if (workingHoursStart == null || workingHoursEnd == null) {
      // First time driver, might need to set up profile
      Get.offAllNamed(Routes.DRIVER_HOME);
    } else {
      Get.offAllNamed(Routes.DRIVER_HOME);
    }
  }

  void _navigateToStoreHome() {
    // Check if store has basic setup
    final storeName = _storageService.readString(StorageConstants.storeName);
    final storeOpenTime =
        _storageService.readString(StorageConstants.storeOpenTime);
    final storeCloseTime =
        _storageService.readString(StorageConstants.storeCloseTime);

    if (storeName == null || storeOpenTime == null || storeCloseTime == null) {
      // First time store, might need to set up profile
      Get.offAllNamed(Routes.PROFILE);
    } else {
      Get.offAllNamed(Routes.STORE_DASHBOARD);
    }
  }

  // Method to be called when app becomes active (for debugging)
  void onAppResumed() {
    final sessionCount =
        _storageService.readIntWithDefault(StorageConstants.sessionCount, 0);
    print('App resumed - Session count: $sessionCount');
  }

  // Method to handle app going to background
  void onAppPaused() {
    // Save any pending data
    print('App paused - Saving state');
  }
}
