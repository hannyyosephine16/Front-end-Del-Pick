// lib/features/customer/controllers/store_controller.dart
import 'package:get/get.dart';
import 'package:del_pick/core/errors/failures.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/repositories/store_repository.dart';
import 'package:del_pick/core/services/external/location_service.dart';

class StoreController extends GetxController {
  final StoreRepository _storeRepository;
  final LocationService _locationService;

  StoreController({
    required StoreRepository storeRepository,
    required LocationService locationService,
  })  : _storeRepository = storeRepository,
        _locationService = locationService;

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxList<StoreModel> _stores = <StoreModel>[].obs;
  final RxList<StoreModel> _filteredStores = <StoreModel>[].obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxBool _hasLocation = false.obs;
  final RxString _searchQuery = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<StoreModel> get stores =>
      _filteredStores.isNotEmpty ? _filteredStores : _stores;
  List<StoreModel> get allStores => _stores;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasLocation => _hasLocation.value;
  bool get hasStores => stores.isNotEmpty;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  Future<void> fetchStores() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      // Get current location first
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        _hasLocation.value = true;
        // Fetch nearby stores with location
        await _fetchNearbyStores(position.latitude, position.longitude);
      } else {
        _hasLocation.value = false;
        // Fallback to get all stores without location
        await _fetchAllStores();
      }
    } catch (e) {
      _hasError.value = true;
      if (e is Exception) {
        final failure = ErrorHandler.handleException(e);
        _errorMessage.value = ErrorHandler.getErrorMessage(failure);
      } else {
        _errorMessage.value = 'An unexpected error occurred';
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _fetchNearbyStores(double latitude, double longitude) async {
    final result = await _storeRepository.getNearbyStores(
      latitude: latitude,
      longitude: longitude,
    );

    if (result.isSuccess && result.data != null) {
      _stores.value = result.data!;
      _applyCurrentFilter();
    } else {
      _hasError.value = true;
      _errorMessage.value = result.message ?? 'Failed to fetch nearby stores';
    }
  }

  Future<void> _fetchAllStores() async {
    final result = await _storeRepository.getAllStores();

    if (result.isSuccess && result.data != null) {
      _stores.value = result.data!;
      _applyCurrentFilter();
    } else {
      _hasError.value = true;
      _errorMessage.value = result.message ?? 'Failed to fetch stores';
    }
  }

  // Public method to fetch nearby stores specifically
  Future<void> fetchNearbyStores() async {
    await fetchStores();
  }

  Future<void> refreshStores() async {
    await fetchStores();
  }

  void sortStoresByDistance() {
    if (_hasLocation.value) {
      final sortedStores = List<StoreModel>.from(_stores);
      sortedStores.sort((a, b) {
        final distanceA = a.distance ?? double.infinity;
        final distanceB = b.distance ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });
      _stores.value = sortedStores;
      _applyCurrentFilter();
    }
  }

  void sortStoresByRating() {
    final sortedStores = List<StoreModel>.from(_stores);
    sortedStores.sort((a, b) {
      final ratingA = a.rating ?? 0.0;
      final ratingB = b.rating ?? 0.0;
      return ratingB.compareTo(ratingA); // Descending order
    });
    _stores.value = sortedStores;
    _applyCurrentFilter();
  }

  void sortStoresByName() {
    final sortedStores = List<StoreModel>.from(_stores);
    sortedStores.sort((a, b) => a.name.compareTo(b.name));
    _stores.value = sortedStores;
    _applyCurrentFilter();
  }

  void filterStores(String query) {
    _searchQuery.value = query;
    _applyCurrentFilter();
  }

  void _applyCurrentFilter() {
    if (_searchQuery.value.isEmpty) {
      _filteredStores.clear();
    } else {
      final query = _searchQuery.value.toLowerCase();
      _filteredStores.value = _stores.where((store) {
        final name = store.name.toLowerCase();
        final address = store.address.toLowerCase();
        final description = (store.description ?? '').toLowerCase();

        return name.contains(query) ||
            address.contains(query) ||
            description.contains(query);
      }).toList();
    }
  }

  void clearSearch() {
    _searchQuery.value = '';
    _filteredStores.clear();
  }

  void filterByStatus(String status) {
    final filtered = _stores.where((store) => store.status == status).toList();
    _filteredStores.value = filtered;
  }

  void showOpenStoresOnly() {
    final filtered = _stores.where((store) => store.isOpenNow()).toList();
    _filteredStores.value = filtered;
  }

  void showAllStores() {
    _filteredStores.clear();
    _searchQuery.value = '';
  }

  // Navigation methods
  void navigateToStoreDetail(int storeId) {
    Get.toNamed('/store_detail', arguments: {'storeId': storeId});
  }

  // Get store by ID
  StoreModel? getStoreById(int storeId) {
    try {
      return _stores.firstWhere((store) => store.id == storeId);
    } catch (e) {
      return null;
    }
  }

  // Get stores count
  int get totalStoresCount => _stores.length;
  int get filteredStoresCount => stores.length;

  // Check if currently showing filtered results
  bool get isFiltered =>
      _filteredStores.isNotEmpty || _searchQuery.value.isNotEmpty;
}
