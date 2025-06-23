// lib/core/services/api/store_service.dart
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class StoreApiService {
  final ApiService _apiService;

  StoreApiService(this._apiService);

  // ✅ FIXED: Get all stores - sesuai backend GET /stores
  Future<Response> getStores({Map<String, dynamic>? queryParams}) async {
    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }

  // ✅ FIXED: Get store detail - sesuai backend GET /stores/:id
  Future<Response> getStoreDetail(int storeId) async {
    return await _apiService.get(ApiEndpoints.getStoreById(storeId));
  }

  // ✅ FIXED: Create store - sesuai backend POST /stores (admin only)
  Future<Response> createStore(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createStore, data: data);
  }

  // ✅ FIXED: Update store - sesuai backend PUT /stores/:id (admin only)
  Future<Response> updateStore(int storeId, Map<String, dynamic> data) async {
    return await _apiService.put(ApiEndpoints.updateStore(storeId), data: data);
  }

  // updateStoreProfile - backend tidak ada endpoint khusus
  // Store owner menggunakan auth profile endpoint

  // updateStoreStatus - backend tidak ada endpoint khusus status
  // Status diupdate melalui update store

  // Delete store - sesuai backend DELETE /stores/:id (admin only)
  Future<Response> deleteStore(int storeId) async {
    return await _apiService.delete(ApiEndpoints.deleteStore(storeId));
  }
}
