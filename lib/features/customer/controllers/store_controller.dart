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
  final RxList<StoreModel> _allStores =
      <StoreModel>[].obs; // Backup for filtering
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
    print('StoreController initialized'); // Debug
    fetchAllStores(); // Debug
    // fetchNearbyStores();
  }

  Future<void> fetchAllStores() async {
    print('StoreController: Starting fetchAllStores'); // Debug
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      print('StoreController: Calling repository.getAllStores()'); // Debug

      final result = await _storeRepository.getAllStores();

      print(
          'StoreController: Repository result - Success: ${result.isSuccess}'); // Debug
      if (result.data != null) {
        print(
            'StoreController: Repository returned ${result.data!.length} stores'); // Debug
      }

      if (result.isSuccess && result.data != null) {
        _stores.value = result.data!;
        _allStores.value = result.data!; // Save for filtering
        print(
            'StoreController: Stores loaded successfully: ${_stores.length}'); // Debug

        // Debug: Print first store details
        if (_stores.isNotEmpty) {
          print('StoreController: First store: ${_stores.first.name}'); // Debug
        }
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to fetch stores';
        print(
            'StoreController: Error from repository: ${result.message}'); // Debug
      }
    } catch (e) {
      print('StoreController: Exception in fetchAllStores: $e'); // Debug
      _hasError.value = true;
      if (e is Exception) {
        final failure = ErrorHandler.handleException(e);
        _errorMessage.value = ErrorHandler.getErrorMessage(failure);
      } else {
        _errorMessage.value = 'An unexpected error occurred';
      }
    } finally {
      _isLoading.value = false;
      print(
          'StoreController: fetchAllStores completed. Loading: ${_isLoading.value}, HasStores: $hasStores, HasError: $_hasError'); // Debug
    }
  }

  // Future<void> fetchNearbyStores() async {
  //   print('Starting fetchNearbyStores'); // Debug
  //   _isLoading.value = true;
  //   _hasError.value = false;
  //   _errorMessage.value = '';
  //
  //   try {
  //     // Get current location
  //     final position = await _locationService.getCurrentLocation();
  //     print('Location: $position'); // Debug
  //
  //     if (position != null) {
  //       _hasLocation.value = true;
  //       print(
  //           'Getting stores with location: ${position.latitude}, ${position.longitude}'); // Debug
  //
  //       // Fetch stores from repository
  //       final result = await _storeRepository.getNearbyStores(
  //         latitude: position.latitude,
  //         longitude: position.longitude,
  //       );
  //
  //       print(
  //           'Repository result: ${result.isSuccess}, data: ${result.data?.length}'); // Debug
  //
  //       if (result.isSuccess && result.data != null) {
  //         _stores.value = result.data!;
  //         _allStores.value = result.data!; // Save for filtering
  //         print('Stores loaded: ${_stores.length}'); // Debug
  //       } else {
  //         _hasError.value = true;
  //         _errorMessage.value = result.message ?? 'Failed to fetch stores';
  //         print('Error from repository: ${result.message}'); // Debug
  //       }
  //     } else {
  //       _hasLocation.value = false;
  //       print('No location, getting all stores'); // Debug
  //
  //       // Fallback to get all stores without location
  //       final result = await _storeRepository.getAllStores();
  //       print(
  //           'All stores result: ${result.isSuccess}, data: ${result.data?.length}'); // Debug
  //
  //       if (result.isSuccess && result.data != null) {
  //         _stores.value = result.data!;
  //         _allStores.value = result.data!; // Save for filtering
  //         print('All stores loaded: ${_stores.length}'); // Debug
  //       } else {
  //         _hasError.value = true;
  //         _errorMessage.value = result.message ?? 'Failed to fetch stores';
  //         print('Error getting all stores: ${result.message}'); // Debug
  //       }
  //     }
  //   } catch (e) {
  //     print('Exception in fetchNearbyStores: $e'); // Debug
  //     _hasError.value = true;
  //     if (e is Exception) {
  //       final failure = ErrorHandler.handleException(e);
  //       _errorMessage.value = ErrorHandler.getErrorMessage(failure);
  //     } else {
  //       _errorMessage.value = 'An unexpected error occurred';
  //     }
  //   } finally {
  //     _isLoading.value = false;
  //     print(
  //         'fetchNearbyStores completed. Loading: ${_isLoading.value}, HasStores: $hasStores'); // Debug
  //   }
  // }

  Future<void> fetchNearbyStores() async {
    print('StoreController: Starting fetchNearbyStores'); // Debug
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      print('StoreController: Location: $position'); // Debug

      if (position != null) {
        _hasLocation.value = true;
        print(
            'StoreController: Getting stores with location: ${position.latitude}, ${position.longitude}'); // Debug

        // Fetch stores from repository
        final result = await _storeRepository.getNearbyStores(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        print(
            'StoreController: Repository result: ${result.isSuccess}, data: ${result.data?.length}'); // Debug

        if (result.isSuccess && result.data != null) {
          _stores.value = result.data!;
          _allStores.value = result.data!; // Save for filtering
          print(
              'StoreController: Nearby stores loaded: ${_stores.length}'); // Debug
        } else {
          _hasError.value = true;
          _errorMessage.value =
              result.message ?? 'Failed to fetch nearby stores';
          print(
              'StoreController: Error from repository: ${result.message}'); // Debug
        }
      } else {
        _hasLocation.value = false;
        print(
            'StoreController: No location, falling back to all stores'); // Debug
        // Fallback to all stores
        await fetchAllStores();
      }
    } catch (e) {
      print('StoreController: Exception in fetchNearbyStores: $e'); // Debug
      _hasError.value = true;
      if (e is Exception) {
        final failure = ErrorHandler.handleException(e);
        _errorMessage.value = ErrorHandler.getErrorMessage(failure);
      } else {
        _errorMessage.value = 'An unexpected error occurred';
      }
    } finally {
      _isLoading.value = false;
      print('StoreController: fetchNearbyStores completed'); // Debug
    }
  }

  Future<void> refreshStores() async {
    print('Refreshing stores'); // Debug
    await fetchAllStores();
    await fetchNearbyStores();
  }

  void sortStoresByDistance() {
    print('Sorting by distance'); // Debug
    _stores.sort((a, b) {
      final distanceA = a.distance ?? double.infinity;
      final distanceB = b.distance ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });
  }

  void sortStoresByRating() {
    print('Sorting by rating'); // Debug
    _stores.sort((a, b) {
      final ratingA = a.rating ?? 0.0;
      final ratingB = b.rating ?? 0.0;
      return ratingB.compareTo(ratingA); // Descending order
    });
  }

  void filterStores(String query) {
    print('Filtering stores with query: $query'); // Debug
    if (query.isEmpty) {
      _stores.value = List.from(_allStores);
      return;
    }

    // Filter stores by name
    final filteredStores = _allStores.where((store) {
      final name = store.name.toLowerCase();
      final address = store.address.toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || address.contains(searchQuery);
    }).toList();

    _stores.value = filteredStores;
    print('Filtered results: ${_stores.length}'); // Debug
  }
}
