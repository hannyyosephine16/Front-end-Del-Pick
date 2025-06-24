// lib/features/shared/controllers/splash_controller.dart - OPTIMIZED untuk struktur existing
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // ✅ Observable states untuk UI feedback
  final RxBool isLoading = true.obs;
  final RxString loadingMessage = 'Initializing...'.obs;
  final RxDouble loadingProgress = 0.0.obs;

  Timer? _timeoutTimer;
  Timer? _progressTimer;
  final int maxInitializationTime = 10; // seconds

  @override
  void onInit() {
    super.onInit();
    // ✅ Menggunakan microtask untuk avoid blocking main thread
    scheduleMicrotask(() => _initializeApp());
  }

  Future<void> _initializeApp() async {
    try {
      // ✅ Set timeout protection
      _setInitializationTimeout();

      // ✅ Start progress animation
      _startProgressAnimation();

      loadingMessage.value = 'Loading services...';
      loadingProgress.value = 0.1;

      // ✅ OPTIMIZED: Parallel execution untuk non-dependent operations
      await Future.wait([
        _minimumSplashDuration(), // UX minimum duration
        _initializeCoreServices(),
      ]);

      loadingMessage.value = 'Checking authentication...';
      loadingProgress.value = 0.6;

      // ✅ Check authentication setelah services ready
      await _checkAuthenticationStatus();

      loadingProgress.value = 1.0;
    } catch (e) {
      debugPrint('❌ Error initializing app: $e');
      _handleInitializationError(e);
    } finally {
      _cleanup();
    }
  }

  // ✅ OPTIMIZED: Minimum splash duration untuk UX
  Future<void> _minimumSplashDuration() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  // ✅ OPTIMIZED: Initialize services efficiently
  Future<void> _initializeCoreServices() async {
    try {
      // ✅ Storage service sudah di-init dari GetStorage.init() di onInit
      // Pastikan storage berfungsi dengan test read
      final testKey = 'app_init_test';
      await _storageService.writeString(testKey, 'test');
      final testValue = _storageService.readString(testKey);

      if (testValue != 'test') {
        throw Exception('Storage service not working properly');
      }

      // Clean up test data
      await _storageService.remove(testKey);

      // ✅ Clear expired cache to free up space
      await _storageService.clearExpiredCache();

      // ✅ Update app version tracking
      await _updateAppVersionTracking();

      debugPrint('✅ Core services initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing services: $e');
      rethrow;
    }
  }

  // ✅ Update app version for tracking
  Future<void> _updateAppVersionTracking() async {
    try {
      const currentVersion = '1.0.0'; // Ganti dengan actual app version
      final lastVersion =
          _storageService.readString(StorageConstants.lastAppVersion);

      if (lastVersion != currentVersion) {
        await _storageService.writeString(
            StorageConstants.currentAppVersion, currentVersion);
        await _storageService.writeString(
            StorageConstants.lastAppVersion, currentVersion);

        if (lastVersion == null) {
          // First time install
          await _storageService.writeDateTime(
              StorageConstants.installDate, DateTime.now());
        } else {
          // App update
          await _storageService.writeDateTime(
              StorageConstants.lastUpdateDate, DateTime.now());
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating app version: $e');
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      // ✅ OPTIMIZED: Single read untuk semua auth data
      final authData = _getStoredAuthData();

      if (_isValidAuthData(authData)) {
        loadingMessage.value = 'Welcome back!';

        // ✅ Update last login time
        await _storageService.writeDateTime(
            StorageConstants.lastLoginTime, DateTime.now());

        // ✅ Navigate based on role
        await _navigateBasedOnRole(authData['userRole']);
      } else {
        loadingMessage.value = 'Please login';
        await _clearInvalidAuthAndNavigate();
      }
    } catch (e) {
      debugPrint('❌ Error checking auth status: $e');
      await _clearInvalidAuthAndNavigate();
    }
  }

  // ✅ OPTIMIZED: Single storage read untuk semua auth data menggunakan existing methods
  Map<String, dynamic> _getStoredAuthData() {
    return {
      'isLoggedIn': _storageService.readBoolWithDefault(
          StorageConstants.isLoggedIn, false),
      'token': _storageService.readString(StorageConstants.authToken),
      'userRole': _storageService.readString(StorageConstants.userRole),
      'userId': _storageService.readString(StorageConstants.userId),
      'userEmail': _storageService.readString(StorageConstants.userEmail),
      'userName': _storageService.readString(StorageConstants.userName),
    };
  }

  // ✅ OPTIMIZED: Efficient validation
  bool _isValidAuthData(Map<String, dynamic> authData) {
    return authData['isLoggedIn'] == true &&
        authData['token'] != null &&
        authData['token'].toString().isNotEmpty &&
        authData['userRole'] != null &&
        ['customer', 'driver', 'store'].contains(authData['userRole']) &&
        authData['userId'] != null &&
        authData['userId'].toString().isNotEmpty;
  }

  Future<void> _navigateBasedOnRole(String? userRole) async {
    try {
      loadingMessage.value = 'Loading dashboard...';

      // ✅ Small delay untuk smooth transition
      await Future.delayed(const Duration(milliseconds: 300));

      switch (userRole) {
        case 'customer':
          await Get.offAllNamed(Routes.CUSTOMER_HOME);
          break;
        case 'driver':
          await Get.offAllNamed(Routes.DRIVER_MAIN);
          break;
        case 'store':
          await Get.offAllNamed(Routes.STORE_DASHBOARD);
          break;
        default:
          debugPrint('⚠️ Unknown user role: $userRole');
          await _clearInvalidAuthAndNavigate();
      }
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      await _clearInvalidAuthAndNavigate();
    }
  }

  Future<void> _clearInvalidAuthAndNavigate() async {
    try {
      // ✅ Clear semua auth-related data menggunakan batch operation
      final authKeys = [
        StorageConstants.authToken,
        StorageConstants.refreshToken,
        StorageConstants.userId,
        StorageConstants.userRole,
        StorageConstants.userEmail,
        StorageConstants.userName,
        StorageConstants.userPhone,
        StorageConstants.userAvatar,
        StorageConstants.isLoggedIn,
      ];

      await _storageService.removeBatch(authKeys);

      // ✅ Navigate to login
      await Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint('❌ Error clearing auth data: $e');
      // ✅ Force navigate to login even if clearing fails
      await Get.offAllNamed(Routes.LOGIN);
    }
  }

  // ✅ Progress animation untuk better UX
  void _startProgressAnimation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (loadingProgress.value < 0.5) {
        loadingProgress.value += 0.02;
      }
    });
  }

  // ✅ Timeout protection
  void _setInitializationTimeout() {
    _timeoutTimer = Timer(Duration(seconds: maxInitializationTime), () {
      if (isLoading.value) {
        debugPrint('⚠️ Initialization timeout, forcing navigation to login');
        _handleInitializationError('Initialization timeout');
      }
    });
  }

  void _handleInitializationError(dynamic error) {
    isLoading.value = false;
    loadingMessage.value = 'Loading failed';
    loadingProgress.value = 0.0;

    // ✅ Log error for debugging
    debugPrint('❌ Initialization error: $error');

    // ✅ Navigate to login dengan delay untuk user feedback
    Timer(const Duration(milliseconds: 1000), () {
      Get.offAllNamed(Routes.LOGIN);
    });
  }

  // ✅ Cleanup resources
  void _cleanup() {
    _timeoutTimer?.cancel();
    _progressTimer?.cancel();
    isLoading.value = false;
  }

  // ✅ Emergency navigation methods
  void forceNavigateToLogin() {
    _cleanup();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> retryInitialization() async {
    isLoading.value = true;
    loadingProgress.value = 0.0;
    loadingMessage.value = 'Retrying...';

    await _initializeApp();
  }

  // ✅ Utility methods untuk debugging
  Map<String, dynamic> getStorageInfo() {
    return {
      'storageSize': _storageService.getStorageSize(),
      'isEmpty': _storageService.isEmpty(),
      'hasAuthToken': _storageService.hasData(StorageConstants.authToken),
      'userRole': _storageService.readString(StorageConstants.userRole),
      'lastLogin': _storageService
          .readDateTime(StorageConstants.lastLoginTime)
          ?.toIso8601String(),
    };
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }
}
