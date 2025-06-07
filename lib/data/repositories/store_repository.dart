// QUICK FIX: Ganti file lib/data/repositories/store_repository.dart dengan ini

import 'package:del_pick/data/providers/store_provider.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/core/utils/result.dart';

class StoreRepository {
  final StoreProvider _storeProvider;

  StoreRepository(this._storeProvider);

  Future<Result<List<StoreModel>>> getAllStores() async {
    try {
      print('=== StoreRepository.getAllStores START ===');
      final response = await _storeProvider.getAllStores();

      print('Response Status: ${response.statusCode}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // PERBAIKAN UTAMA: Akses stores dari dalam data object
        if (responseData['data'] != null &&
            responseData['data'] is Map<String, dynamic> &&
            responseData['data']['stores'] != null) {
          final storesData = responseData['data']['stores'] as List;
          print('Found ${storesData.length} stores in response');

          if (storesData.isNotEmpty) {
            print('First store sample: ${storesData.first}');
          }

          final stores = storesData
              .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
              .toList();

          print('Successfully parsed ${stores.length} stores');
          print('=== StoreRepository.getAllStores SUCCESS ===');
          return Result.success(stores);
        } else {
          print('ERROR: Invalid response structure');
          print('data field type: ${responseData['data'].runtimeType}');
          return Result.failure('Invalid response structure');
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to fetch stores';
        print('API Error: $errorMessage');
        return Result.failure(errorMessage);
      }
    } catch (e, stackTrace) {
      print('=== StoreRepository.getAllStores ERROR ===');
      print('Exception: $e');
      print('StackTrace: $stackTrace');
      return Result.failure('Error: $e');
    }
  }

  Future<Result<List<StoreModel>>> getNearbyStores({
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('=== StoreRepository.getNearbyStores START ===');
      final response = await _storeProvider.getNearbyStores(
        latitude: latitude,
        longitude: longitude,
      );

      print('Nearby Response Status: ${response.statusCode}');
      print('Nearby Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Same fix for nearby stores
        if (responseData['data'] != null &&
            responseData['data'] is Map<String, dynamic> &&
            responseData['data']['stores'] != null) {
          final storesData = responseData['data']['stores'] as List;
          print('Found ${storesData.length} nearby stores');

          final stores = storesData
              .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
              .toList();

          print('Successfully parsed ${stores.length} nearby stores');
          return Result.success(stores);
        } else {
          return Result.failure('Invalid nearby response structure');
        }
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch nearby stores',
        );
      }
    } catch (e) {
      print('Nearby stores error: $e');
      return Result.failure(e.toString());
    }
  }
}
