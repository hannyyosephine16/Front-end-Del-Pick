// lib/data/providers/store_provider.dart
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:get/get.dart' as getx;

class StoreProvider {
  final ApiService _apiService = getx.Get.find<ApiService>();

  Future<Response> getAllStores({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: params,
    );
  }

  Future<Response> getNearbyStores({
    required double latitude,
    required double longitude,
  }) async {
    final params = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: params,
    );
  }

  Future<Response> getStoreDetail(int storeId) async {
    return await _apiService.get(ApiEndpoints.getStoreById(storeId));
  }

  Future<Response> createStore(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createStore, data: data);
  }

  Future<Response> updateStore(int storeId, Map<String, dynamic> data) async {
    return await _apiService.put(ApiEndpoints.updateStore(storeId), data: data);
  }

  Future<Response> deleteStore(int storeId) async {
    return await _apiService.delete(ApiEndpoints.deleteStore(storeId));
  }
}
