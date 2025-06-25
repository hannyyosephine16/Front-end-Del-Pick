import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class StoreRemoteDataSource {
  final ApiService _apiService;

  StoreRemoteDataSource(this._apiService);

  // ✅ Get all stores - tetap menggunakan endpoint yang sama
  Future<Response> getAllStores({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: params,
    );
  }

  // ✅ Get nearby stores - menggunakan endpoint yang sama dengan parameter location
  Future<Response> getNearbyStores({
    required double latitude,
    required double longitude,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      ...?params,
    };
    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }

  // ✅ Get store by ID
  Future<Response> getStoreById(int storeId) async {
    return await _apiService.get('${ApiEndpoints.getStoreById}');
  }
}
