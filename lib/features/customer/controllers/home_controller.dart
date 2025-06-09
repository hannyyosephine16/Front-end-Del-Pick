// lib/features/customer/controllers/home_controller.dart

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/store_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
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
  // final RxBool _hasLocation =
  //     true.obs; // Always true since we use default location
  final RxBool _hasLocation = false.obs;
  // final RxString _currentAddress =
  //     'Institut Teknologi Del'.obs; // Set default address
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
  double get customerLatitude => AppConstants.defaultLatitude;
  double get customerLongitude => AppConstants.defaultLongitude;

  @override
  void onInit() {
    super.onInit();
    _setGreeting();
    // _setDefaultLocation();
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

  void _setDefaultLocation() {
    // Always use IT Del as customer location
    _hasLocation.value = true;
    _currentAddress.value = 'Institut Teknologi Del';
    print('Customer location set to: ${_currentAddress.value}');
    print('Coordinates: ${customerLatitude}, ${customerLongitude}');
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

  // Future<void> _loadNearbyStores() async {
  //   try {
  //     // Always use default IT Del coordinates for customer location
  //     final result = await _storeRepository.getNearbyStores(
  //       latitude: customerLatitude,
  //       longitude: customerLongitude,
  //     );
  //
  //     if (result.isSuccess && result.data != null) {
  //       // Limit to 5 stores for home screen
  //       _nearbyStores.value = result.data!.take(5).toList();
  //       print('Loaded ${_nearbyStores.length} nearby stores');
  //     } else {
  //       print('Failed to load nearby stores: ${result.message}');
  //       // Fallback to get all stores
  //       final fallbackResult = await _storeRepository.getAllStores();
  //       if (fallbackResult.isSuccess && fallbackResult.data != null) {
  //         _nearbyStores.value = fallbackResult.data!.take(5).toList();
  //         print('Loaded ${_nearbyStores.length} stores as fallback');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error loading nearby stores: $e');
  //     // Handle error silently for now
  //   }
  // }

  Future<void> _loadNearbyStores() async {
    try {
      // Get all stores first
      final result = await _storeRepository.getAllStores();

      if (result.isSuccess && result.data != null) {
        final allStores = result.data!;

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
        _recentOrders.value = result.data!.data;
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
