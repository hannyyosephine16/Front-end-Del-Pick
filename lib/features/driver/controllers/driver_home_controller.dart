// lib/features/driver/controllers/driver_home_controller.dart - FIXED VERSION
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/core/constants/driver_status_constants.dart';
import 'package:del_pick/core/utils/custom_snackbar.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

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
  final RxString _currentStatus = DriverStatusConstants.inactive.obs;
  final RxInt _todayDeliveries = 0.obs;
  final RxDouble _todayEarnings = 0.0.obs;
  final RxDouble _todayDistance = 0.0.obs;
  final RxDouble _rating = 0.0.obs;
  final RxList<String> _validTransitions = <String>[].obs;
  final RxBool _hasActiveOrders = false.obs;
  final RxInt _activeOrderCount = 0.obs;

  // ========================================================================
  // Getters
  // ========================================================================

  bool get isOnline => _isOnline.value;
  bool get isUpdatingStatus => _isUpdatingStatus.value;
  String get currentStatus => _currentStatus.value;
  int get todayDeliveries => _todayDeliveries.value;
  double get todayEarnings => _todayEarnings.value;
  double get todayDistance => _todayDistance.value;
  double get rating => _rating.value;
  List<String> get validTransitions => _validTransitions;
  bool get hasActiveOrders => _hasActiveOrders.value;
  int get activeOrderCount => _activeOrderCount.value;

  // ========================================================================
  // Computed Properties
  // ========================================================================

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
  // Lifecycle
  // ========================================================================

  @override
  void onInit() {
    super.onInit();
    loadDriverStatus();
    loadDailyStats();
  }

  // ========================================================================
  // Main Toggle Method
  // ========================================================================

  Future<void> toggleDriverStatus() async {
    if (!canToggleStatus) {
      _showCannotToggleMessage();
      return;
    }

    try {
      _isUpdatingStatus.value = true;

      // Determine target status
      final targetStatus = isOnline
          ? DriverStatusConstants.inactive
          : DriverStatusConstants.active;

      // Validate transition
      if (!validTransitions.contains(targetStatus)) {
        CustomSnackbar.showError(
          title: 'Error',
          message:
              'Cannot change status to ${DriverStatusConstants.getDriverStatusName(targetStatus)}',
        );
        return;
      }

      // Check location permission for going online
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

      // Update status in backend
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

        // Start location updates if going online
        if (targetStatus == DriverStatusConstants.active) {
          locationService.startLocationUpdates();
        } else {
          locationService.stopLocationUpdates();
        }

        // Refresh status info
        await loadDriverStatus();
      } else {
        // Handle business rule errors
        _handleStatusUpdateError(result.message ?? 'Failed to update status');
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update status: ${e.toString()}',
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  // ========================================================================
  // Helper Methods
  // ========================================================================

  Future<void> loadDriverStatus() async {
    try {
      final result = await driverRepository.getDriverStatusInfo();

      if (result.isSuccess && result.data != null) {
        final statusData = result.data!;

        _currentStatus.value =
            statusData['current'] ?? DriverStatusConstants.inactive;
        _isOnline.value = _currentStatus.value == DriverStatusConstants.active;
        _validTransitions.value =
            List<String>.from(statusData['canTransitionTo'] ?? []);
        _hasActiveOrders.value = statusData['hasActiveOrders'] ?? false;
        _activeOrderCount.value = statusData['activeOrderCount'] ?? 0;
      }
    } catch (e) {
      print('Error loading driver status: $e');
    }
  }

  Future<void> loadDailyStats() async {
    try {
      // Simulate loading daily stats - replace with real API call
      _todayDeliveries.value = 8;
      _todayEarnings.value = 125000;
      _todayDistance.value = 45.2;
      _rating.value = 4.8;
    } catch (e) {
      print('Error loading daily stats: $e');
    }
  }

  Future<bool> _checkLocationPermission() async {
    try {
      return await locationService.checkPermission();
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  void _handleStatusUpdateError(String errorMessage) {
    // Handle specific error types
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
    } else {
      CustomSnackbar.showError(
        title: 'Status Update Failed',
        message: errorMessage,
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

  void refreshStatus() {
    loadDriverStatus();
    loadDailyStats();
  }

  void goToEarnings() {
    Get.toNamed('/driver/earnings');
  }

  void goToOrders() {
    Get.toNamed('/driver/orders');
  }

  void goToMap() {
    Get.toNamed('/driver/map');
  }

  // ========================================================================
  // Legacy Support (for backward compatibility)
  // ========================================================================

  void toggleOnlineStatus() {
    toggleDriverStatus();
  }
}
