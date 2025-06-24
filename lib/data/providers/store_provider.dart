// lib/data/providers/store_provider.dart - FIXED VERSION
import 'package:del_pick/data/datasources/remote/store_remote_datasource.dart';
import 'package:dio/dio.dart';

class StoreProvider {
  final StoreRemoteDataSource _remoteDataSource;

  StoreProvider({
    required StoreRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ✅ Get all stores - Backend: GET /stores
  Future<Response> getAllStores({Map<String, dynamic>? params}) async {
    return await _remoteDataSource.getAllStores(params: params);
  }

  // ✅ Get nearby stores - Backend: GET /stores with lat/lng params
  Future<Response> getNearbyStores({
    required double latitude,
    required double longitude,
    Map<String, dynamic>? params,
  }) async {
    return await _remoteDataSource.getNearbyStores(
      latitude: latitude,
      longitude: longitude,
      params: params,
    );
  }

  // ✅ Search stores with filters
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

    return await _remoteDataSource.getAllStores(params: params);
  }

  // ✅ Get store by ID - Backend: GET /stores/:id
  Future<Response> getStoreById(int storeId) async {
    // Note: Backend mungkin belum ada endpoint ini, bisa dikembangkan
    return await _remoteDataSource.getAllStores(
      params: {'id': storeId},
    );
  }

  // ✅ Get stores sorted by rating
  Future<Response> getStoresSortedByRating({
    String sortOrder = 'DESC',
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'sortBy': 'rating',
      'sortOrder': sortOrder,
      ...?params,
    };

    return await _remoteDataSource.getAllStores(params: queryParams);
  }

  // ✅ Get stores sorted by distance
  Future<Response> getStoresSortedByDistance({
    required double latitude,
    required double longitude,
    String sortOrder = 'ASC',
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'sortBy': 'distance',
      'sortOrder': sortOrder,
      'latitude': latitude,
      'longitude': longitude,
      ...?params,
    };

    return await _remoteDataSource.getNearbyStores(
      latitude: latitude,
      longitude: longitude,
      params: queryParams,
    );
  }

  // ✅ Get stores by status (active/inactive)
  Future<Response> getStoresByStatus({
    required String status,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'status': status,
      ...?params,
    };

    return await _remoteDataSource.getAllStores(params: queryParams);
  }

  // ✅ Get active stores only
  Future<Response> getActiveStores({
    Map<String, dynamic>? params,
  }) async {
    return await getStoresByStatus(
      status: 'active',
      params: params,
    );
  }

  // ✅ Get stores with menu items (for restaurant listing)
  Future<Response> getStoresWithMenus({
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'include': 'menu_items',
      ...?params,
    };

    return await _remoteDataSource.getAllStores(params: queryParams);
  }

  // ✅ Get popular stores (sorted by rating and review count)
  Future<Response> getPopularStores({
    int limit = 10,
    double? latitude,
    double? longitude,
  }) async {
    final params = <String, dynamic>{
      'sortBy': 'rating,review_count',
      'sortOrder': 'DESC',
      'limit': limit,
      'status': 'active',
    };

    if (latitude != null && longitude != null) {
      params['latitude'] = latitude;
      params['longitude'] = longitude;
    }

    return await _remoteDataSource.getAllStores(params: params);
  }

  // ✅ Get stores within radius
  Future<Response> getStoresWithinRadius({
    required double latitude,
    required double longitude,
    required double radiusKm,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radiusKm,
      'status': 'active', // Only active stores
      ...?params,
    };

    return await _remoteDataSource.getNearbyStores(
      latitude: latitude,
      longitude: longitude,
      params: queryParams,
    );
  }
}
