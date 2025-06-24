// lib/data/providers/menu_provider.dart - FIXED VERSION
import 'package:del_pick/data/datasources/remote/menu_remote_datasource.dart';
import 'package:dio/dio.dart';

class MenuProvider {
  final MenuRemoteDataSource _remoteDataSource;

  MenuProvider({
    required MenuRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ✅ Get all menu items - Backend: GET /menu
  Future<Response> getAllMenuItems({Map<String, dynamic>? params}) async {
    return await _remoteDataSource.getAllMenuItems(params: params);
  }

  // ✅ Get menu items by store ID - Backend: GET /menu/store/:store_id
  Future<Response> getMenuItemsByStoreId(
    int storeId, {
    Map<String, dynamic>? params,
  }) async {
    return await _remoteDataSource.getMenuItemsByStoreId(storeId,
        params: params);
  }

  // ✅ Get menu item by ID - Backend: GET /menu/:id
  Future<Response> getMenuItemById(int menuItemId) async {
    return await _remoteDataSource.getMenuItemById(menuItemId);
  }

  // ✅ Create menu item - Backend: POST /menu (store only)
  Future<Response> createMenuItem(Map<String, dynamic> data) async {
    return await _remoteDataSource.createMenuItem(data);
  }

  // ✅ Update menu item - Backend: PUT /menu/:id (store only)
  Future<Response> updateMenuItem(
    int menuItemId,
    Map<String, dynamic> data,
  ) async {
    return await _remoteDataSource.updateMenuItem(menuItemId, data);
  }

  // ✅ Delete menu item - Backend: DELETE /menu/:id (store only)
  Future<Response> deleteMenuItem(int menuItemId) async {
    return await _remoteDataSource.deleteMenuItem(menuItemId);
  }

  // ✅ Additional helper methods for better UX

  // Get available menu items by store (only is_available = true)
  Future<Response> getAvailableMenuItemsByStore(
    int storeId, {
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'is_available': true,
      ...?params,
    };

    return await _remoteDataSource.getMenuItemsByStoreId(
      storeId,
      params: queryParams,
    );
  }

  // Get menu items by category
  Future<Response> getMenuItemsByCategory(
    int storeId,
    String category, {
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'category': category,
      'is_available': true, // Only available items
      ...?params,
    };

    return await _remoteDataSource.getMenuItemsByStoreId(
      storeId,
      params: queryParams,
    );
  }

  // Search menu items within a store
  Future<Response> searchMenuItems(
    int storeId,
    String searchQuery, {
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'search': searchQuery,
      'is_available': true, // Only available items
      ...?params,
    };

    return await _remoteDataSource.getMenuItemsByStoreId(
      storeId,
      params: queryParams,
    );
  }

  // Get menu items with price range filter
  Future<Response> getMenuItemsInPriceRange(
    int storeId, {
    double? minPrice,
    double? maxPrice,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = <String, dynamic>{
      'is_available': true,
      ...?params,
    };

    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;

    return await _remoteDataSource.getMenuItemsByStoreId(
      storeId,
      params: queryParams,
    );
  }

  // Get popular menu items (could be based on order frequency)
  Future<Response> getPopularMenuItems(
    int storeId, {
    int limit = 10,
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {
      'is_available': true,
      'sortBy': 'popularity', // Backend might need to implement this
      'sortOrder': 'DESC',
      'limit': limit,
      ...?params,
    };

    return await _remoteDataSource.getMenuItemsByStoreId(
      storeId,
      params: queryParams,
    );
  }

  // Get menu categories for a store
  Future<Response> getMenuCategories(int storeId) async {
    final params = {
      'group_by': 'category',
      'is_available': true,
    };

    return await _remoteDataSource.getMenuItemsByStoreId(storeId,
        params: params);
  }
}
