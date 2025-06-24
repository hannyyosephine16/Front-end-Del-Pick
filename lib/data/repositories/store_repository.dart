// QUICK FIX: Ganti file lib/data/repositories/store_repository.dart dengan ini

import 'package:del_pick/data/providers/store_provider.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/core/utils/result.dart';
import '../../core/errors/error_handler.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';

class StoreRepository {
  final StoreProvider _storeProvider;

  StoreRepository(this._storeProvider);

  /// Get all stores with basic pagination
  Future<Result<PaginatedResponse<StoreModel>>> getAllStores({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _storeProvider.getAllStores(
        params: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final stores = (data['stores'] as List)
            .map((json) => StoreModel.fromJson(json))
            .toList();

        final paginatedResponse = PaginatedResponse<StoreModel>(
          // data: stores,
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          items: [],
          // limit: limit,
        );

        return Result.success(paginatedResponse);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch stores',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get nearby stores with location
  Future<Result<List<StoreModel>>> getNearbyStores({
    required double latitude,
    required double longitude,
    int limit = 20,
  }) async {
    try {
      final response = await _storeProvider.getNearbyStores(
        latitude: latitude,
        longitude: longitude,
        params: {
          'limit': limit.toString(),
          'sortBy': 'distance',
          'sortOrder': 'ASC',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final stores = (data['stores'] as List)
            .map((json) => StoreModel.fromJson(json))
            .toList();
        return Result.success(stores);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch nearby stores',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Search stores with pagination and filters
  Future<Result<PaginatedResponse<StoreModel>>> searchStores({
    String? search,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 10,
    String? status,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _storeProvider.searchStores(
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        limit: limit,
        status: status,
        latitude: latitude,
        longitude: longitude,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final stores = (data['stores'] as List)
            .map((json) => StoreModel.fromJson(json))
            .toList();

        final paginatedResponse = PaginatedResponse<StoreModel>(
          items: stores,
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
        );

        return Result.success(paginatedResponse);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to search stores',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get store by ID
  Future<Result<StoreModel>> getStoreById(int storeId) async {
    try {
      final response = await _storeProvider.getStoreById(storeId);

      if (response.statusCode == 200) {
        final store = StoreModel.fromJson(response.data['data']);
        return Result.success(store);
      } else {
        return Result.failure(response.data['message'] ?? 'Store not found');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get stores sorted by rating
  Future<Result<PaginatedResponse<StoreModel>>> getStoresSortedByRating({
    String sortOrder = 'DESC',
    int page = 1,
    int limit = 10,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (latitude != null) params['latitude'] = latitude.toString();
      if (longitude != null) params['longitude'] = longitude.toString();

      final response = await _storeProvider.getStoresSortedByRating(
        sortOrder: sortOrder,
        params: params,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final stores = (data['stores'] as List)
            .map((json) => StoreModel.fromJson(json))
            .toList();

        final paginatedResponse = PaginatedResponse<StoreModel>(
          // data: stores,
          items: [],
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          // limit: limit,
        );

        return Result.success(paginatedResponse);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch stores',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get stores sorted by distance
  Future<Result<PaginatedResponse<StoreModel>>> getStoresSortedByDistance({
    required double latitude,
    required double longitude,
    String sortOrder = 'ASC',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _storeProvider.getStoresSortedByDistance(
        latitude: latitude,
        longitude: longitude,
        sortOrder: sortOrder,
        params: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final stores = (data['stores'] as List)
            .map((json) => StoreModel.fromJson(json))
            .toList();

        final paginatedResponse = PaginatedResponse<StoreModel>(
          // data: stores,
          items: [],
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          // limit: limit,
        );

        return Result.success(paginatedResponse);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch stores',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Get active stores only
  Future<Result<PaginatedResponse<StoreModel>>> getActiveStores({
    int page = 1,
    int limit = 10,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (latitude != null) params['latitude'] = latitude.toString();
      if (longitude != null) params['longitude'] = longitude.toString();

      final response = await _storeProvider.getStoresByStatus(
        status: 'active',
        params: params,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final stores = (data['stores'] as List)
            .map((json) => StoreModel.fromJson(json))
            .toList();

        final paginatedResponse = PaginatedResponse<StoreModel>(
          // data: stores,
          items: [],
          totalItems: data['totalItems'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
          currentPage: data['currentPage'] ?? 1,
          // limit: limit,
        );

        return Result.success(paginatedResponse);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch active stores',
        );
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
// Future<Result<List<StoreModel>>> getAllStores() async {
//   try {
//     final response = await _storeProvider.getAllStores();
//
//     print('Response Status: ${response.statusCode}');
//     print('Response Data Type: ${response.data.runtimeType}');
//     print('Response Data: ${response.data}');
//
//     if (response.statusCode == 200) {
//       final responseData = response.data as Map<String, dynamic>;
//
//       // PERBAIKAN UTAMA: Akses stores dari dalam data object
//       if (responseData['data'] != null &&
//           responseData['data'] is Map<String, dynamic> &&
//           responseData['data']['stores'] != null) {
//         final storesData = responseData['data']['stores'] as List;
//         print('Found ${storesData.length} stores in response');
//
//         if (storesData.isNotEmpty) {
//           print('First store sample: ${storesData.first}');
//         }
//
//         final stores = storesData
//             .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
//             .toList();
//
//         print('Successfully parsed ${stores.length} stores');
//         print('=== StoreRepository.getAllStores SUCCESS ===');
//         return Result.success(stores);
//       } else {
//         print('ERROR: Invalid response structure');
//         print('data field type: ${responseData['data'].runtimeType}');
//         return Result.failure('Invalid response structure');
//       }
//     } else {
//       final errorMessage =
//           response.data['message'] ?? 'Failed to fetch stores';
//       print('API Error: $errorMessage');
//       return Result.failure(errorMessage);
//     }
//   } catch (e, stackTrace) {
//     print('=== StoreRepository.getAllStores ERROR ===');
//     print('Exception: $e');
//     print('StackTrace: $stackTrace');
//     return Result.failure('Error: $e');
//   }
// }
//
// Future<Result<List<StoreModel>>> getNearbyStores({
//   required double latitude,
//   required double longitude,
// }) async {
//   try {
//     print('=== StoreRepository.getNearbyStores START ===');
//     final response = await _storeProvider.getNearbyStores(
//       latitude: latitude,
//       longitude: longitude,
//     );
//
//     print('Nearby Response Status: ${response.statusCode}');
//     print('Nearby Response Data: ${response.data}');
//
//     if (response.statusCode == 200) {
//       final responseData = response.data as Map<String, dynamic>;
//
//       // Same fix for nearby stores
//       if (responseData['data'] != null &&
//           responseData['data'] is Map<String, dynamic> &&
//           responseData['data']['stores'] != null) {
//         final storesData = responseData['data']['stores'] as List;
//         print('Found ${storesData.length} nearby stores');
//
//         final stores = storesData
//             .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
//             .toList();
//
//         print('Successfully parsed ${stores.length} nearby stores');
//         return Result.success(stores);
//       } else {
//         return Result.failure('Invalid nearby response structure');
//       }
//     } else {
//       return Result.failure(
//         response.data['message'] ?? 'Failed to fetch nearby stores',
//       );
//     }
//   } catch (e) {
//     print('Nearby stores error: $e');
//     return Result.failure(e.toString());
//   }
// }
//
// Future<Result<StoreModel>> getStoreById(int id) async {
//   try {
//     final response = await _storeProvider.getStoreById(id);
//
//     if (response.statusCode == 200) {
//       final store =
//           StoreModel.fromJson(response.data['data'] as Map<String, dynamic>);
//       return Result.success(store);
//     } else {
//       return Result.failure(response.data['message'] ?? 'Store not found');
//     }
//   } catch (e) {
//     if (e is Exception) {
//       final failure = ErrorHandler.handleException(e);
//       return Result.failure(ErrorHandler.getErrorMessage(failure));
//     }
//     return Result.failure('An unexpected error occurred');
//   }
// }
