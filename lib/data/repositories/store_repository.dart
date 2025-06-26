import 'package:del_pick/data/datasources/remote/store_remote_datasource.dart';
import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';

class StoreRepository {
  final StoreRemoteDataSource _storeRemoteDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  StoreRepository(
    this._storeRemoteDataSource,
    this._authRemoteDataSource,
    this._authLocalDataSource,
  );

  // ✅ FIXED: Match backend API response structure
  Future<Result<List<StoreModel>>> getAllStores({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response =
          await _storeRemoteDataSource.getAllStores(params: params);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        // Backend returns data as array directly
        final storesList = responseData['data'] as List;

        final stores = storesList
            .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(stores);
      } else {
        final message =
            response.data != null && response.data is Map<String, dynamic>
                ? response.data['message'] ?? 'Failed to fetch stores'
                : 'Failed to fetch stores';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<StoreModel>>> getNearbyStores({
    required double latitude,
    required double longitude,
    int limit = 20,
  }) async {
    try {
      final response = await _storeRemoteDataSource.getNearbyStores(
        latitude: latitude,
        longitude: longitude,
        params: {'limit': limit.toString()},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        // Match getAllStores structure
        final storesList = responseData['data'] as List;

        final stores = storesList
            .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(stores);
      } else {
        final message =
            response.data != null && response.data is Map<String, dynamic>
                ? response.data['message'] ?? 'Failed to fetch nearby stores'
                : 'Failed to fetch nearby stores';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ Get store by ID (untuk customer yang mau lihat detail store)
  Future<Result<StoreModel>> getStoreById(int storeId) async {
    try {
      final response = await _storeRemoteDataSource.getStoreById(storeId);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final storeData = responseData['data'] as Map<String, dynamic>;

        final store = StoreModel.fromJson(storeData);
        return Result.success(store);
      } else {
        final message =
            response.data != null && response.data is Map<String, dynamic>
                ? response.data['message'] ?? 'Store not found'
                : 'Store not found';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ UPDATED: Get current store dari local storage (untuk store owner)
  Future<Result<StoreModel>> getCurrentStore() async {
    try {
      // Prioritas 1: Ambil store data dari local storage
      final storeData = await _authLocalDataSource.getStoreData();

      if (storeData != null) {
        final store = StoreModel.fromJson(storeData);
        return Result.success(store);
      }

      // Prioritas 2: Ambil dari login session - field 'store'
      final loginSession = await _authLocalDataSource.getLoginSession();
      if (loginSession != null && loginSession['store'] != null) {
        final storeSessionData = loginSession['store'] as Map<String, dynamic>;
        final store = StoreModel.fromJson(storeSessionData);

        // Save to local storage for future access
        await _authLocalDataSource.saveStoreData(storeSessionData);

        return Result.success(store);
      }

      // Prioritas 3: Ambil dari user.owner (sesuai response login)
      if (loginSession != null && loginSession['user'] != null) {
        final userData = loginSession['user'] as Map<String, dynamic>;
        if (userData['owner'] != null) {
          final ownerData = userData['owner'] as Map<String, dynamic>;
          final store = StoreModel.fromJson(ownerData);

          // Save to local storage for future access
          await _authLocalDataSource.saveStoreData(ownerData);

          return Result.success(store);
        }
      }

      return Result.failure('Store data not found in local storage');
    } catch (e) {
      return Result.failure('Failed to get current store: ${e.toString()}');
    }
  }

  // ✅ FIXED: Refresh current store dari server (via profile endpoint)
  Future<Result<StoreModel>> refreshCurrentStore() async {
    try {
      // getProfile() mengembalikan Map<String, dynamic>, bukan Response
      final profileData = await _authRemoteDataSource.getProfile();

      // Extract store data from profile response
      Map<String, dynamic>? storeData;

      // Sesuai struktur response login: user.owner berisi data store
      if (profileData['owner'] != null) {
        // Jika user role store, store data ada di field 'owner'
        storeData = profileData['owner'] as Map<String, dynamic>;
      } else if (profileData['store'] != null) {
        // Fallback jika ada field 'store' langsung
        storeData = profileData['store'] as Map<String, dynamic>;
      }

      if (storeData == null) {
        return Result.failure('Store data not found in profile response');
      }

      // Save updated store data ke local storage
      await _authLocalDataSource.saveStoreData(storeData);

      final store = StoreModel.fromJson(storeData);
      return Result.success(store);
    } catch (e) {
      // Handle both DioException dan general exceptions
      if (e is DioException) {
        return Result.failure(_handleDioError(e));
      }
      return Result.failure('Failed to refresh store data: ${e.toString()}');
    }
  }

  // ✅ Search stores (untuk customer mencari toko)
  Future<Result<List<StoreModel>>> searchStores({
    required String query,
    Map<String, dynamic>? params,
  }) async {
    try {
      final searchParams = {
        'search': query,
        ...?params,
      };

      final response =
          await _storeRemoteDataSource.getAllStores(params: searchParams);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final storesList = responseData['data'] as List;

        final stores = storesList
            .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(stores);
      } else {
        final message =
            response.data != null && response.data is Map<String, dynamic>
                ? response.data['message'] ?? 'Search failed'
                : 'Search failed';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ Get stores with menu items (untuk customer melihat store dengan menu)
  Future<Result<List<StoreModel>>> getStoresWithMenu({
    Map<String, dynamic>? params,
  }) async {
    try {
      // Add include parameter untuk ambil menu items
      final requestParams = {
        'include': 'menu_items',
        ...?params,
      };

      final response =
          await _storeRemoteDataSource.getAllStores(params: requestParams);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final storesList = responseData['data'] as List;

        final stores = storesList
            .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(stores);
      } else {
        final message =
            response.data != null && response.data is Map<String, dynamic>
                ? response.data['message'] ?? 'Failed to fetch stores'
                : 'Failed to fetch stores';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ Update local store data (setelah dapat update dari server)
  Future<void> updateLocalStoreData(Map<String, dynamic> storeData) async {
    try {
      await _authLocalDataSource.saveStoreData(storeData);
    } catch (e) {
      print('Error updating local store data: $e');
    }
  }

  // ✅ Get store status dari local storage
  Future<String?> getStoreStatus() async {
    try {
      return await _authLocalDataSource.getStoreStatus();
    } catch (e) {
      print('Error getting store status: $e');
      return null;
    }
  }

  // ✅ Check if store is active
  Future<bool> isStoreActive() async {
    try {
      final status = await getStoreStatus();
      return status == 'active';
    } catch (e) {
      return false;
    }
  }

  // ✅ Clear store data dari local storage
  Future<void> clearStoreData() async {
    try {
      await _authLocalDataSource
          .clearAuthData(); // This will clear store data too
    } catch (e) {
      print('Error clearing store data: $e');
    }
  }

  // ✅ Get store opening hours and status
  Future<Result<Map<String, dynamic>>> getStoreOperationalStatus(
      int storeId) async {
    try {
      final response = await _storeRemoteDataSource.getStoreById(storeId);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final storeData = responseData['data'] as Map<String, dynamic>;

        // Extract operational info
        final operationalStatus = {
          'isOpen': _isStoreOpen(storeData),
          'openTime': storeData['open_time'],
          'closeTime': storeData['close_time'],
          'status': storeData['status'],
          'isActive': storeData['status'] == 'active',
        };

        return Result.success(operationalStatus);
      } else {
        final message =
            response.data != null && response.data is Map<String, dynamic>
                ? response.data['message'] ?? 'Failed to get store status'
                : 'Failed to get store status';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ Helper method to check if store is currently open
  bool _isStoreOpen(Map<String, dynamic> storeData) {
    try {
      if (storeData['status'] != 'active') return false;

      final openTime = storeData['open_time'] as String?;
      final closeTime = storeData['close_time'] as String?;

      if (openTime == null || closeTime == null)
        return true; // Assume 24/7 if no times set

      final now = DateTime.now();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Simple time comparison (assumes same day operation)
      return currentTime.compareTo(openTime) >= 0 &&
          currentTime.compareTo(closeTime) <= 0;
    } catch (e) {
      return false; // Default to closed if unable to determine
    }
  }

  // ✅ Get current store info (untuk quick access tanpa error handling)
  Future<Map<String, dynamic>?> getCurrentStoreInfo() async {
    try {
      final result = await getCurrentStore();
      if (result.isSuccess && result.data != null) {
        return result.data!.toJson();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ Get store ID dari local storage (untuk quick access)
  Future<int?> getCurrentStoreId() async {
    try {
      final storeData = await _authLocalDataSource.getStoreData();
      if (storeData != null && storeData['id'] != null) {
        return storeData['id'] as int?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ Check if current user is store owner
  Future<bool> isCurrentUserStoreOwner() async {
    try {
      final userRole = await _authLocalDataSource.getUserRole();
      final storeData = await _authLocalDataSource.getStoreData();
      return userRole == 'store' && storeData != null;
    } catch (e) {
      return false;
    }
  }

  // ✅ Sync store data dengan server (untuk periodic sync)
  Future<Result<StoreModel>> syncStoreData() async {
    try {
      // Hanya sync jika user adalah store owner
      final isStoreOwner = await isCurrentUserStoreOwner();
      if (!isStoreOwner) {
        return Result.failure('User is not a store owner');
      }

      // Refresh data dari server
      return await refreshCurrentStore();
    } catch (e) {
      return Result.failure('Failed to sync store data: ${e.toString()}');
    }
  }

  // ✅ Error handler dengan proper null checking
  String _handleDioError(DioException e) {
    final response = e.response;
    if (response?.data != null && response!.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return data['message'] ?? 'Network error occurred';
    }

    // Handle different DioException types
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error occurred';
    }
  }
}
