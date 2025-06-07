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
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxBool _hasLocation = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<StoreModel> get stores => _stores;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasLocation => _hasLocation.value;
  bool get hasStores => _stores.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchAllStores(); // Changed to fetch all stores initially
  }

  Future<void> fetchAllStores() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      print('Fetching all stores...');

      // Fetch all stores from repository
      final result = await _storeRepository.getAllStores();

      if (result.isSuccess && result.data != null) {
        _stores.value = result.data!;
        print('Successfully fetched ${result.data!.length} stores');

        // Debug: Print store names
        for (var store in result.data!) {
          print('Store: ${store.name} - Status: ${store.status}');
        }
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to fetch stores';
        print('Error fetching stores: ${result.message}');
      }
    } catch (e) {
      _hasError.value = true;
      print('Exception in fetchAllStores: $e');

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

  Future<void> fetchNearbyStores() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      print('Fetching nearby stores...');

      // Get current location
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        _hasLocation.value = true;
        print('Location found: ${position.latitude}, ${position.longitude}');

        // Fetch stores from repository
        final result = await _storeRepository.getNearbyStores(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        if (result.isSuccess && result.data != null) {
          _stores.value = result.data!;
          print('Successfully fetched ${result.data!.length} nearby stores');
        } else {
          _hasError.value = true;
          _errorMessage.value =
              result.message ?? 'Failed to fetch nearby stores';
          print('Error fetching nearby stores: ${result.message}');
        }
      } else {
        print('Location not available, falling back to all stores');
        _hasLocation.value = false;
        // Fallback to get all stores without location
        await fetchAllStores();
      }
    } catch (e) {
      _hasError.value = true;
      print('Exception in fetchNearbyStores: $e');

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

  Future<void> refreshStores() async {
    // Try to fetch nearby stores first, fallback to all stores
    await fetchNearbyStores();
  }

  void sortStoresByDistance() {
    if (_stores.isNotEmpty) {
      _stores.sort((a, b) {
        final distanceA = a.distance ?? double.infinity;
        final distanceB = b.distance ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });
      print('Stores sorted by distance');
    }
  }

  void sortStoresByRating() {
    if (_stores.isNotEmpty) {
      _stores.sort((a, b) {
        final ratingA = a.rating ?? 0.0;
        final ratingB = b.rating ?? 0.0;
        return ratingB.compareTo(ratingA); // Descending order
      });
      print('Stores sorted by rating');
    }
  }

  void filterStores(String query) {
    if (query.isEmpty) {
      refreshStores();
      return;
    }

    print('Filtering stores with query: $query');

    // Filter stores by name or description
    final allStores = List<StoreModel>.from(_stores);
    final filteredStores = allStores.where((store) {
      final name = store.name.toLowerCase();
      final description = store.description?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();

    _stores.value = filteredStores;
    print('Filtered to ${filteredStores.length} stores');
  }

  // Method to manually set stores (for testing)
  void setStores(List<StoreModel> stores) {
    _stores.value = stores;
  }

  // Method to clear error state
  void clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }
}
