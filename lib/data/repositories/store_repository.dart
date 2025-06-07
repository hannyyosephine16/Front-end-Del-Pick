// lib/data/repositories/store_repository.dart
import 'package:get/get.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/providers/store_provider.dart';
import 'package:del_pick/core/errors/error_handler.dart';

class StoreRepository {
  final StoreProvider _storeProvider;

  StoreRepository(this._storeProvider);

  Future<Result<List<StoreModel>>> getAllStores({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _storeProvider.getAllStores(params: params);

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle the response structure dari postman result
        if (data['stores'] != null) {
          final List<dynamic> storesJson = data['stores'] as List<dynamic>;
          final stores = storesJson
              .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return Result.success(stores, data['message'] ?? 'Success');
        } else {
          return Result.failure('No stores data found');
        }
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to get stores');
      }
    } catch (e) {
      final failure = ErrorHandler.handleException(e as Exception);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  Future<Result<List<StoreModel>>> getNearbyStores({
    required double latitude,
    required double longitude,
    double? radius,
  }) async {
    try {
      final response = await _storeProvider.getNearbyStores(
        latitude: latitude,
        longitude: longitude,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['stores'] != null) {
          final List<dynamic> storesJson = data['stores'] as List<dynamic>;
          final stores = storesJson
              .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return Result.success(stores, data['message'] ?? 'Success');
        } else {
          return Result.failure('No stores found in your area');
        }
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to get nearby stores');
      }
    } catch (e) {
      final failure = ErrorHandler.handleException(e as Exception);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  Future<Result<StoreModel>> getStoreDetail(int storeId) async {
    try {
      final response = await _storeProvider.getStoreDetail(storeId);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['store'] != null) {
          final store =
              StoreModel.fromJson(data['store'] as Map<String, dynamic>);
          return Result.success(store, data['message'] ?? 'Success');
        } else {
          return Result.failure('Store not found');
        }
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to get store detail');
      }
    } catch (e) {
      final failure = ErrorHandler.handleException(e as Exception);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }
}
