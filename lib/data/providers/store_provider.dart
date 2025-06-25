// ================================================================
// lib/data/providers/store_provider.dart - FIXED
// ================================================================
import 'package:del_pick/data/datasources/remote/store_remote_datasource.dart';
import 'package:dio/dio.dart';

class StoreProvider {
  final StoreRemoteDataSource _remoteDataSource;

  StoreProvider(this._remoteDataSource);

  /// Get all stores - GET /stores
  Future<Response> getAllStores({Map<String, dynamic>? params}) async {
    return await _remoteDataSource.getAllStores(params: params);
  }

  /// Get nearby stores - GET /stores with lat/lng params
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

  /// Search stores with filters
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

  /// Get active stores only
  Future<Response> getActiveStores({Map<String, dynamic>? params}) async {
    final queryParams = {
      'status': 'active',
      ...?params,
    };

    return await _remoteDataSource.getAllStores(params: queryParams);
  }

  /// Get stores within radius
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
      'status': 'active',
      ...?params,
    };

    return await _remoteDataSource.getNearbyStores(
      latitude: latitude,
      longitude: longitude,
      params: queryParams,
    );
  }

  /// Get popular stores
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
}
