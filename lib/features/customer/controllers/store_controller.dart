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
  final RxBool _isSearching = false.obs;
  final RxList<StoreModel> _stores = <StoreModel>[].obs;
  final RxList<StoreModel> _allStores = <StoreModel>[].obs; // Original data
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxBool _hasLocation = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _currentSortBy = 'distance'.obs; // distance, rating, name

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;
  List<StoreModel> get stores => _stores;
  List<StoreModel> get allStores => _allStores;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasLocation => _hasLocation.value;
  bool get hasStores => _stores.isNotEmpty;
  String get searchQuery => _searchQuery.value;
  String get currentSortBy => _currentSortBy.value;

  @override
  void onInit() {
    super.onInit();
    fetchNearbyStores();
  }

  Future<void> fetchNearbyStores() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        _hasLocation.value = true;

        // Fetch stores from repository
        final result = await _storeRepository.getNearbyStores(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        if (result.isSuccess && result.data != null) {
          _allStores.value = result.data!; // Store original data
          _applyCurrentFilters(); // Apply current filters and sorting
        } else {
          _hasError.value = true;
          _errorMessage.value = result.message ?? 'Failed to fetch stores';
        }
      } else {
        _hasLocation.value = false;
        // Fallback to get all stores without location
        final result = await _storeRepository.getAllStores();

        if (result.isSuccess && result.data != null) {
          _allStores.value = result.data!; // Store original data
          _applyCurrentFilters(); // Apply current filters and sorting
        } else {
          _hasError.value = true;
          _errorMessage.value = result.message ?? 'Failed to fetch stores';
        }
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

  Future<void> refreshStores() async {
    await fetchNearbyStores();
  }

  void searchStores(String query) {
    _isSearching.value = true;
    _searchQuery.value = query;

    // Add small delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      _applyCurrentFilters();
      _isSearching.value = false;
    });
  }

  void clearSearch() {
    _searchQuery.value = '';
    _applyCurrentFilters();
  }

  void _applyCurrentFilters() {
    List<StoreModel> filteredStores = List.from(_allStores);

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      filteredStores = filteredStores.where((store) {
        final name = store.name.toLowerCase();
        final address = store.address.toLowerCase();
        final query = _searchQuery.value.toLowerCase();

        return name.contains(query) || address.contains(query);
      }).toList();
    }

    // Apply sorting
    _applySorting(filteredStores);

    _stores.value = filteredStores;
  }

  void _applySorting(List<StoreModel> stores) {
    switch (_currentSortBy.value) {
      case 'distance':
        stores.sort((a, b) {
          final distanceA = a.distance ?? double.infinity;
          final distanceB = b.distance ?? double.infinity;
          return distanceA.compareTo(distanceB);
        });
        break;
      case 'rating':
        stores.sort((a, b) {
          final ratingA = a.rating ?? 0.0;
          final ratingB = b.rating ?? 0.0;
          return ratingB.compareTo(ratingA); // Descending order
        });
        break;
      case 'name':
        stores.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  void sortStoresByDistance() {
    _currentSortBy.value = 'distance';
    _applyCurrentFilters();

    Get.snackbar(
      'Sorted',
      'Restaurants sorted by distance',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void sortStoresByRating() {
    _currentSortBy.value = 'rating';
    _applyCurrentFilters();

    Get.snackbar(
      'Sorted',
      'Restaurants sorted by rating',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void sortStoresByName() {
    _currentSortBy.value = 'name';
    _applyCurrentFilters();

    Get.snackbar(
      'Sorted',
      'Restaurants sorted by name',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void filterOpenStores() {
    List<StoreModel> openStores =
        _allStores.where((store) => store.isOpenNow()).toList();
    _stores.value = openStores;

    Get.snackbar(
      'Filtered',
      'Showing only open restaurants',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void filterByRating(double minRating) {
    List<StoreModel> ratedStores = _allStores.where((store) {
      return (store.rating ?? 0.0) >= minRating;
    }).toList();
    _stores.value = ratedStores;

    Get.snackbar(
      'Filtered',
      'Showing restaurants with rating ≥ $minRating',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void resetFilters() {
    _searchQuery.value = '';
    _currentSortBy.value = 'distance';
    _applyCurrentFilters();

    Get.snackbar(
      'Reset',
      'All filters cleared',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // Get available categories for filtering
  List<String> get availableCategories {
    return _allStores
        .map((store) => store.description ?? 'Other')
        .toSet()
        .toList();
  }

  int get totalStoresCount => _allStores.length;
  int get filteredStoresCount => _stores.length;
}
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/core/errors/failures.dart';
// import 'package:del_pick/core/errors/error_handler.dart';
// import 'package:del_pick/data/models/store/store_model.dart';
// import 'package:del_pick/data/repositories/store_repository.dart';
// import 'package:del_pick/core/services/external/location_service.dart';
//
// import '../../../app/config/app_config.dart';
// import '../../../core/utils/distance_helper.dart';
//
// class StoreController extends GetxController {
//   final StoreRepository _storeRepository;
//   final LocationService _locationService;
//
//   StoreController({
//     required StoreRepository storeRepository,
//     required LocationService locationService,
//   })  : _storeRepository = storeRepository,
//         _locationService = locationService;
//
//   // Observable state
//   final RxBool _isLoading = false.obs;
//   final RxList<StoreModel> _stores = <StoreModel>[].obs;
//   final RxList<StoreModel> _allStores = <StoreModel>[].obs;
//   final RxString _errorMessage = ''.obs;
//   final RxBool _hasError = false.obs;
//   final RxBool _hasLocation = false.obs;
//   final Rx<Position?> _userLocation = Rx<Position?>(null);
//   // Getters
//   bool get isLoading => _isLoading.value;
//   List<StoreModel> get stores => _stores;
//   String get errorMessage => _errorMessage.value;
//   bool get hasError => _hasError.value;
//   bool get hasLocation => _hasLocation.value;
//   bool get hasStores => _stores.isNotEmpty;
//   Position? get userLocation => _userLocation.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     print('StoreController initialized'); // Debug
//     fetchAllStores(); // Debug
//     // fetchNearbyStores();
//   }
//
//   Future<void> fetchAllStores() async {
//     print('StoreController: Starting fetchAllStores'); // Debug
//     _isLoading.value = true;
//     _hasError.value = false;
//     _errorMessage.value = '';
//
//     try {
//       print('StoreController: Calling repository.getAllStores()'); // Debug
//
//       // Get current location first
//       await _getCurrentLocation();
//
//       final result = await _storeRepository.getAllStores();
//
//       print(
//           'StoreController: Repository result - Success: ${result.isSuccess}'); // Debug
//       if (result.data != null) {
//         print(
//             'StoreController: Repository returned ${result.data!.length} stores'); // Debug
//       }
//
//       if (result.isSuccess && result.data != null) {
//         _stores.value = result.data!;
//         _allStores.value = result.data!; // Save for filtering
//         print(
//             'StoreController: Stores loaded successfully: ${_stores.length}'); // Debug
//
//         // Debug: Print first store details
//         // if (_stores.isNotEmpty) {
//         //   print('StoreController: First store: ${_stores.first.name}'); // Debug
//         // }
//         // Calculate distances and sort by distance if location available
//         if (_hasLocation.value && _userLocation.value != null) {
//           _calculateDistancesAndSort();
//         } else {
//           // If no location, just show all stores
//           _stores.value = _allStores;
//         }
//       } else {
//         _hasError.value = true;
//         _errorMessage.value = result.message ?? 'Failed to fetch stores';
//         print(
//             'StoreController: Error from repository: ${result.message}'); // Debug
//       }
//     } catch (e) {
//       print('StoreController: Exception in fetchAllStores: $e'); // Debug
//       _hasError.value = true;
//       if (e is Exception) {
//         final failure = ErrorHandler.handleException(e);
//         _errorMessage.value = ErrorHandler.getErrorMessage(failure);
//       } else {
//         _errorMessage.value = 'An unexpected error occurred';
//       }
//     } finally {
//       _isLoading.value = false;
//       print(
//           'StoreController: fetchAllStores completed. Loading: ${_isLoading.value}, HasStores: $hasStores, HasError: $_hasError'); // Debug
//     }
//   }
//
//   // Future<void> fetchNearbyStores() async {
//   //   print('Starting fetchNearbyStores'); // Debug
//   //   _isLoading.value = true;
//   //   _hasError.value = false;
//   //   _errorMessage.value = '';
//   //
//   //   try {
//   //     // Get current location
//   //     final position = await _locationService.getCurrentLocation();
//   //     print('Location: $position'); // Debug
//   //
//   //     if (position != null) {
//   //       _hasLocation.value = true;
//   //       print(
//   //           'Getting stores with location: ${position.latitude}, ${position.longitude}'); // Debug
//   //
//   //       // Fetch stores from repository
//   //       final result = await _storeRepository.getNearbyStores(
//   //         latitude: position.latitude,
//   //         longitude: position.longitude,
//   //       );
//   //
//   //       print(
//   //           'Repository result: ${result.isSuccess}, data: ${result.data?.length}'); // Debug
//   //
//   //       if (result.isSuccess && result.data != null) {
//   //         _stores.value = result.data!;
//   //         _allStores.value = result.data!; // Save for filtering
//   //         print('Stores loaded: ${_stores.length}'); // Debug
//   //       } else {
//   //         _hasError.value = true;
//   //         _errorMessage.value = result.message ?? 'Failed to fetch stores';
//   //         print('Error from repository: ${result.message}'); // Debug
//   //       }
//   //     } else {
//   //       _hasLocation.value = false;
//   //       print('No location, getting all stores'); // Debug
//   //
//   //       // Fallback to get all stores without location
//   //       final result = await _storeRepository.getAllStores();
//   //       print(
//   //           'All stores result: ${result.isSuccess}, data: ${result.data?.length}'); // Debug
//   //
//   //       if (result.isSuccess && result.data != null) {
//   //         _stores.value = result.data!;
//   //         _allStores.value = result.data!; // Save for filtering
//   //         print('All stores loaded: ${_stores.length}'); // Debug
//   //       } else {
//   //         _hasError.value = true;
//   //         _errorMessage.value = result.message ?? 'Failed to fetch stores';
//   //         print('Error getting all stores: ${result.message}'); // Debug
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print('Exception in fetchNearbyStores: $e'); // Debug
//   //     _hasError.value = true;
//   //     if (e is Exception) {
//   //       final failure = ErrorHandler.handleException(e);
//   //       _errorMessage.value = ErrorHandler.getErrorMessage(failure);
//   //     } else {
//   //       _errorMessage.value = 'An unexpected error occurred';
//   //     }
//   //   } finally {
//   //     _isLoading.value = false;
//   //     print(
//   //         'fetchNearbyStores completed. Loading: ${_isLoading.value}, HasStores: $hasStores'); // Debug
//   //   }
//   // }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       final position = await _locationService.getCurrentLocation();
//       if (position != null) {
//         _userLocation.value = position;
//         _hasLocation.value = true;
//       } else {
//         _hasLocation.value = false;
//         // Use default location (IT Del)
//         _userLocation.value = Position(
//           latitude: AppConfig.defaultLatitude,
//           longitude: AppConfig.defaultLongitude,
//           timestamp: DateTime.now(),
//           accuracy: 0,
//           altitude: 0,
//           altitudeAccuracy: 0,
//           heading: 0,
//           speed: 0,
//           headingAccuracy: 0,
//           speedAccuracy: 0,
//         );
//       }
//     } catch (e) {
//       _hasLocation.value = false;
//       // Use default location as fallback
//       _userLocation.value = Position(
//         latitude: AppConfig.defaultLatitude,
//         longitude: AppConfig.defaultLongitude,
//         timestamp: DateTime.now(),
//         accuracy: 0,
//         altitude: 0,
//         altitudeAccuracy: 0,
//         heading: 0,
//         speed: 0,
//         headingAccuracy: 0,
//         speedAccuracy: 0,
//       );
//     }
//   }
//
//   void _calculateDistancesAndSort() {
//     if (_userLocation.value == null) return;
//
//     final userLat = _userLocation.value!.latitude;
//     final userLon = _userLocation.value!.longitude;
//
//     // Calculate distance for each store and create new list with distance
//     final storesWithDistance = _allStores.map((store) {
//       if (store.latitude != null && store.longitude != null) {
//         final distance = DistanceHelper.calculateDistance(
//           userLat,
//           userLon,
//           store.latitude!,
//           store.longitude!,
//         );
//
//         // Update store with calculated distance
//         return store.copyWith(distance: distance);
//       } else {
//         // If store doesn't have coordinates, put it at the end
//         return store.copyWith(distance: 9999.0);
//       }
//     }).toList();
//
//     // Sort by distance (closest first)
//     storesWithDistance.sort((a, b) {
//       final distanceA = a.distance ?? 9999.0;
//       final distanceB = b.distance ?? 9999.0;
//       return distanceA.compareTo(distanceB);
//     });
//
//     // Filter stores within delivery radius (optional - remove if you want all stores)
//     // final nearbyStores = storesWithDistance.where((store) {
//     //   final distance = store.distance ?? 9999.0;
//     //   return distance <= AppConfig.maxDeliveryRadius;
//     // }).toList();
//
//     _stores.value = storesWithDistance;
//   }
//
//   Future<void> fetchNearbyStores() async {
//     print('StoreController: Starting fetchNearbyStores'); // Debug
//     _isLoading.value = true;
//     _hasError.value = false;
//     _errorMessage.value = '';
//
//     try {
//       // Get current location
//       final position = await _locationService.getCurrentLocation();
//       print('StoreController: Location: $position'); // Debug
//
//       if (position != null) {
//         _hasLocation.value = true;
//         print(
//             'StoreController: Getting stores with location: ${position.latitude}, ${position.longitude}'); // Debug
//
//         // Fetch stores from repository
//         final result = await _storeRepository.getNearbyStores(
//           latitude: position.latitude,
//           longitude: position.longitude,
//         );
//
//         print(
//             'StoreController: Repository result: ${result.isSuccess}, data: ${result.data?.length}'); // Debug
//
//         if (result.isSuccess && result.data != null) {
//           _stores.value = result.data!;
//           _allStores.value = result.data!; // Save for filtering
//           print(
//               'StoreController: Nearby stores loaded: ${_stores.length}'); // Debug
//         } else {
//           _hasError.value = true;
//           _errorMessage.value =
//               result.message ?? 'Failed to fetch nearby stores';
//           print(
//               'StoreController: Error from repository: ${result.message}'); // Debug
//         }
//       } else {
//         _hasLocation.value = false;
//         print(
//             'StoreController: No location, falling back to all stores'); // Debug
//         // Fallback to all stores
//         await fetchAllStores();
//       }
//     } catch (e) {
//       print('StoreController: Exception in fetchNearbyStores: $e'); // Debug
//       _hasError.value = true;
//       if (e is Exception) {
//         final failure = ErrorHandler.handleException(e);
//         _errorMessage.value = ErrorHandler.getErrorMessage(failure);
//       } else {
//         _errorMessage.value = 'An unexpected error occurred';
//       }
//     } finally {
//       _isLoading.value = false;
//       print('StoreController: fetchNearbyStores completed'); // Debug
//     }
//   }
//
//   Future<void> refreshStores() async {
//     print('Refreshing stores'); // Debug
//     await fetchAllStores();
//     await fetchNearbyStores();
//   }
//
//   void sortStoresByDistance() {
//     print('Sorting by distance'); // Debug
//     _stores.sort((a, b) {
//       final distanceA = a.distance ?? double.infinity;
//       final distanceB = b.distance ?? double.infinity;
//       return distanceA.compareTo(distanceB);
//     });
//   }
//
//   void sortStoresByName() {
//     _stores.sort((a, b) => a.name.compareTo(b.name));
//   }
//
//   void sortStoresByRating() {
//     print('Sorting by rating'); // Debug
//     _stores.sort((a, b) {
//       final ratingA = a.rating ?? 0.0;
//       final ratingB = b.rating ?? 0.0;
//       return ratingB.compareTo(ratingA); // Descending order
//     });
//   }
//
//   void filterStores(String query) {
//     if (query.isEmpty) {
//       // Reset to original sorted list
//       if (_userLocation.value != null) {
//         _calculateDistancesAndSort();
//       } else {
//         _stores.value = _allStores;
//       }
//       return;
//     }
//
//     // Filter stores by name
//     final filteredStores = _allStores.where((store) {
//       final name = store.name.toLowerCase();
//       final address = store.address.toLowerCase();
//       final searchQuery = query.toLowerCase();
//
//       return name.contains(searchQuery) || address.contains(searchQuery);
//     }).toList();
//
//     // If user has location, calculate distances for filtered stores
//     if (_userLocation.value != null) {
//       final userLat = _userLocation.value!.latitude;
//       final userLon = _userLocation.value!.longitude;
//
//       final storesWithDistance = filteredStores.map((store) {
//         if (store.latitude != null && store.longitude != null) {
//           final distance = DistanceHelper.calculateDistance(
//             userLat,
//             userLon,
//             store.latitude!,
//             store.longitude!,
//           );
//           return store.copyWith(distance: distance);
//         } else {
//           return store.copyWith(distance: 9999.0);
//         }
//       }).toList();
//
//       // Sort filtered results by distance
//       storesWithDistance.sort((a, b) {
//         final distanceA = a.distance ?? 9999.0;
//         final distanceB = b.distance ?? 9999.0;
//         return distanceA.compareTo(distanceB);
//       });
//
//       _stores.value = storesWithDistance;
//     } else {
//       _stores.value = filteredStores;
//     }
//   }
//
//   void filterStoresByDeliveryRadius() {
//     if (_userLocation.value == null) return;
//
//     final userLat = _userLocation.value!.latitude;
//     final userLon = _userLocation.value!.longitude;
//
//     final nearbyStores = _allStores.where((store) {
//       if (store.latitude != null && store.longitude != null) {
//         return DistanceHelper.isWithinDeliveryRadius(
//           userLat,
//           userLon,
//           store.latitude!,
//           store.longitude!,
//           AppConfig.maxDeliveryRadius,
//         );
//       }
//       return false;
//     }).toList();
//
//     // Calculate distances and sort
//     final storesWithDistance = nearbyStores.map((store) {
//       final distance = DistanceHelper.calculateDistance(
//         userLat,
//         userLon,
//         store.latitude!,
//         store.longitude!,
//       );
//       return store.copyWith(distance: distance);
//     }).toList();
//
//     storesWithDistance.sort((a, b) {
//       final distanceA = a.distance ?? 9999.0;
//       final distanceB = b.distance ?? 9999.0;
//       return distanceA.compareTo(distanceB);
//     });
//
//     _stores.value = storesWithDistance;
//   }
//
//   void clearFilters() {
//     if (_userLocation.value != null) {
//       _calculateDistancesAndSort();
//     } else {
//       _stores.value = _allStores;
//     }
//   }
// }
