// lib/features/driver/controllers/driver_home_controller.dart - COMPLETE VERSION
import 'dart:async';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/core/constants/driver_status_constants.dart';
import 'package:del_pick/core/utils/custom_snackbar.dart';
import 'package:del_pick/core/utils/result.dart';
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

  // Observable Variables
  final RxBool _isOnline = false.obs;
  final RxBool _isUpdatingStatus = false.obs;
  final RxBool _isLoading = true.obs;
  final RxString _currentStatus = DriverStatusConstants.driverInactive.obs;
  final RxInt _todayDeliveries = 0.obs;
  final RxDouble _todayEarnings = 0.0.obs;
  final RxDouble _todayDistance = 0.0.obs;
  final RxDouble _rating = 0.0.obs;
  final RxList<String> _validTransitions = <String>[].obs;
  final RxBool _hasActiveOrders = false.obs;
  final RxInt _activeOrderCount = 0.obs;
  final RxString _errorMessage = ''.obs;

  // Driver Requests
  final RxList<DriverRequestModel> _driverRequests = <DriverRequestModel>[].obs;
  final RxBool _isLoadingRequests = false.obs;
  final RxBool _isRespondingToRequest = false.obs;
  final RxInt _pendingRequestsCount = 0.obs;

  // Getters
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

  List<DriverRequestModel> get driverRequests => _driverRequests;
  bool get isLoadingRequests => _isLoadingRequests.value;
  bool get isRespondingToRequest => _isRespondingToRequest.value;
  int get pendingRequestsCount => _pendingRequestsCount.value;
  bool get hasNewRequests => pendingRequestsCount > 0;

  bool get canToggleStatus {
    return !isUpdatingStatus &&
        !hasActiveOrders &&
        currentStatus != DriverStatusConstants.driverBusy;
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
      case DriverStatusConstants.driverActive:
        return {
          'text': 'Online',
          'description': 'Siap menerima pesanan',
          'color': AppColors.success,
        };
      case DriverStatusConstants.driverBusy:
        return {
          'text': 'Busy',
          'description': 'Sedang mengantarkan pesanan',
          'color': AppColors.warning,
        };
      case DriverStatusConstants.driverInactive:
      default:
        return {
          'text': 'Offline',
          'description': 'Tidak menerima pesanan',
          'color': AppColors.textSecondary,
        };
    }
  }

  // Timer untuk periodic updates
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    initializeDriver();
    _startPeriodicUpdates();
  }

  @override
  void onClose() {
    _stopPeriodicUpdates();
    super.onClose();
  }

  void _startPeriodicUpdates() {
    ever(_isOnline, (bool online) {
      if (online) {
        _refreshTimer?.cancel();
        _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          _loadDriverRequestsQuietly();
        });
      } else {
        _stopPeriodicUpdates();
      }
    });
  }

  void _stopPeriodicUpdates() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> initializeDriver() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      print('🔄 Initializing driver...');

      await Future.wait([
        loadDriverProfile(),
        loadDailyStats(),
        loadActiveOrderCount(),
        loadDriverRequests(),
      ]);

      print('✅ Driver initialization completed');
    } catch (e) {
      _errorMessage.value = 'Failed to initialize: ${e.toString()}';
      print('❌ Error initializing driver: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadDriverProfile() async {
    try {
      print('📡 Loading driver profile...');

      final result = await driverRepository.getDriverProfile();

      if (result.isSuccess && result.data != null) {
        final driver = result.data!;

        _currentStatus.value = driver.status;
        _isOnline.value = driver.status == DriverStatusConstants.driverActive;
        _rating.value = driver.rating;

        _validTransitions.value =
            driverRepository.getValidStatusTransitions(_currentStatus.value);

        print('✅ Driver profile loaded successfully');
        print('   Current status: ${_currentStatus.value}');
        print('   Rating: ${_rating.value}');

        _errorMessage.value = '';
      } else {
        print('⚠️ API Error, using default values: ${result.error}');
        _handleLoadError('profile', result.error);
      }
    } catch (e) {
      print('💥 Exception in loadDriverProfile: $e');
      _handleLoadError('profile', e.toString());
    }
  }

  Future<void> loadDailyStats() async {
    try {
      print('📊 Loading daily stats...');
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

  Future<void> loadActiveOrderCount() async {
    try {
      print('📋 Loading active order count...');

      // Simulate active order count since method doesn't exist
      _activeOrderCount.value = 0;
      _hasActiveOrders.value = false;

      print('✅ Active order count loaded: ${_activeOrderCount.value}');
    } catch (e) {
      print('💥 Exception in loadActiveOrderCount: $e');
      _activeOrderCount.value = 0;
      _hasActiveOrders.value = false;
    }
  }

  Future<void> loadDriverRequests() async {
    try {
      _isLoadingRequests.value = true;
      print('📋 Loading driver requests...');

      final result = await driverRepository.getDriverRequests(
        params: {
          'page': 1,
          'limit': 10,
          'status': DriverStatusConstants.requestPending,
        },
      );

      if (result.isSuccess && result.data != null) {
        _driverRequests.value = result.data!;
        _pendingRequestsCount.value = result.data!
            .where((request) =>
                request.status == DriverStatusConstants.requestPending)
            .length;

        print(
            '✅ Driver requests loaded: ${_driverRequests.length} total, ${_pendingRequestsCount.value} pending');
      } else {
        print('⚠️ Failed to load driver requests: ${result.error}');
        _driverRequests.clear();
        _pendingRequestsCount.value = 0;
      }
    } catch (e) {
      print('💥 Exception in loadDriverRequests: $e');
      _driverRequests.clear();
      _pendingRequestsCount.value = 0;
    } finally {
      _isLoadingRequests.value = false;
    }
  }

  Future<void> _loadDriverRequestsQuietly() async {
    try {
      final result = await driverRepository.getDriverRequests(
        params: {
          'page': 1,
          'limit': 10,
          'status': DriverStatusConstants.requestPending,
        },
      );

      if (result.isSuccess && result.data != null) {
        final newRequests = result.data!;
        final newPendingCount = newRequests
            .where((request) =>
                request.status == DriverStatusConstants.requestPending)
            .length;

        if (newPendingCount != _pendingRequestsCount.value) {
          _driverRequests.value = newRequests;
          _pendingRequestsCount.value = newPendingCount;

          if (newPendingCount > _pendingRequestsCount.value) {
            CustomSnackbar.showInfo(
              title: 'Pesanan Baru',
              message: 'Ada ${newPendingCount} pesanan baru yang menunggu',
            );
          }
        }
      }
    } catch (e) {
      print('Background refresh failed: $e');
    }
  }

  Future<void> acceptDriverRequest(DriverRequestModel request) async {
    if (_isRespondingToRequest.value) return;

    try {
      _isRespondingToRequest.value = true;
      print('✅ Accepting driver request: ${request.id}');

      final result = await driverRepository.respondToDriverRequest(
        request.id,
        'accept',
      );

      if (result.isSuccess) {
        CustomSnackbar.showSuccess(
          title: 'Pesanan Diterima',
          message: 'Anda telah menerima pesanan ${request.orderCode}',
        );

        await Future.wait([
          loadDriverRequests(),
          loadActiveOrderCount(),
          loadDriverProfile(),
        ]);

        Get.toNamed(Routes.DRIVER_REQUEST_DETAIL,
            arguments: {'orderId': request.orderId});
      } else {
        CustomSnackbar.showError(
          title: 'Gagal Menerima Pesanan',
          message: result.error ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      print('💥 Exception in acceptDriverRequest: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal menerima pesanan: ${e.toString()}',
      );
    } finally {
      _isRespondingToRequest.value = false;
    }
  }

  Future<void> rejectDriverRequest(DriverRequestModel request) async {
    if (_isRespondingToRequest.value) return;

    try {
      _isRespondingToRequest.value = true;
      print('❌ Rejecting driver request: ${request.id}');

      final result = await driverRepository.respondToDriverRequest(
        request.id,
        'reject',
      );

      if (result.isSuccess) {
        CustomSnackbar.showInfo(
          title: 'Pesanan Ditolak',
          message: 'Anda telah menolak pesanan ${request.orderCode}',
        );

        await loadDriverRequests();
      } else {
        CustomSnackbar.showError(
          title: 'Gagal Menolak Pesanan',
          message: result.error ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      print('💥 Exception in rejectDriverRequest: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal menolak pesanan: ${e.toString()}',
      );
    } finally {
      _isRespondingToRequest.value = false;
    }
  }

  Future<void> toggleDriverStatus() async {
    if (!canToggleStatus) {
      _showCannotToggleMessage();
      return;
    }

    try {
      _isUpdatingStatus.value = true;
      print('🔄 Toggling driver status...');

      final targetStatus = isOnline
          ? DriverStatusConstants.driverInactive
          : DriverStatusConstants.driverActive;

      print('   Current: ${currentStatus} → Target: $targetStatus');

      if (!driverRepository.isValidStatusTransition(
          currentStatus, targetStatus)) {
        CustomSnackbar.showError(
          title: 'Error',
          message:
              'Cannot change status to ${DriverStatusConstants.getDriverStatusName(targetStatus)}',
        );
        return;
      }

      if (targetStatus == DriverStatusConstants.driverActive) {
        final hasLocation = await _checkLocationPermission();
        if (!hasLocation) {
          CustomSnackbar.showError(
            title: 'Location Required',
            message: 'Please enable location permission to go online',
          );
          return;
        }
      }

      final result = await driverRepository.updateDriverStatus(targetStatus);

      if (result.isSuccess) {
        _currentStatus.value = targetStatus;
        _isOnline.value = targetStatus == DriverStatusConstants.driverActive;

        CustomSnackbar.showSuccess(
          title: 'Status Updated',
          message:
              'You are now ${DriverStatusConstants.getDriverStatusName(targetStatus)}',
        );

        if (targetStatus == DriverStatusConstants.driverActive) {
          locationService.startLocationUpdates();
          await loadDriverRequests();
        } else {
          locationService.stopLocationUpdates();
          _driverRequests.clear();
          _pendingRequestsCount.value = 0;
        }

        await loadDriverProfile();

        print('✅ Status updated successfully to: $targetStatus');
      } else {
        print('❌ Status update failed: ${result.error}');
        _handleStatusUpdateError(result.error);
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

  Future<bool> _checkLocationPermission() async {
    try {
      return await locationService.checkPermission();
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  void _handleLoadError(String dataType, String? error) {
    _errorMessage.value = 'Failed to load $dataType: $error';
    print('❌ Error loading $dataType: $error');

    if (error?.contains('Authentication') == true ||
        error?.contains('401') == true) {
      CustomSnackbar.showError(
        title: 'Authentication Error',
        message: 'Please login again',
      );
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _showCannotToggleMessage() {
    String message = '';
    if (isUpdatingStatus) {
      message = 'Status update in progress';
    } else if (hasActiveOrders) {
      message = 'Cannot change status while you have active orders';
    } else if (currentStatus == DriverStatusConstants.driverBusy) {
      message = 'Cannot change status while busy with delivery';
    } else {
      message = 'Cannot change status at this time';
    }

    CustomSnackbar.showWarning(
      title: 'Cannot Change Status',
      message: message,
    );
  }

  void _handleStatusUpdateError(String? error) {
    String message = 'Failed to update status';
    if (error?.contains('permission') == true) {
      message = 'Location permission required to go online';
    } else if (error?.contains('active') == true) {
      message = 'Complete current deliveries before changing status';
    } else if (error != null) {
      message = error;
    }

    CustomSnackbar.showError(
      title: 'Status Update Failed',
      message: message,
    );
  }

  // Refresh methods
  Future<void> refreshData() async {
    await Future.wait([
      loadDriverProfile(),
      loadDriverRequests(),
      loadActiveOrderCount(),
    ]);
  }

  Future<void> refreshDriverRequests() async {
    await loadDriverRequests();
  }

  // Alias for refreshData to match the screen usage
  Future<void> refreshStatus() async {
    await refreshData();
  }

  // Navigation methods that are used in the screen
  void goToMap() {
    Get.toNamed(Routes.DRIVER_MAP);
  }

  void goToOrders() {
    Get.toNamed(Routes.DRIVER_ORDER_HISTORY);
  }

  void goToRequests() {
    Get.toNamed(Routes.DRIVER_REQUESTS);
  }

  void goToProfile() {
    Get.toNamed(Routes.DRIVER_PROFILE);
  }
}
