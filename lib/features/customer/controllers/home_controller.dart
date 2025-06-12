// lib/features/customer/controllers/home_controller.dart - FIXED PaginatedResponse
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

  // ✅ Separate loading states for better UX
  final RxBool _isLoadingStores = false.obs;
  final RxBool _isLoadingOrders = false.obs;
  final RxList<StoreModel> _nearbyStores = <StoreModel>[].obs;
  final RxList<OrderModel> _recentOrders = <OrderModel>[].obs;
  final RxString _greeting = ''.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxBool _hasLocation = false.obs;
  final RxString _currentAddress = 'Institut Teknologi Del'.obs;
  final Rx<Position?> _userLocation = Rx<Position?>(null);

  // ✅ Cache timers untuk prevent multiple calls
  DateTime? _lastStoresFetch;
  DateTime? _lastOrdersFetch;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // Getters
  bool get isLoading => _isLoadingStores.value || _isLoadingOrders.value;
  bool get isLoadingStores => _isLoadingStores.value;
  bool get isLoadingOrders => _isLoadingOrders.value;
  List<StoreModel> get nearbyStores => _nearbyStores;
  List<OrderModel> get recentOrders => _recentOrders;
  String get greeting => _greeting.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasLocation => _hasLocation.value;
  String get currentAddress => _currentAddress.value;
  bool get hasStores => _nearbyStores.isNotEmpty;
  bool get hasOrders => _recentOrders.isNotEmpty;

  double get customerLatitude =>
      _userLocation.value?.latitude ?? AppConfig.defaultLatitude;
  double get customerLongitude =>
      _userLocation.value?.longitude ?? AppConfig.defaultLongitude;

  @override
  void onInit() {
    super.onInit();

    // ✅ IMMEDIATE: Set greeting tanpa delay
    _setGreeting();

    // ✅ IMMEDIATE: Set default location
    _setDefaultLocation();

    // ✅ BACKGROUND: Load data secara asynchronous
    _loadDataInBackground();
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
    _currentAddress.value = 'Institut Teknologi Del';
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
    _hasLocation.value = true;
  }

  // ✅ Load data di background tanpa block UI
  void _loadDataInBackground() async {
    // Start loading location in background
    _getCurrentLocationInBackground();

    // Load essential data with staggered loading
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadStoresInBackground();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _loadOrdersInBackground();
    });
  }

  void _getCurrentLocationInBackground() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _userLocation.value = position;
        _hasLocation.value = true;

        // Refresh stores with real location if needed
        if (_nearbyStores.isEmpty) {
          _loadStoresInBackground();
        }
      }
    } catch (e) {
      // Keep default location if error
      print('Location error (using default): $e');
    }
  }

  // ✅ OPTIMIZED: Load stores with cache check
  void _loadStoresInBackground() async {
    // Check cache
    if (_shouldUseCachedStores()) {
      return;
    }

    _isLoadingStores.value = true;

    try {
      // Try nearby stores first (limit 5 for home screen)
      final result = await _storeRepository.getAllStores(
        page: 1,
        limit: 5,
      );

      if (result.isSuccess && result.data != null) {
        // ✅ FIXED: Use .items instead of .data
        var stores = result.data!.items;

        // Calculate distances if location available
        if (_userLocation.value != null) {
          stores = stores.map((store) {
            if (store.latitude != null && store.longitude != null) {
              final distance = DistanceHelper.calculateDistance(
                _userLocation.value!.latitude,
                _userLocation.value!.longitude,
                store.latitude!,
                store.longitude!,
              );
              return store.copyWith(distance: distance);
            }
            return store.copyWith(distance: 9999.0);
          }).toList();

          // Sort by distance
          stores.sort((a, b) {
            final distanceA = a.distance ?? 9999.0;
            final distanceB = b.distance ?? 9999.0;
            return distanceA.compareTo(distanceB);
          });
        }

        _nearbyStores.value = stores.take(5).toList();
        _lastStoresFetch = DateTime.now();
      }
    } catch (e) {
      print('Error loading stores: $e');
    } finally {
      _isLoadingStores.value = false;
    }
  }

  // ✅ OPTIMIZED: Load orders with cache check
  void _loadOrdersInBackground() async {
    // Check cache
    if (_shouldUseCachedOrders()) {
      return;
    }

    _isLoadingOrders.value = true;

    try {
      final result = await _orderRepository.getOrdersByUser(
        params: {'limit': 3, 'page': 1},
      );

      if (result.isSuccess && result.data != null) {
        if (result.data is PaginatedResponse<OrderModel>) {
          // ✅ FIXED: Use .items instead of .data
          _recentOrders.value = (result.data as PaginatedResponse<OrderModel>)
              .items
              .take(3)
              .toList();
        }
        _lastOrdersFetch = DateTime.now();
      }
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      _isLoadingOrders.value = false;
    }
  }

  // ✅ Cache check helpers
  bool _shouldUseCachedStores() {
    return _lastStoresFetch != null &&
        _nearbyStores.isNotEmpty &&
        DateTime.now().difference(_lastStoresFetch!) < _cacheTimeout;
  }

  bool _shouldUseCachedOrders() {
    return _lastOrdersFetch != null &&
        _recentOrders.isNotEmpty &&
        DateTime.now().difference(_lastOrdersFetch!) < _cacheTimeout;
  }

  // ✅ OPTIMIZED: Refresh with cache invalidation
  Future<void> refreshData() async {
    _lastStoresFetch = null;
    _lastOrdersFetch = null;

    _loadStoresInBackground();
    _loadOrdersInBackground();
  }

  // Navigation methods (unchanged)
  void navigateToStores() => Get.toNamed(Routes.STORE_LIST);
  void navigateToOrders() => Get.toNamed(Routes.ORDER_HISTORY);
  void navigateToStoreDetail(int storeId) =>
      Get.toNamed(Routes.STORE_DETAIL, arguments: {'storeId': storeId});
  void navigateToOrderDetail(int orderId) =>
      Get.toNamed(Routes.CUSTOMER_ORDER_DETAIL,
          arguments: {'orderId': orderId});
  void navigateToCart() => Get.toNamed(Routes.CART);
  void navigateToProfile() => Get.toNamed(Routes.PROFILE);

  Map<String, dynamic> getCustomerLocation() {
    return {
      'latitude': customerLatitude,
      'longitude': customerLongitude,
      'address': _currentAddress.value,
    };
  }
}
