// lib/features/customer/controllers/home_controller.dart - Compatible with existing StoreRepository

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/store_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/constants/app_constants.dart';

import '../../../app/config/app_config.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/distance_helper.dart';

class HomeController extends GetxController {
  final StoreRepository _storeRepository;
  final OrderRepository _orderRepository;
  final LocationService _locationService;

  HomeController({
    required StoreRepository storeRepository,
    required OrderRepository orderRepository,
    required LocationService locationService,
  })  : _storeRepository = storeRepository,
        _orderRepository = orderRepository,
        _locationService = locationService;

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxList<StoreModel> _nearbyStores = <StoreModel>[].obs;
  final RxList<OrderModel> _recentOrders = <OrderModel>[].obs;
  final RxString _greeting = ''.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxBool _hasLocation = false.obs;
  final RxString _currentAddress = 'Getting location...'.obs;
  final Rx<Position?> _userLocation = Rx<Position?>(null);

  // Getters
  bool get isLoading => _isLoading.value;
  List<StoreModel> get nearbyStores => _nearbyStores;
  List<OrderModel> get recentOrders => _recentOrders;
  String get greeting => _greeting.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasLocation => _hasLocation.value;
  String get currentAddress => _currentAddress.value;
  bool get hasStores => _nearbyStores.isNotEmpty;
  bool get hasOrders => _recentOrders.isNotEmpty;

  // Customer location (default IT Del coordinates)
  double get customerLatitude =>
      _userLocation.value?.latitude ?? AppConstants.defaultLatitude;
  double get customerLongitude =>
      _userLocation.value?.longitude ?? AppConstants.defaultLongitude;

  @override
  void onInit() {
    super.onInit();
    _setGreeting();
    _getCurrentLocation();
    loadHomeData();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting.value = 'Good Morning';
    } else if (hour < 17) {
      _greeting.value = 'Good Afternoon';
    } else {
      _greeting.value = 'Good Evening';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _userLocation.value = position;
        _hasLocation.value = true;
        // You might want to implement reverse geocoding here
        _currentAddress.value = 'Institut Teknologi Del';
      } else {
        _hasLocation.value = false;
        _currentAddress.value = 'Location not available';
        // Use default location as fallback
        _userLocation.value = Position(
          latitude: AppConfig.defaultLatitude,
          longitude: AppConfig.defaultLongitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          speed: 0,
          headingAccuracy: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      _hasLocation.value = false;
      _currentAddress.value = 'Location error';
      // Use default location as fallback
      _userLocation.value = Position(
        latitude: AppConfig.defaultLatitude,
        longitude: AppConfig.defaultLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        speed: 0,
        headingAccuracy: 0,
        speedAccuracy: 0,
      );
    }
  }

  Future<void> loadHomeData() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      await Future.wait([_loadNearbyStores(), _loadRecentOrders()]);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to load data';
      print('Error loading home data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadNearbyStores() async {
    try {
      // Try getNearbyStores first if location is available
      if (_userLocation.value != null) {
        final nearbyResult = await _storeRepository.getNearbyStores(
          latitude: _userLocation.value!.latitude,
          longitude: _userLocation.value!.longitude,
          limit: 5,
        );

        if (nearbyResult.isSuccess && nearbyResult.data != null) {
          _nearbyStores.value = nearbyResult.data!.take(5).toList();
          print('Loaded ${_nearbyStores.length} nearby stores');
          return;
        }
      }

      // Fallback: Get all stores and calculate distances locally
      final result = await _storeRepository.getAllStores(limit: 20);

      if (result.isSuccess && result.data != null) {
        List<StoreModel> allStores =
            result.data!.data; // Access data from PaginatedResponse

        // If we have user location, calculate distances and sort
        if (_userLocation.value != null) {
          final userLat = _userLocation.value!.latitude;
          final userLon = _userLocation.value!.longitude;

          // Calculate distance for each store
          final storesWithDistance = allStores.map((store) {
            if (store.latitude != null && store.longitude != null) {
              final distance = DistanceHelper.calculateDistance(
                userLat,
                userLon,
                store.latitude!,
                store.longitude!,
              );
              return store.copyWith(distance: distance);
            } else {
              // If store doesn't have coordinates, put it at the end
              return store.copyWith(distance: 9999.0);
            }
          }).toList();

          // Sort by distance (closest first) and take only 5 stores for home screen
          storesWithDistance.sort((a, b) {
            final distanceA = a.distance ?? 9999.0;
            final distanceB = b.distance ?? 9999.0;
            return distanceA.compareTo(distanceB);
          });

          _nearbyStores.value = storesWithDistance.take(5).toList();
        } else {
          // If no location, just take first 5 stores
          _nearbyStores.value = allStores.take(5).toList();
        }

        print('Loaded ${_nearbyStores.length} stores using getAllStores');
      } else {
        print('Failed to load stores: ${result.message}');
      }
    } catch (e) {
      // Handle error silently for now
      print('Error loading nearby stores: $e');
    }
  }

  Future<void> _loadRecentOrders() async {
    try {
      final result = await _orderRepository.getOrdersByUser(
        params: {'limit': 3, 'page': 1},
      );

      if (result.isSuccess && result.data != null) {
        // Handle different response types from order repository
        if (result.data is PaginatedResponse<OrderModel>) {
          _recentOrders.value =
              (result.data as PaginatedResponse<OrderModel>).data;
        } else if (result.data is List<OrderModel>) {
          _recentOrders.value = result.data as List<OrderModel>;
        } else {
          _recentOrders.clear();
        }
        print('Loaded ${_recentOrders.length} recent orders');
      } else {
        print('Failed to load recent orders: ${result.message}');
      }
    } catch (e) {
      print('Error loading recent orders: $e');
      // Handle error silently for now
    }
  }

  Future<void> refreshData() async {
    await loadHomeData();
  }

  void navigateToStores() {
    Get.toNamed(Routes.STORE_LIST);
  }

  void navigateToOrders() {
    Get.toNamed(Routes.ORDER_HISTORY);
  }

  void navigateToStoreDetail(int storeId) {
    Get.toNamed(Routes.STORE_DETAIL, arguments: {'storeId': storeId});
  }

  void navigateToOrderDetail(int orderId) {
    Get.toNamed(Routes.ORDER_DETAIL, arguments: {'orderId': orderId});
  }

  void navigateToCart() {
    Get.toNamed(Routes.CART);
  }

  void navigateToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  // Method to get customer location for other controllers
  Map<String, dynamic> getCustomerLocation() {
    return {
      'latitude': customerLatitude,
      'longitude': customerLongitude,
      'address': _currentAddress.value,
    };
  }
}
