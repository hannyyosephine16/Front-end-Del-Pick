// lib/features/driver/controllers/driver_home_controller.dart - Updated with Models
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/driver/driver_status_model.dart'; // New import
import 'package:del_pick/core/constants/driver_status_constants.dart';
import 'package:del_pick/core/utils/custom_snackbar.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'dart:async';

import '../../../data/models/driver/driver_status_change_response.dart';
import '../../../data/models/driver/driver_status_error_model.dart';

class DriverHomeController extends GetxController {
  final DriverRepository driverRepository;
  final OrderRepository orderRepository;
  final LocationService locationService;
  final StorageService storageService;

  DriverHomeController({
    required this.driverRepository,
    required this.orderRepository,
    required this.locationService,
    required this.storageService,
  });

  // Observables - Updated dengan models
  final Rx<DriverModel?> _driver = Rx<DriverModel?>(null);
  final Rx<DriverStatusModel?> _driverStatus = Rx<DriverStatusModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isUpdatingStatus = false.obs;
  final RxDouble _todayEarnings = 0.0.obs;
  final RxInt _todayDeliveries = 0.obs;
  final RxDouble _todayDistance = 0.0.obs;
  final RxDouble _rating = 0.0.obs;
  final RxBool _locationPermissionGranted = false.obs;

  Timer? _locationUpdateTimer;

  // Getters - Updated
  DriverModel? get driver => _driver.value;
  DriverStatusModel? get driverStatus => _driverStatus.value;
  bool get isLoading => _isLoading.value;
  bool get isUpdatingStatus => _isUpdatingStatus.value;
  String get currentStatus =>
      _driverStatus.value?.status ?? DriverStatusConstants.inactive;
  double get todayEarnings => _todayEarnings.value;
  int get todayDeliveries => _todayDeliveries.value;
  double get todayDistance => _todayDistance.value;
  double get rating => _rating.value;
  bool get locationPermissionGranted => _locationPermissionGranted.value;

  // Status checks using models
  bool get isOnline => _driverStatus.value?.isActive ?? false;
  bool get isOffline => _driverStatus.value?.isInactive ?? true;
  bool get isBusy => _driverStatus.value?.isBusy ?? false;
  bool get canToggleStatus =>
      (_driverStatus.value?.canToggleStatus ?? false) && !isUpdatingStatus;

  // New getters menggunakan models
  bool get canGoOnline => _driverStatus.value?.canGoOnline ?? false;
  bool get canGoOffline => _driverStatus.value?.canGoOffline ?? false;
  bool get hasActiveOrders => _driverStatus.value?.hasActiveOrders ?? false;
  int get activeOrderCount => _driverStatus.value?.activeOrderCount ?? 0;
  String get blockingReason => _driverStatus.value?.blockingReason ?? '';
  List<String> get validTransitions =>
      _driverStatus.value?.validTransitions ?? [];

  @override
  void onInit() {
    super.onInit();
    _initializeDriver();
  }

  @override
  void onReady() {
    super.onReady();
    if (isOnline) {
      _startLocationUpdates();
    }
  }

  @override
  void onClose() {
    _stopLocationUpdates();
    super.onClose();
  }

  /// Initialize driver data dengan status info
  Future<void> _initializeDriver() async {
    try {
      _isLoading.value = true;

      _locationPermissionGranted.value =
          await locationService.checkPermission();

      // Load driver profile dan status info
      await Future.wait([
        _loadDriverProfile(),
        _loadDriverStatusInfo(),
        _loadTodayStats(),
      ]);

      // Listen to status changes
      ever(_driverStatus, _handleStatusChange);
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to initialize driver data: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load driver profile
  Future<void> _loadDriverProfile() async {
    try {
      final userId = storageService.readInt('user_id') ?? 1;
      final result = await driverRepository.getDriverById(userId);

      if (result.isSuccess && result.data != null) {
        _driver.value = result.data!;
        _rating.value = result.data!.rating;
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to load driver profile',
        );
      }
    } catch (e) {
      print('Error loading driver profile: $e');
    }
  }

  /// Load driver status info dari backend
  Future<void> _loadDriverStatusInfo() async {
    try {
      final result = await driverRepository.getDriverStatusInfo();

      if (result.isSuccess && result.data != null) {
        // Parse response ke DriverStatusModel
        final statusData = result.data!['statusInfo'] as Map<String, dynamic>;
        _driverStatus.value = DriverStatusModel.fromJson(statusData);

        // Save status ke local storage
        await storageService.writeString('driver_status', currentStatus);
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to load driver status',
        );
      }
    } catch (e) {
      print('Error loading driver status: $e');
    }
  }

  /// Load today's statistics
  Future<void> _loadTodayStats() async {
    try {
      // TODO: Replace dengan actual API call
      _todayEarnings.value = 125000.0;
      _todayDeliveries.value = 8;
      _todayDistance.value = 45.0;
    } catch (e) {
      print('Error loading today stats: $e');
    }
  }

  /// Toggle driver status dengan model-based validation
  Future<void> toggleDriverStatus() async {
    if (!canToggleStatus) {
      // Show specific blocking reason
      if (blockingReason.isNotEmpty) {
        CustomSnackbar.showWarning(
          title: 'Cannot Change Status',
          message: blockingReason,
        );
      }
      return;
    }

    try {
      _isUpdatingStatus.value = true;

      // Determine new status berdasarkan valid transitions
      String? newStatus;
      if (isOnline && canGoOffline) {
        newStatus = DriverStatusConstants.inactive;
      } else if (isOffline && canGoOnline) {
        newStatus = DriverStatusConstants.active;
      }

      if (newStatus == null) {
        CustomSnackbar.showError(
          title: 'Invalid Transition',
          message: 'No valid status transition available',
        );
        return;
      }

      // Check location permission for going online
      if (newStatus == DriverStatusConstants.active) {
        final hasLocationPermission =
            await _checkAndRequestLocationPermission();
        if (!hasLocationPermission) {
          return;
        }
      }

      // Update status via repository
      final result = await driverRepository.updateDriverStatus({
        'status': newStatus,
      });

      if (result.isSuccess && result.data != null) {
        // Parse response sebagai DriverStatusChangeResponse
        final response = DriverStatusChangeResponse.fromJson(result.data!);

        // Update driver model
        final updatedDriver = DriverModel.fromJson(result.data!['driver']);
        _driver.value = updatedDriver;

        // Reload status info untuk mendapatkan valid transitions terbaru
        await _loadDriverStatusInfo();

        // Show success message
        CustomSnackbar.showSuccess(
          title: response.statusChange.title ?? 'Status Updated',
          message: response.message,
        );
      } else {
        // Handle error dengan model
        _handleStatusUpdateError(
            result.message ?? 'Failed to update status', result.data);
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'An error occurred while updating status: $e',
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  /// Handle status update error menggunakan model
  void _handleStatusUpdateError(
      String message, Map<String, dynamic>? errorData) {
    if (errorData != null && errorData.containsKey('businessRule')) {
      final errorModel = DriverStatusErrorModel.fromJson(errorData);

      CustomSnackbar.showError(
        title: 'Cannot Change Status',
        message: errorModel.userFriendlyMessage,
        duration: Duration(seconds: errorModel.isRateLimited ? 5 : 4),
      );

      // Handle specific business rules
      if (errorModel.isRateLimited && errorModel.waitTime != null) {
        // Bisa tambahkan countdown timer di UI
        _startRateLimitCountdown(errorModel.waitTime!);
      }
    } else {
      CustomSnackbar.showError(
        title: 'Update Failed',
        message: message,
      );
    }
  }

  /// Start countdown untuk rate limiting
  void _startRateLimitCountdown(int seconds) {
    // Implementasi countdown timer jika diperlukan
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick >= seconds) {
        timer.cancel();
        // Refresh status info setelah rate limit selesai
        _loadDriverStatusInfo();
      }
    });
  }

  /// Check location permission
  Future<bool> _checkAndRequestLocationPermission() async {
    final hasPermission = await locationService.checkPermission();
    _locationPermissionGranted.value = hasPermission;

    if (!hasPermission) {
      CustomSnackbar.showAction(
        title: 'Location Permission Required',
        message: 'Please enable location access in app settings',
        actionLabel: 'Open Settings',
        onActionPressed: () {
          // TODO: Open app settings
        },
      );
    }

    return hasPermission;
  }

  /// Handle status change side effects
  Future<void> _handleStatusChange(DriverStatusModel? newStatusModel) async {
    if (newStatusModel == null) return;

    if (newStatusModel.isActive) {
      await _startLocationUpdates();
    } else {
      _stopLocationUpdates();
    }
  }

  /// Start location updates
  Future<void> _startLocationUpdates() async {
    if (!isOnline || !locationPermissionGranted) return;

    try {
      await locationService.startLocationUpdates();

      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _updateDriverLocation(),
      );

      await _updateDriverLocation();
    } catch (e) {
      print('Error starting location updates: $e');
      CustomSnackbar.showError(
        title: 'Location Error',
        message: 'Failed to start location updates',
      );
    }
  }

  /// Stop location updates
  void _stopLocationUpdates() {
    locationService.stopLocationUpdates();
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  /// Update driver location
  Future<void> _updateDriverLocation() async {
    if (!isOnline || !locationPermissionGranted) return;

    try {
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        final result = await driverRepository.updateDriverLocation({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });

        if (!result.isSuccess) {
          print('Failed to update location: ${result.message}');
        }
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  /// Refresh semua data
  Future<void> refreshData() async {
    await Future.wait([
      _loadDriverProfile(),
      _loadDriverStatusInfo(),
      _loadTodayStats(),
    ]);
  }

  /// Force status update (manual refresh)
  Future<void> forceStatusUpdate() async {
    if (isUpdatingStatus) return;

    try {
      _isUpdatingStatus.value = true;
      await _loadDriverStatusInfo();
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  /// Get status display info (enhanced dengan model)
  Map<String, dynamic> get statusDisplayInfo {
    final statusModel = _driverStatus.value;
    if (statusModel == null) {
      return {
        'text': 'Unknown',
        'color': Get.theme.colorScheme.outline,
        'description': 'Status not loaded',
        'icon': 'help_outline',
      };
    }

    return {
      'text': statusModel.statusDisplayName,
      'color': DriverStatusConstants.getDriverStatusColor(statusModel.status),
      'description': statusModel.statusDescription,
      'icon': DriverStatusConstants.getDriverStatusIcon(statusModel.status)
          .codePoint
          .toString(),
      'canToggle': statusModel.canToggleStatus,
      'blockingReason': statusModel.blockingReason,
    };
  }

  /// Format methods (unchanged)
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
    return '${rating.toStringAsFixed(1)} ⭐';
  }

  /// Enhanced status message menggunakan model
  String get statusMessage {
    if (isUpdatingStatus) return 'Updating status...';

    final statusModel = _driverStatus.value;
    if (statusModel == null) return 'Loading status...';

    if (statusModel.hasBlockingReason) {
      return statusModel.blockingReason;
    }

    return statusModel.statusDescription;
  }

  /// Validation methods menggunakan model
  bool get canAcceptOrders => _driverStatus.value?.isActive ?? false;
  bool get requiresLocationPermission =>
      _driverStatus.value?.requiresLocationPermission ?? false;
  bool get hasValidLocation => _driverStatus.value?.hasValidLocation ?? false;
}
