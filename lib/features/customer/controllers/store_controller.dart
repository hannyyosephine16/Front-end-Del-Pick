import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/data/repositories/store_repository.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/core/utils/distance_helper.dart';
import 'package:del_pick/app/config/app_config.dart';

class StoreController extends GetxController {
  final StoreRepository _storeRepository;
  final LocationService _locationService;

  StoreController({
    required StoreRepository storeRepository,
    required LocationService locationService,
  })  : _storeRepository = storeRepository,
        _locationService = locationService;

  // ✅ Simplified state management
  final RxBool _isLoading = false.obs;
  final RxBool _isSearching = false.obs;
  final RxList<StoreModel> _stores = <StoreModel>[].obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxDouble _currentLatitude = AppConfig.defaultLatitude.obs;
  final RxDouble _currentLongitude = AppConfig.defaultLongitude.obs;

  // ✅ Simplified filter state
  final RxString _searchQuery = ''.obs;
  final RxString _currentSortBy = 'distance'.obs;

  // ✅ Debounced search
  Timer? _searchDebouncer;

  // ✅ Cache to prevent repeated calls
  DateTime? _lastFetch;
  static const Duration _cacheTimeout = Duration(minutes: 3);

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;
  List<StoreModel> get stores => _stores;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasStores => _stores.isNotEmpty;
  String get searchQuery => _searchQuery.value;
  String get currentSortBy => _currentSortBy.value;
  int get totalStoresCount => _stores.length;
  int get filteredStoresCount => _stores.length;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  @override
  void onClose() {
    _searchDebouncer?.cancel();
    super.onClose();
  }

  void _initializeLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentLatitude.value = position.latitude;
        _currentLongitude.value = position.longitude;
      }
    } catch (e) {
      // Use default location
    }

    // Load stores after location is set
    loadStores();
  }

  // ✅ MAIN OPTIMIZED METHOD: Simple and fast
  Future<void> loadStores({bool isRefresh = false}) async {
    // Check cache unless refreshing
    if (!isRefresh && _shouldUseCache()) {
      return;
    }

    _isLoading.value = true;
    _hasError.value = false;

    try {
      // Use simple getAllStores with reasonable limit
      final result = await _storeRepository.getAllStores(
        page: 1,
        limit: 50, // Reasonable limit for mobile
      );

      if (result.isSuccess && result.data != null) {
        // ✅ FIXED: Use .items instead of .data
        var storesList = result.data!.items;

        // Calculate distances and sort
        storesList = _calculateDistancesAndSort(storesList);

        _stores.value = storesList;
        _lastFetch = DateTime.now();
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to load stores';
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Error loading stores: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // ✅ OPTIMIZED: Efficient distance calculation
  List<StoreModel> _calculateDistancesAndSort(List<StoreModel> stores) {
    final userLat = _currentLatitude.value;
    final userLon = _currentLongitude.value;

    // Calculate distances efficiently
    final storesWithDistance = stores.map((store) {
      if (store.latitude != null && store.longitude != null) {
        final distance = DistanceHelper.calculateDistance(
          userLat,
          userLon,
          store.latitude!,
          store.longitude!,
        );
        return store.copyWith(distance: distance);
      }
      return store.copyWith(distance: 9999.0);
    }).toList();

    // Sort by current sort preference
    _sortStores(storesWithDistance);

    return storesWithDistance;
  }

  void _sortStores(List<StoreModel> stores) {
    switch (_currentSortBy.value) {
      case 'distance':
        stores.sort(
            (a, b) => (a.distance ?? 9999.0).compareTo(b.distance ?? 9999.0));
        break;
      case 'rating':
        stores.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
        break;
      case 'name':
        stores.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  // ✅ OPTIMIZED: Debounced search
  void searchStores(String query) {
    _searchDebouncer?.cancel();
    _searchQuery.value = query;
    _isSearching.value = true;

    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      _applySearch();
      _isSearching.value = false;
    });
  }

  void _applySearch() {
    if (_searchQuery.value.isEmpty) {
      loadStores();
      return;
    }

    // Filter existing stores (no API call needed)
    final query = _searchQuery.value.toLowerCase();
    final filtered = _stores.where((store) {
      return store.name.toLowerCase().contains(query) ||
          (store.description?.toLowerCase().contains(query) ?? false);
    }).toList();

    _stores.value = filtered;
  }

  void clearSearch() {
    _searchQuery.value = '';
    loadStores();
  }

  // ✅ SIMPLIFIED: Quick sort methods
  void sortStoresByDistance() {
    _currentSortBy.value = 'distance';
    final sortedStores = List<StoreModel>.from(_stores);
    _sortStores(sortedStores);
    _stores.value = sortedStores;
  }

  void sortStoresByRating() {
    _currentSortBy.value = 'rating';
    final sortedStores = List<StoreModel>.from(_stores);
    _sortStores(sortedStores);
    _stores.value = sortedStores;
  }

  void sortStoresByName() {
    _currentSortBy.value = 'name';
    final sortedStores = List<StoreModel>.from(_stores);
    _sortStores(sortedStores);
    _stores.value = sortedStores;
  }

  void filterOpenStores() {
    final openStores = _stores.where((store) => store.isOpen ?? false).toList();
    _stores.value = openStores;
  }

  void filterByRating(double minRating) {
    final ratedStores =
        _stores.where((store) => (store.rating ?? 0) >= minRating).toList();
    _stores.value = ratedStores;
  }

  void resetFilters() {
    _searchQuery.value = '';
    _currentSortBy.value = 'distance';
    loadStores();
  }

  Future<void> refreshStores() async {
    _lastFetch = null; // Invalidate cache
    await loadStores(isRefresh: true);
  }

  // ✅ Cache helper
  bool _shouldUseCache() {
    return _lastFetch != null &&
        _stores.isNotEmpty &&
        DateTime.now().difference(_lastFetch!) < _cacheTimeout;
  }
}
