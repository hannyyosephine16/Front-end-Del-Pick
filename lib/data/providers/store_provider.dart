// lib/data/providers/store_provider.dart - FIXED VERSION
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

  Future<Response> getStoreById(int storeId) async {
    return await _apiService.get(ApiEndpoints.getStoreById(storeId));
  }

  Future<Response> getStoreDetail(int storeId) async {
    return await _apiService.get(ApiEndpoints.getStoreById(storeId));
  }

  Future<Response> getNearbyStores({
    required double latitude,
    required double longitude,
    double? radius,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (radius != null) 'radius': radius,
      ...?params,
    };

    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }

  Future<Response> searchStores({
    String? search,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
    String? status,
    double? latitude,
    double? longitude,
  }) async {
    final params = <String, dynamic>{};

    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (status != null) params['status'] = status;
    if (latitude != null) params['latitude'] = latitude;
    if (longitude != null) params['longitude'] = longitude;

    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: params,
    );
  }

  Future<Response> getStoresSortedByRating({
    String sortOrder = 'DESC',
    Map<String, dynamic>? params,
  }) async {
    final queryParams = <String, dynamic>{
      'sortBy': 'rating',
      'sortOrder': sortOrder,
      ...?params,
    };

    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }

  Future<Response> getStoresSortedByDistance({
    required double latitude,
    required double longitude,
    String sortOrder = 'ASC',
    Map<String, dynamic>? params,
  }) async {
    final queryParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'sortBy': 'distance',
      'sortOrder': sortOrder,
      ...?params,
    };

    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }

  Future<Response> getStoresByStatus({
    required String status,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = <String, dynamic>{
      'status': status,
      ...?params,
    };

    return await _apiService.get(
      ApiEndpoints.getAllStores,
      queryParameters: queryParams,
    );
  }

  Future<Response> getStoreOrders({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.storeOrders,
      queryParameters: params,
    );
  }

  Future<Response> processOrder(int orderId, Map<String, dynamic> data) async {
    return await _apiService.post(
      ApiEndpoints.processOrder(orderId),
      data: data,
    );
  }

  Future<Response> updateOrderStatus(
      int orderId, Map<String, dynamic> data) async {
    return await _apiService.patch(
      ApiEndpoints.updateOrderStatus(orderId),
      data: data,
    );
  }
}
