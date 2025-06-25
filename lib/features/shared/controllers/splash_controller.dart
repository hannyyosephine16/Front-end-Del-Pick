// lib/features/shared/controllers/splash_controller.dart (FIXED NAVIGATION FLOW)
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
      loadingText.value = 'Memeriksa status aplikasi...';
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize services
      loadingText.value = 'Menginisialisasi layanan...';
      await _initializeServices();

      // Check permissions
      loadingText.value = 'Memeriksa izin...';
      await _checkPermissions();

      // ✅ FIXED: Check onboarding first, then auth
      loadingText.value = 'Memuat...';
      await _checkNavigationFlow();
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
      print('Temporary data cleaned up');
    } catch (e) {
      print('Error cleaning up temporary data: $e');
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Request notification permission
      await _notificationService.requestPermission();

      // Check location permission status (don't request yet)
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

  // ✅ FIXED: Proper navigation flow check
  Future<void> _checkNavigationFlow() async {
    try {
      // 1. Check if this is first time opening the app
      final isFirstTime = _storageService.readBoolWithDefault(
          StorageConstants.isFirstTime, true);

      // 2. Check if user has seen onboarding
      final hasSeenOnboarding = _storageService.readBoolWithDefault(
          StorageConstants.hasSeenOnboarding, false);

      // 3. If first time OR hasn't seen onboarding, show onboarding
      if (isFirstTime || !hasSeenOnboarding) {
        print('First time user or onboarding not completed');
        _navigateToOnboarding();
        return;
      }

      // 4. User has seen onboarding, check authentication
      loadingText.value = 'Memeriksa autentikasi...';
      await _checkAuthStatus();
    } catch (e) {
      print('Error checking navigation flow: $e');
      _navigateToOnboarding();
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Check if user is logged in
      final isLoggedIn = _storageService.readBoolWithDefault(
          StorageConstants.isLoggedIn, false);
      final token = _storageService.readString(StorageConstants.authToken);

      if (isLoggedIn && token != null && token.isNotEmpty) {
        // Verify token with backend
        loadingText.value = 'Memverifikasi sesi...';
        final result = await _authRepository.getProfile();

        if (result.isSuccess && result.data != null) {
          // Token valid, update user data and navigate based on role
          _updateUserSession(result.data!);
          _navigateBasedOnRole(result.data!.role);
        } else {
          // Token invalid, clear session and navigate to login
          _clearInvalidSession();
          _navigateToLogin();
        }
      } else {
        // Not logged in, go to login
        _navigateToLogin();
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // On error, clear session and go to login
      _clearInvalidSession();
      _navigateToLogin();
    }
  }

  void _clearInvalidSession() {
    // Clear auth data
    _storageService.remove(StorageConstants.authToken);
    _storageService.remove(StorageConstants.refreshToken);
    _storageService.remove(StorageConstants.userId);
    _storageService.remove(StorageConstants.userRole);
    _storageService.remove(StorageConstants.userEmail);
    _storageService.remove(StorageConstants.userName);
    _storageService.remove(StorageConstants.userPhone);
    _storageService.remove(StorageConstants.userAvatar);
    _storageService.writeBool(StorageConstants.isLoggedIn, false);
  }

  void _updateUserSession(dynamic user) {
    // Update last login time
    _storageService.writeString(
        StorageConstants.lastLoginTime, DateTime.now().toIso8601String());

    // Update user data in storage
    _storageService.writeString(StorageConstants.userName, user.name);
    _storageService.writeString(StorageConstants.userEmail, user.email);
    _storageService.writeString(StorageConstants.userRole, user.role);

    if (user.phone != null) {
      _storageService.writeString(StorageConstants.userPhone, user.phone!);
    }
    if (user.avatar != null) {
      _storageService.writeString(StorageConstants.userAvatar, user.avatar!);
    }
  }

  // ✅ Navigation methods with proper flow
  void _navigateToOnboarding() {
    isLoading.value = false;
    print('Navigating to onboarding');
    Get.offAllNamed(Routes.ONBOARDING);
  }

  void _navigateToLogin() {
    isLoading.value = false;
    print('Navigating to login');
    Get.offAllNamed(Routes.LOGIN);
  }

  void _navigateBasedOnRole(String role) {
    isLoading.value = false;
    print('Navigating based on role: $role');

    switch (role.toLowerCase()) {
      case 'customer':
        Get.offAllNamed(Routes.CUSTOMER_HOME);
        break;
      case 'driver':
        Get.offAllNamed(Routes.DRIVER_MAIN);
        break;
      case 'store':
        Get.offAllNamed(Routes.STORE_DASHBOARD);
        break;
      default:
        print('Unknown role: $role, navigating to login');
        Get.offAllNamed(Routes.LOGIN);
    }
  }

  // Methods untuk handle app lifecycle
  void onAppResumed() {
    final sessionCount =
        _storageService.readIntWithDefault(StorageConstants.sessionCount, 0);
    print('App resumed - Session count: $sessionCount');
  }

  void onAppPaused() {
    print('App paused - Saving state');
  }
}
