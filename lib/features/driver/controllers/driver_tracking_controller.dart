// lib/features/driver/controllers/driver_tracking_controller.dart - FIXED VERSION
import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:del_pick/data/repositories/tracking_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/models/tracking/tracking_info_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/core/services/external/permission_service.dart';
import 'package:del_pick/core/utils/custom_snackbar.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class DriverTrackingController extends GetxController {
  final TrackingRepository trackingRepository;
  final OrderRepository orderRepository;
  final DriverRepository driverRepository;
  final LocationService locationService;
  final PermissionService permissionService;

  DriverTrackingController({
    required this.trackingRepository,
    required this.orderRepository,
    required this.driverRepository,
    required this.locationService,
    required this.permissionService,
  });

  // Observable Variables
  final RxInt _currentOrderId = 0.obs;
  final Rx<OrderModel?> _currentOrder = Rx<OrderModel?>(null);
  final Rx<TrackingInfoModel?> _trackingInfo = Rx<TrackingInfoModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isTrackingActive = false.obs;
  final RxBool _isUpdatingLocation = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Position?> _currentPosition = Rx<Position?>(null);
  final RxDouble _distanceToDestination = 0.0.obs;
  final RxString _estimatedArrival = ''.obs;

  // Timers
  Timer? _locationUpdateTimer;
  Timer? _trackingRefreshTimer;

  // Getters
  int get currentOrderId => _currentOrderId.value;
  OrderModel? get currentOrder => _currentOrder.value;
  TrackingInfoModel? get trackingInfo => _trackingInfo.value;
  bool get isLoading => _isLoading.value;
  bool get isTrackingActive => _isTrackingActive.value;
  bool get isUpdatingLocation => _isUpdatingLocation.value;
  String get errorMessage => _errorMessage.value;
  Position? get currentPosition => _currentPosition.value;
  double get distanceToDestination => _distanceToDestination.value;
  String get estimatedArrival => _estimatedArrival.value;

  bool get hasActiveDelivery =>
      _currentOrder.value != null &&
      _currentOrder.value!.orderStatus == OrderStatusConstants.onDelivery;

  bool get canStartDelivery =>
      _currentOrder.value != null &&
      _currentOrder.value!.orderStatus == OrderStatusConstants.readyForPickup;

  bool get canCompleteDelivery =>
      _currentOrder.value != null &&
      _currentOrder.value!.orderStatus == OrderStatusConstants.onDelivery;

  @override
  void onInit() {
    super.onInit();
    _initializeLocationService();
  }

  @override
  void onClose() {
    _stopTracking();
    super.onClose();
  }

  /// Initialize location service
  Future<void> _initializeLocationService() async {
    try {
      // Check permission using PermissionService
      final hasPermission = await permissionService.checkLocationPermission();
      if (!hasPermission) {
        final granted = await permissionService.requestLocationPermission();
        if (!granted) {
          CustomSnackbar.showError(
            title: 'Location Permission Required',
            message: 'Location permission is required for delivery tracking',
          );
          return;
        }
      }

      // Start location updates
      await locationService.startLocationUpdates();
      print('✅ Location service initialized');
    } catch (e) {
      print('❌ Failed to initialize location service: $e');
    }
  }

  /// Start tracking for an order
  Future<void> startTrackingOrder(int orderId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _currentOrderId.value = orderId;

      print('🔄 Starting tracking for order: $orderId');

      // Load order details
      await _loadOrderDetails(orderId);

      // Start location tracking
      await _startLocationTracking();

      // Start periodic tracking updates
      _startTrackingRefresh();

      _isTrackingActive.value = true;

      print('✅ Tracking started successfully for order: $orderId');
    } catch (e) {
      print('💥 Exception in startTrackingOrder: $e');
      _errorMessage.value = 'Failed to start tracking: ${e.toString()}';
      CustomSnackbar.showError(
        title: 'Tracking Error',
        message: 'Failed to start tracking: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load order details
  Future<void> _loadOrderDetails(int orderId) async {
    try {
      final result = await orderRepository.getOrderDetail(orderId);

      if (result.isSuccess && result.data != null) {
        _currentOrder.value = result.data!;
        print('✅ Order details loaded: ${_currentOrder.value!.code}');
      } else {
        throw Exception(result.message ?? 'Failed to load order details');
      }
    } catch (e) {
      print('❌ Failed to load order details: $e');
      throw e;
    }
  }

  /// Start location tracking
  Future<void> _startLocationTracking() async {
    try {
      // Start location updates timer
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _updateDriverLocation(),
      );

      // Get initial position
      await _updateDriverLocation();

      print('✅ Location tracking started');
    } catch (e) {
      print('❌ Failed to start location tracking: $e');
      throw e;
    }
  }

  /// Update driver location
  Future<void> _updateDriverLocation() async {
    if (_isUpdatingLocation.value) return;

    try {
      _isUpdatingLocation.value = true;

      // Get current position from LocationService
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition.value = position;

        // Update driver location in backend for order tracking
        if (_currentOrderId.value > 0) {
          final result = await trackingRepository.updateDriverLocation(
            _currentOrderId.value,
            position.latitude,
            position.longitude,
          );

          if (!result.isSuccess) {
            print('❌ Failed to update location in tracking: ${result.message}');
          }
        }

        // Update driver location in driver repository
        final driverResult = await driverRepository.updateDriverLocation(
          position.latitude,
          position.longitude,
        );

        if (!driverResult.isSuccess) {
          print('❌ Failed to update driver location: ${driverResult.message}');
        }

        // Calculate distance to destination
        if (_currentOrder.value != null) {
          _calculateDistanceToDestination(position);
        }

        print(
            '📍 Location updated: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      print('❌ Failed to update location: $e');
    } finally {
      _isUpdatingLocation.value = false;
    }
  }

  /// Calculate distance to destination
  void _calculateDistanceToDestination(Position currentPosition) {
    // For delivery orders, use customer location
    double? destinationLat;
    double? destinationLng;

    if (_currentOrder.value?.orderStatus ==
        OrderStatusConstants.readyForPickup) {
      // Going to store for pickup
      destinationLat = _currentOrder.value?.store?.latitude;
      destinationLng = _currentOrder.value?.store?.longitude;
    } else if (_currentOrder.value?.orderStatus ==
        OrderStatusConstants.onDelivery) {
      // Going to customer for delivery - Using static destination for now
      destinationLat = 2.3834831864787818; // IT Del coordinates
      destinationLng = 99.14857915147614;
    }

    if (destinationLat == null || destinationLng == null) {
      return;
    }

    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      destinationLat,
      destinationLng,
    );

    _distanceToDestination.value = distance / 1000; // Convert to kilometers

    // Calculate estimated arrival time (assuming 30 km/h average speed)
    final estimatedMinutes = (distance / 1000) / 30 * 60;
    final arrivalTime =
        DateTime.now().add(Duration(minutes: estimatedMinutes.round()));
    _estimatedArrival.value =
        '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }

  /// Start tracking refresh timer
  void _startTrackingRefresh() {
    _trackingRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshTrackingInfo(),
    );
  }

  /// Refresh tracking information
  Future<void> _refreshTrackingInfo() async {
    if (_currentOrderId.value <= 0) return;

    try {
      final result =
          await trackingRepository.getTrackingInfo(_currentOrderId.value);

      if (result.isSuccess && result.data != null) {
        _trackingInfo.value = result.data!;
      }
    } catch (e) {
      print('Failed to refresh tracking info: $e');
    }
  }

  /// Start delivery - Backend: POST /orders/{id}/tracking/start
  Future<void> startDelivery() async {
    if (_currentOrderId.value <= 0 || !canStartDelivery) return;

    try {
      _isLoading.value = true;
      print('🚀 Starting delivery for order: ${_currentOrderId.value}');

      final result =
          await trackingRepository.startDelivery(_currentOrderId.value);

      if (result.isSuccess) {
        CustomSnackbar.showSuccess(
          title: 'Delivery Started',
          message: 'You have started the delivery for this order',
        );

        // Update order status locally
        if (_currentOrder.value != null) {
          _currentOrder.value = _currentOrder.value!.copyWith(
            orderStatus: OrderStatusConstants.onDelivery,
            actualPickupTime: DateTime.now(),
          );
        }

        // Start intensive location tracking
        await _startLocationTracking();

        print('✅ Delivery started successfully');
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to start delivery',
        );
      }
    } catch (e) {
      print('💥 Exception in startDelivery: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to start delivery: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Complete delivery - Backend: POST /orders/{id}/tracking/complete
  Future<void> completeDelivery() async {
    if (_currentOrderId.value <= 0 || !canCompleteDelivery) return;

    try {
      _isLoading.value = true;
      print('✅ Completing delivery for order: ${_currentOrderId.value}');

      final result =
          await trackingRepository.completeDelivery(_currentOrderId.value);

      if (result.isSuccess) {
        CustomSnackbar.showSuccess(
          title: 'Delivery Completed',
          message: 'Order has been delivered successfully',
        );

        // Update order status locally
        if (_currentOrder.value != null) {
          _currentOrder.value = _currentOrder.value!.copyWith(
            orderStatus: OrderStatusConstants.delivered,
            actualDeliveryTime: DateTime.now(),
          );
        }

        // Stop tracking
        _stopTracking();

        // Navigate back to driver dashboard
        Get.offAllNamed(Routes.DRIVER_MAIN);

        print('✅ Delivery completed successfully');
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to complete delivery',
        );
      }
    } catch (e) {
      print('💥 Exception in completeDelivery: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to complete delivery: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Stop tracking
  void _stopTracking() {
    _locationUpdateTimer?.cancel();
    _trackingRefreshTimer?.cancel();
    _isTrackingActive.value = false;

    // Stop location service updates
    locationService.stopLocationUpdates();

    print('🛑 Tracking stopped');
  }

  /// Resume tracking (if paused)
  Future<void> resumeTracking() async {
    if (_currentOrderId.value > 0) {
      await startTrackingOrder(_currentOrderId.value);
    }
  }

  /// Get tracking history
  Future<void> loadTrackingHistory() async {
    if (_currentOrderId.value <= 0) return;

    try {
      final result =
          await trackingRepository.getTrackingHistory(_currentOrderId.value);

      if (result.isSuccess && result.data != null) {
        // Handle tracking history data
        final historyData = result.data!;
        print('✅ Tracking history loaded: $historyData');
      }
    } catch (e) {
      print('❌ Failed to load tracking history: $e');
    }
  }

  /// Check if delivery is running late
  bool get isDeliveryLate {
    if (_currentOrder.value?.estimatedDeliveryTime == null) return false;

    final now = DateTime.now();
    final estimatedTime = _currentOrder.value!.estimatedDeliveryTime!;

    return now.isAfter(estimatedTime) &&
        _currentOrder.value!.orderStatus == OrderStatusConstants.onDelivery;
  }

  /// Get delivery status message
  String get deliveryStatusMessage {
    if (_currentOrder.value == null) return 'No active delivery';

    switch (_currentOrder.value!.orderStatus) {
      case OrderStatusConstants.preparing:
        return 'Store is preparing your assigned order';
      case OrderStatusConstants.readyForPickup:
        return 'Order is ready for pickup from store';
      case OrderStatusConstants.onDelivery:
        return 'Delivering order to customer';
      case OrderStatusConstants.delivered:
        return 'Order delivered successfully';
      default:
        return 'Unknown delivery status';
    }
  }

  /// Navigate to navigation app
  void openNavigationApp() {
    double? destinationLat;
    double? destinationLng;

    if (_currentOrder.value?.orderStatus ==
        OrderStatusConstants.readyForPickup) {
      // Going to store
      destinationLat = _currentOrder.value?.store?.latitude;
      destinationLng = _currentOrder.value?.store?.longitude;
    } else if (_currentOrder.value?.orderStatus ==
        OrderStatusConstants.onDelivery) {
      // Going to customer - Using static destination for now
      destinationLat = 2.3834831864787818; // IT Del coordinates
      destinationLng = 99.14857915147614;
    }

    if (destinationLat == null || destinationLng == null) {
      CustomSnackbar.showError(
        title: 'Navigation Error',
        message: 'Destination coordinates not available',
      );
      return;
    }

    // Open navigation app with destination coordinates
    print('🗺️ Opening navigation to: $destinationLat, $destinationLng');

    CustomSnackbar.showInfo(
      title: 'Navigation',
      message: 'Opening navigation app...',
    );
  }

  /// Get delivery progress percentage (0.0 to 1.0)
  double get deliveryProgress {
    if (_currentOrder.value == null) return 0.0;

    switch (_currentOrder.value!.orderStatus) {
      case OrderStatusConstants.preparing:
        return 0.25;
      case OrderStatusConstants.readyForPickup:
        return 0.5;
      case OrderStatusConstants.onDelivery:
        return 0.75;
      case OrderStatusConstants.delivered:
        return 1.0;
      default:
        return 0.0;
    }
  }

  /// Get formatted distance to destination
  String get formattedDistanceToDestination {
    if (_distanceToDestination.value < 1) {
      return '${(_distanceToDestination.value * 1000).round()} m';
    } else {
      return '${_distanceToDestination.value.toStringAsFixed(1)} km';
    }
  }

  /// Clear tracking data
  void clearTrackingData() {
    _currentOrderId.value = 0;
    _currentOrder.value = null;
    _trackingInfo.value = null;
    _currentPosition.value = null;
    _distanceToDestination.value = 0.0;
    _estimatedArrival.value = '';
    _errorMessage.value = '';
    _stopTracking();
  }

  /// Handle emergency stop
  Future<void> emergencyStop() async {
    try {
      CustomSnackbar.showWarning(
        title: 'Emergency Stop',
        message: 'Delivery tracking has been stopped due to emergency',
      );

      _stopTracking();

      // You might want to notify the backend about emergency stop
      // await orderRepository.reportEmergency(_currentOrderId.value);
    } catch (e) {
      print('❌ Failed to handle emergency stop: $e');
    }
  }

  /// Get destination address based on current order status
  String get destinationAddress {
    if (_currentOrder.value == null) return 'Unknown destination';

    switch (_currentOrder.value!.orderStatus) {
      case OrderStatusConstants.readyForPickup:
        return _currentOrder.value?.store?.address ?? 'Store location';
      case OrderStatusConstants.onDelivery:
        return 'Institut Teknologi Del'; // Static destination
      default:
        return 'Unknown destination';
    }
  }

  /// Check if driver is at pickup location
  bool get isAtPickupLocation {
    if (_currentOrder.value?.store?.latitude == null ||
        _currentOrder.value?.store?.longitude == null ||
        _currentPosition.value == null) {
      return false;
    }

    final distance = Geolocator.distanceBetween(
      _currentPosition.value!.latitude,
      _currentPosition.value!.longitude,
      _currentOrder.value!.store!.latitude!,
      _currentOrder.value!.store!.longitude!,
    );

    return distance <= 100; // Within 100 meters
  }

  /// Check if driver is at delivery location
  bool get isAtDeliveryLocation {
    if (_currentPosition.value == null) return false;

    // Static destination coordinates (IT Del)
    const double destLat = 2.3834831864787818;
    const double destLng = 99.14857915147614;

    final distance = Geolocator.distanceBetween(
      _currentPosition.value!.latitude,
      _currentPosition.value!.longitude,
      destLat,
      destLng,
    );

    return distance <= 100; // Within 100 meters
  }
}
