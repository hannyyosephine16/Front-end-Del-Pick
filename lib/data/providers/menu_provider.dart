import 'package:del_pick/data/datasources/remote/menu_remote_datasource.dart';
import 'package:dio/dio.dart';

class MenuProvider {
  final MenuRemoteDataSource _remoteDataSource;

  MenuProvider(this._remoteDataSource);

  /// Get all menu items - GET /menu
  Future<Response> getAllMenuItems({Map<String, dynamic>? params}) async {
    return await _remoteDataSource.getAllMenuItems(params: params);
  }

  /// Get menu items by store ID - GET /menu/store/:store_id
  Future<Response> getMenuItemsByStoreId(
      int storeId, {
        Map<String, dynamic>? params,
      }) async {
    return await _remoteDataSource.getMenuItemsByStoreId(storeId, params: params);
  }

  /// Get menu item by ID - GET /menu/:id
  Future<Response> getMenuItemById(int menuItemId) async {
    return await _remoteDataSource.getMenuItemById(menuItemId);
  }

  /// Create menu item - POST /menu (store only)
  Future<Response> createMenuItem(Map<String, dynamic> data) async {
    return await _remoteDataSource.createMenuItem(data);
  }

  /// Update menu item - PUT /menu/:id (store only)
  Future<Response> updateMenuItem(
      int menuItemId,
      Map<String, dynamic> data,
      ) async {
    return await _remoteDataSource.updateMenuItem(menuItemId, data);
  }

  /// Delete menu item - DELETE /menu/:id (store only)
  Future<Response> deleteMenuItem(int menuItemId) async {
    return await _remoteDataSource.deleteMenuItem(menuItemId);
  }

  /// Get available menu items by store (only is_available = true)
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

  /// Get menu items by category
  Future<Response> getMenuItemsByCategory(
      int storeId,
      String category, {
        Map<String, dynamic>? params,
      }) async {
    final queryParams = {
      'category': category,
      'is_available': true,
      ...?params,
    };

    return await _remoteDataSource.getMenuItemsByStoreId(
      storeId,
      params: queryParams,
    );
  }

  /// Search menu items within a store
  Future<Response> searchMenuItems(
      int storeId,
      String searchQuery, {
        Map<String, dynamic>? params,
      }) async {
    final queryParams = {
      'search': searchQuery,
      'is_available': true,
      ...?params,
    };

    return await _remoteDataSource.getMenuItemsByStoreId(
      storeId,
      params: queryParams,
    );
  }
}