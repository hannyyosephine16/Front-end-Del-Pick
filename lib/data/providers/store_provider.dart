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

  Future<Response> getStoreById(int storeId) async {
    return await _apiService.get('${ApiEndpoints.getAllStores}/$storeId');
  }

  Future<Response> searchStores({
    required String query,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'search': query,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      ...?params,
    };

    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }

  Future<Response> getStoresByCategory({
    required String category,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'category': category,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      ...?params,
    };

    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }

  Future<Response> getStoresWithFilters({
    String? search,
    String? category,
    String? sortBy,
    String? sortOrder,
    double? latitude,
    double? longitude,
    double? radius,
    String? status,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty)
      queryParams['sortOrder'] = sortOrder;
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (radius != null) queryParams['radius'] = radius.toString();
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }
}
