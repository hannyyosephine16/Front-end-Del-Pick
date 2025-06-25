// lib/features/customer/controllers/customer_home_controller.dart - FIXED
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/store_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/app/config/app_config.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class CustomerHomeController extends GetxController {
  final StoreRepository _storeRepository;
  final OrderRepository _orderRepository;
  final LocationService _locationService;

  CustomerHomeController({
    required StoreRepository storeRepository,
    required OrderRepository orderRepository,
    required LocationService locationService,
  })  : _storeRepository = storeRepository,
        _orderRepository = orderRepository,
        _locationService = locationService;

  // Observable states
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

  // Cache management
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
    _initializeHomeData();
  }

  // Initialize home data
  void _initializeHomeData() {
    _setGreeting();
    _setDefaultLocation();
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

  // Background data loading with proper staggering
  void _loadDataInBackground() {
    // Get location first
    _getCurrentLocationInBackground();

    // Staggered loading - FIXED: Don't assign void functions
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _loadStoresInBackground();
    });

    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      _loadOrdersInBackground();
    });
  }

  void _getCurrentLocationInBackground() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _userLocation.value = position;
        _hasLocation.value = true;

        // Update address based on location
        await _updateAddressFromLocation(position);
      }
    } catch (e) {
      print('Location error (using default): $e');
    }
  }

  Future<void> _updateAddressFromLocation(Position position) async {
    try {
      // You can implement reverse geocoding here if needed
      // For now, keep default address
      _currentAddress.value = 'Institut Teknologi Del';
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
  }

  // Load stores using correct repository method
  Future<void> _loadStoresInBackground() async {
    if (_shouldUseCachedStores()) return;

    _isLoadingStores.value = true;
    _clearError();

    try {
      final result = await _storeRepository.getAllStores(
        params: {
          'page': 1,
          'limit': 5,
          'latitude': customerLatitude,
          'longitude': customerLongitude,
        },
      );

      if (result.isSuccess && result.data != null) {
        var stores = result.data!;

        // Calculate distances and filter by proximity
        if (_userLocation.value != null) {
          stores = _processStoresWithDistance(stores);
        }

        _nearbyStores.value = stores.take(5).toList();
        _lastStoresFetch = DateTime.now();
      } else {
        _setError(result.errorMessage ?? 'Failed to load stores');
      }
    } catch (e) {
      _setError('Failed to load nearby stores');
      print('Error loading stores: $e');
    } finally {
      _isLoadingStores.value = false;
    }
  }

  // Load orders using correct repository method
  Future<void> _loadOrdersInBackground() async {
    if (_shouldUseCachedOrders()) return;

    _isLoadingOrders.value = true;

    try {
      // Use getUserOrders method from repository
      final result = await _orderRepository.getUserOrders(
        page: 1,
        limit: 3,
      );

      if (result.isSuccess && result.data != null) {
        // Fix: Access items from PaginatedResponse correctly
        _recentOrders.value = result.data!.items.take(3).toList();
        _lastOrdersFetch = DateTime.now();
      } else {
        print('Error loading orders: ${result.errorMessage}');
      }
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      _isLoadingOrders.value = false;
    }
  }

  // Process stores with distance calculation
  List<StoreModel> _processStoresWithDistance(List<StoreModel> stores) {
    const maxDistance = 20.0; // km

    // ✅ FIXED: Separate filter and sort operations to avoid void expression
    final filteredStores = stores
        .where((store) => store.latitude != null && store.longitude != null)
        .map((store) {
          final distance = _calculateDistance(
            _userLocation.value!.latitude,
            _userLocation.value!.longitude,
            store.latitude!,
            store.longitude!,
          );
          return store.copyWith(distance: distance);
        })
        .where((store) => (store.distance ?? 0) <= maxDistance)
        .toList();

    // Sort separately
    filteredStores.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));

    return filteredStores;
  }

  // Calculate distance using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }

  // Cache management
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

  // Error management
  void _setError(String message) {
    _errorMessage.value = message;
    _hasError.value = true;
  }

  void _clearError() {
    _errorMessage.value = '';
    _hasError.value = false;
  }

  // Public methods
  Future<void> refreshData() async {
    _lastStoresFetch = null;
    _lastOrdersFetch = null;
    _clearError();

    await _loadStoresInBackground();
    await _loadOrdersInBackground();
  }

  Future<void> refreshLocation() async {
    _getCurrentLocationInBackground();
    await refreshData();
  }

  // Navigation methods
  void navigateToStores() => Get.toNamed(Routes.STORE_LIST);

  void navigateToOrders() => Get.toNamed(Routes.ORDER_HISTORY);

  void navigateToStoreDetail(int storeId) =>
      Get.toNamed('${Routes.STORE_DETAIL}/$storeId');

  void navigateToOrderDetail(int orderId) =>
      Get.toNamed('${Routes.CUSTOMER_ORDER_DETAIL}/$orderId');

  void navigateToCart() => Get.toNamed(Routes.CART);

  void navigateToProfile() => Get.toNamed(Routes.CUSTOMER_PROFILE);

  void navigateToOrderTracking(int orderId) =>
      Get.toNamed('${Routes.ORDER_TRACKING}/$orderId');

  void navigateToSearch() => Get.toNamed(Routes.SEARCH);

  // Utility methods
  Map<String, dynamic> getCustomerLocation() {
    return {
      'latitude': customerLatitude,
      'longitude': customerLongitude,
      'address': _currentAddress.value,
      'hasRealLocation': _userLocation.value != null,
    };
  }

  String getDistanceText(double? distance) {
    if (distance == null) return '';
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  bool isStoreOpen(StoreModel store) {
    if (store.openTime == null || store.closeTime == null) {
      return store.status == 'active';
    }
    // ✅ FIXED: Check if StoreModel has isOpenNow method, otherwise use simple check
    try {
      return store.isOpenNow() && store.status == 'active';
    } catch (e) {
      // Fallback if isOpenNow method doesn't exist
      return store.status == 'active';
    }
  }

  String getStoreStatusText(StoreModel store) {
    if (store.status != 'active') return 'Closed';
    if (isStoreOpen(store)) return 'Open';
    return 'Closed';
  }

  // Order status helpers based on backend order statuses
  List<OrderModel> get activeOrders =>
      _recentOrders.where((order) => order.isActive).toList();

  List<OrderModel> get trackableOrders =>
      _recentOrders.where((order) => order.canTrack).toList();

  bool get hasActiveOrders => activeOrders.isNotEmpty;

  // Store filtering helpers
  List<StoreModel> get openStores =>
      _nearbyStores.where((store) => isStoreOpen(store)).toList();

  List<StoreModel> get nearestStores => _nearbyStores.take(3).toList();

  bool get hasOpenStores => openStores.isNotEmpty;

  @override
  void onClose() {
    // Clean up any timers or subscriptions if needed
    super.onClose();
  }
}
