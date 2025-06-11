// lib/features/driver/controllers/driver_home_controller.dart - DENGAN AUTH DEBUG
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/core/constants/driver_status_constants.dart';
import 'package:del_pick/core/utils/custom_snackbar.dart';
import 'package:del_pick/core/utils/auth_debug.dart'; // Import auth debug
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';

class DriverHomeController extends GetxController {
  final DriverRepository driverRepository;
  final OrderRepository orderRepository;
  final LocationService locationService;

  DriverHomeController({
    required this.driverRepository,
    required this.orderRepository,
    required this.locationService,
  });

  // ========================================================================
  // Observable Variables
  // ========================================================================

  final RxBool _isOnline = false.obs;
  final RxBool _isUpdatingStatus = false.obs;
  final RxBool _isLoading = true.obs;
  final RxString _currentStatus = DriverStatusConstants.inactive.obs;
  final RxInt _todayDeliveries = 0.obs;
  final RxDouble _todayEarnings = 0.0.obs;
  final RxDouble _todayDistance = 0.0.obs;
  final RxDouble _rating = 0.0.obs;
  final RxList<String> _validTransitions = <String>[].obs;
  final RxBool _hasActiveOrders = false.obs;
  final RxInt _activeOrderCount = 0.obs;
  final RxString _errorMessage = ''.obs;

  // ========================================================================
  // Getters (unchanged)
  // ========================================================================

  bool get isOnline => _isOnline.value;
  bool get isUpdatingStatus => _isUpdatingStatus.value;
  bool get isLoading => _isLoading.value;
  String get currentStatus => _currentStatus.value;
  int get todayDeliveries => _todayDeliveries.value;
  double get todayEarnings => _todayEarnings.value;
  double get todayDistance => _todayDistance.value;
  double get rating => _rating.value;
  List<String> get validTransitions => _validTransitions;
  bool get hasActiveOrders => _hasActiveOrders.value;
  int get activeOrderCount => _activeOrderCount.value;
  String get errorMessage => _errorMessage.value;

  bool get canToggleStatus {
    return !isUpdatingStatus &&
        !hasActiveOrders &&
        currentStatus != DriverStatusConstants.busy;
  }

  String get formattedTodayEarnings {
    return 'Rp ${todayEarnings.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get formattedTodayDistance {
    return '${todayDistance.toStringAsFixed(1)} km';
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  Map<String, dynamic> get statusDisplayInfo {
    switch (currentStatus) {
      case DriverStatusConstants.active:
        return {
          'text': 'Online',
          'description': 'Siap menerima pesanan',
          'color': AppColors.success,
        };
      case DriverStatusConstants.busy:
        return {
          'text': 'Busy',
          'description': 'Sedang mengantarkan pesanan',
          'color': AppColors.warning,
        };
      case DriverStatusConstants.inactive:
      default:
        return {
          'text': 'Offline',
          'description': 'Tidak menerima pesanan',
          'color': AppColors.textSecondary,
        };
    }
  }

  // ========================================================================
  // Lifecycle dengan Auth Debug
  // ========================================================================

  @override
  void onInit() {
    super.onInit();

    // Debug auth state di development mode
    if (kDebugMode) {
      _runAuthDebug();
    }

    initializeDriver();
  }

  /// Run comprehensive auth debugging
  Future<void> _runAuthDebug() async {
    print('\n🚀 === DRIVER CONTROLLER INIT DEBUG ===');

    // 1. Print current auth state
    await AuthDebug.printCurrentAuthState();

    // 2. Validate driver auth
    final isValidAuth = await AuthDebug.validateDriverAuth();
    if (!isValidAuth) {
      print('⚠️ WARNING: Driver auth validation failed');
    }

    // 3. Sync auth token to ApiService
    await AuthDebug.syncAuthToken();

    // 4. Print API headers
    await AuthDebug.printApiHeaders();

    // 5. Test auth token dengan API call
    await AuthDebug.testAuthToken();

    print('=== END DRIVER CONTROLLER INIT DEBUG ===\n');
  }

  // ========================================================================
  // Initialization Method
  // ========================================================================

  Future<void> initializeDriver() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      print('🔄 Initializing driver...');

      // Validate auth sebelum melakukan API calls
      if (kDebugMode) {
        final isValidAuth = await AuthDebug.validateDriverAuth();
        if (!isValidAuth) {
          print('❌ Auth validation failed during initialization');
          _handleAuthError();
          return;
        }
      }

      // Load driver data
      await Future.wait([
        loadDriverProfile(),
        loadDailyStats(),
        loadActiveOrderCount(),
      ]);

      print('✅ Driver initialization completed');
    } catch (e) {
      _errorMessage.value = 'Failed to initialize: ${e.toString()}';
      print('❌ Error initializing driver: $e');

      // Debug error jika dalam development mode
      if (kDebugMode) {
        print('\n🔍 === INITIALIZATION ERROR DEBUG ===');
        await AuthDebug.printCurrentAuthState();
        print('=== END ERROR DEBUG ===\n');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  // ========================================================================
  // Data Loading Methods
  // ========================================================================

  /// Load driver profile - ENDPOINT: GET /auth/profile
  Future<void> loadDriverProfile() async {
    try {
      print('📡 Loading driver profile...');

      final result = await driverRepository.getDriverProfile();

      if (result.isSuccess && result.data != null) {
        final profileData = result.data!;

        // Extract driver info from profile response
        final driverData = profileData['driver'] as Map<String, dynamic>?;
        final userData = profileData['user'] as Map<String, dynamic>?;

        if (driverData != null) {
          // Update driver-specific state
          _currentStatus.value =
              driverData['status'] ?? DriverStatusConstants.inactive;
          _isOnline.value =
              _currentStatus.value == DriverStatusConstants.active;
          _rating.value = (driverData['rating'] ?? 0.0).toDouble();

          // Set valid transitions based on current status
          _validTransitions.value = driverRepository.isValidStatusTransition(
            _currentStatus.value,
            DriverStatusConstants.active,
          )
              ? [DriverStatusConstants.active]
              : [DriverStatusConstants.inactive];

          print('✅ Driver profile loaded successfully');
          print('   Current status: ${_currentStatus.value}');
          print('   Rating: ${_rating.value}');
        }

        if (userData != null) {
          print('   User: ${userData['name']} (${userData['email']})');
        }

        _errorMessage.value = '';
      } else {
        print('⚠️ API Error, using default values: ${result.errorMessage}');
        _handleLoadError('profile', result.errorMessage);
      }
    } catch (e) {
      print('💥 Exception in loadDriverProfile: $e');
      _handleLoadError('profile', e.toString());

      // Debug error lebih detail
      if (kDebugMode) {
        print('\n🔍 === PROFILE LOAD ERROR DEBUG ===');
        await AuthDebug.testAuthToken();
        print('=== END PROFILE ERROR DEBUG ===\n');
      }
    }
  }

  /// Load daily stats - DUMMY DATA untuk sementara
  Future<void> loadDailyStats() async {
    try {
      print('📊 Loading daily stats...');

      // Untuk sementara menggunakan dummy data
      await Future.delayed(Duration(milliseconds: 300));

      _todayDeliveries.value = 8;
      _todayEarnings.value = 125000;
      _todayDistance.value = 45.2;

      print('✅ Daily stats loaded (dummy data)');
    } catch (e) {
      print('❌ Error loading daily stats: $e');
      _todayDeliveries.value = 0;
      _todayEarnings.value = 0.0;
      _todayDistance.value = 0.0;
    }
  }

  /// Load active order count - ENDPOINT: GET /drivers/orders dengan filter
  Future<void> loadActiveOrderCount() async {
    try {
      print('📋 Loading active order count...');

      final result = await orderRepository.getDriverActiveOrderCount();

      if (result.isSuccess) {
        _activeOrderCount.value = result.data ?? 0;
        _hasActiveOrders.value = _activeOrderCount.value > 0;
        print('✅ Active order count loaded: ${_activeOrderCount.value}');
      } else {
        print('⚠️ Failed to load active order count: ${result.errorMessage}');
        _activeOrderCount.value = 0;
        _hasActiveOrders.value = false;

        // Debug specific error
        if (result.errorMessage.contains('403') && kDebugMode) {
          print('\n🔍 === ORDER COUNT 403 ERROR DEBUG ===');
          print('This might be an endpoint permission issue');
          await AuthDebug.testAuthToken();
          print('=== END ORDER COUNT ERROR DEBUG ===\n');
        }
      }
    } catch (e) {
      print('💥 Exception in loadActiveOrderCount: $e');
      _activeOrderCount.value = 0;
      _hasActiveOrders.value = false;
    }
  }

  void _handleLoadError(String dataType, String error) {
    _errorMessage.value = 'Failed to load $dataType: $error';
    print('❌ Error loading $dataType: $error');

    // Set safe defaults berdasarkan error type
    if (error.contains('Authentication') || error.contains('401')) {
      _handleAuthError();
    } else if (error.contains('403') || error.contains('Access denied')) {
      CustomSnackbar.showError(
        title: 'Access Error',
        message: 'Driver access not authorized. Please contact support.',
      );
      // Set basic defaults untuk akses ditolak
      _currentStatus.value = DriverStatusConstants.inactive;
      _isOnline.value = false;
      _validTransitions.value = [];
    } else if (error.contains('Driver tidak ditemukan') ||
        error.contains('404')) {
      CustomSnackbar.showError(
        title: 'Driver Not Found',
        message: 'Driver profile not found in system. Please contact admin.',
      );
      // Set defaults untuk driver tidak ditemukan
      _currentStatus.value = DriverStatusConstants.inactive;
      _isOnline.value = false;
      _validTransitions.value = [];
    } else {
      // Default error handling
      _currentStatus.value = DriverStatusConstants.inactive;
      _isOnline.value = false;
      _validTransitions.value = [DriverStatusConstants.active];
    }
  }

  void _handleAuthError() {
    CustomSnackbar.showError(
      title: 'Session Expired',
      message: 'Please login again',
    );

    // Clear auth data dan redirect ke login
    if (kDebugMode) {
      AuthDebug.clearAuthData();
    }

    Get.offAllNamed('/login');
  }

  // ========================================================================
  // Status Toggle Method - ENDPOINT: PUT /drivers/status
  // ========================================================================

  Future<void> toggleDriverStatus() async {
    if (!canToggleStatus) {
      _showCannotToggleMessage();
      return;
    }

    try {
      _isUpdatingStatus.value = true;
      print('🔄 Toggling driver status...');

      // Determine target status
      final targetStatus = isOnline
          ? DriverStatusConstants.inactive
          : DriverStatusConstants.active;

      print('   Current: ${currentStatus} → Target: $targetStatus');

      // Validate transition (client-side)
      if (!driverRepository.isValidStatusTransition(
          currentStatus, targetStatus)) {
        CustomSnackbar.showError(
          title: 'Error',
          message:
              'Cannot change status to ${DriverStatusConstants.getDriverStatusName(targetStatus)}',
        );
        return;
      }

      // Check location permission untuk going online
      if (targetStatus == DriverStatusConstants.active) {
        final hasLocation = await _checkLocationPermission();
        if (!hasLocation) {
          CustomSnackbar.showError(
            title: 'Location Required',
            message: 'Please enable location permission to go online',
          );
          return;
        }
      }

      // Update status menggunakan endpoint yang benar: PUT /drivers/status
      final result = await driverRepository.updateDriverStatus({
        'status': targetStatus,
      });

      if (result.isSuccess) {
        // Update local state
        _currentStatus.value = targetStatus;
        _isOnline.value = targetStatus == DriverStatusConstants.active;

        // Show success message
        CustomSnackbar.showSuccess(
          title: 'Status Updated',
          message:
              'You are now ${DriverStatusConstants.getDriverStatusName(targetStatus)}',
        );

        // Start/stop location updates
        if (targetStatus == DriverStatusConstants.active) {
          locationService.startLocationUpdates();
        } else {
          locationService.stopLocationUpdates();
        }

        // Refresh profile info
        await loadDriverProfile();

        print('✅ Status updated successfully to: $targetStatus');
      } else {
        print('❌ Status update failed: ${result.errorMessage}');
        _handleStatusUpdateError(result.errorMessage);

        // Debug status update error
        if (kDebugMode) {
          print('\n🔍 === STATUS UPDATE ERROR DEBUG ===');
          await AuthDebug.testAuthToken();
          print('=== END STATUS UPDATE ERROR DEBUG ===\n');
        }
      }
    } catch (e) {
      print('💥 Exception in toggleDriverStatus: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update status: ${e.toString()}',
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  // ========================================================================
  // Helper Methods (unchanged)
  // ========================================================================

  Future<bool> _checkLocationPermission() async {
    try {
      return await locationService.checkPermission();
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  void _handleStatusUpdateError(String errorMessage) {
    if (errorMessage.contains('CANNOT_OFFLINE_DURING_DELIVERY')) {
      CustomSnackbar.showError(
        title: 'Cannot Go Offline',
        message: 'Please complete your current delivery first',
      );
    } else if (errorMessage.contains('CANNOT_OFFLINE_WITH_ACTIVE_ORDERS')) {
      CustomSnackbar.showError(
        title: 'Active Orders',
        message: 'Complete $activeOrderCount active orders first',
      );
    } else if (errorMessage.contains('LOCATION_PERMISSION_REQUIRED')) {
      CustomSnackbar.showError(
        title: 'Location Required',
        message: 'Please enable location permission to go online',
      );
    } else if (errorMessage.contains('Authentication') ||
        errorMessage.contains('401')) {
      _handleAuthError();
    } else if (errorMessage.contains('403')) {
      CustomSnackbar.showError(
        title: 'Access Denied',
        message: 'You do not have permission to change status',
      );
    } else if (errorMessage.contains('404')) {
      CustomSnackbar.showError(
        title: 'Driver Not Found',
        message: 'Driver profile not found. Please contact admin.',
      );
    } else {
      CustomSnackbar.showError(
        title: 'Status Update Failed',
        message:
            errorMessage.isNotEmpty ? errorMessage : 'Unknown error occurred',
      );
    }
  }

  void _showCannotToggleMessage() {
    String message = 'Cannot change status right now';

    if (isUpdatingStatus) {
      message = 'Status update in progress...';
    } else if (hasActiveOrders) {
      message = 'Complete $activeOrderCount active orders first';
    } else if (currentStatus == DriverStatusConstants.busy) {
      message = 'Complete current delivery first';
    }

    CustomSnackbar.showWarning(
      title: 'Cannot Toggle Status',
      message: message,
    );
  }

  // ========================================================================
  // Public Methods for UI
  // ========================================================================

  Future<void> refreshStatus() async {
    print('🔄 Manual refresh requested');
    await initializeDriver();
  }

  void retryInitialization() {
    print('🔄 Retry initialization requested');
    initializeDriver();
  }

  /// Debug method untuk UI - hanya di development mode
  Future<void> debugAuth() async {
    if (kDebugMode) {
      await _runAuthDebug();
    }
  }

  void goToEarnings() {
    Get.toNamed('/driver/earnings');
  }

  void goToOrders() {
    Get.toNamed(Routes.DRIVER_ORDERS);
  }

  void goToMap() {
    Get.toNamed(Routes.DRIVER_MAP);
  }

  void goToProfile() {
    Get.toNamed(Routes.DRIVER_PROFILE);
  }

  // ========================================================================
  // Legacy Support
  // ========================================================================

  void toggleOnlineStatus() {
    toggleDriverStatus();
  }

  @Deprecated('Use loadDriverProfile() instead')
  Future<void> loadDriverStatus() async {
    await loadDriverProfile();
  }
}
