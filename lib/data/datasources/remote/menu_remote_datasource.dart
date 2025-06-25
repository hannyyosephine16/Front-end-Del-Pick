// lib/data/datasources/remote/menu_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class MenuRemoteDataSource {
  final ApiService _apiService;

  MenuRemoteDataSource(this._apiService);

  /// Get all menu items
  /// Backend: GET /api/v1/menu
  Future<Response> getAllMenuItems({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.getAllMenuItems,
      queryParameters: params,
    );
  }

  /// Get menu items by store ID
  /// Backend: GET /api/v1/menu/store/{store_id}
  Future<Response> getMenuItemsByStoreId(
    int storeId, {
    Map<String, dynamic>? params,
  }) async {
    return await _apiService.get(
      ApiEndpoints.getMenuItemsByStoreId(storeId),
      queryParameters: params,
    );
  }

  /// Get menu item by ID
  /// Backend: GET /api/v1/menu/{id}
  Future<Response> getMenuItemById(int menuItemId) async {
    return await _apiService.get(ApiEndpoints.getMenuItemById(menuItemId));
  }

  /// ✅ ADDED: Get menu items with advanced filters
  /// Backend: GET /api/v1/menu with query parameters
  Future<Response> getMenuItemsWithFilters({
    int? storeId,
    String? category,
    bool? isAvailable,
    double? minPrice,
    double? maxPrice,
    String? search,
    int? page,
    int? limit,
  }) async {
    // Build query parameters
    final Map<String, dynamic> queryParams = {};

    if (storeId != null) queryParams['storeId'] = storeId;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (isAvailable != null) queryParams['isAvailable'] = isAvailable;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    return await _apiService.get(
      ApiEndpoints.getAllMenuItems, // Use base menu endpoint with filters
      queryParameters: queryParams,
    );
  }

  /// Create menu item (Store only)
  /// Backend: POST /api/v1/menu
  Future<Response> createMenuItem(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createMenuItem, data: data);
  }

  /// Update menu item (Store only)
  /// Backend: PUT /api/v1/menu/{id}
  Future<Response> updateMenuItem(
    int menuItemId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.put(
      ApiEndpoints.updateMenuItem(menuItemId),
      data: data,
    );
  }

  /// ✅ ADDED: Update menu item status (Store only)
  /// Backend: PATCH /api/v1/menu/{id}/status
  Future<Response> updateMenuItemStatus(
    int menuItemId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.patch(
      ApiEndpoints.updateMenuItemStatus(menuItemId),
      data: data,
    );
  }

  /// Delete menu item (Store only)
  /// Backend: DELETE /api/v1/menu/{id}
  Future<Response> deleteMenuItem(int menuItemId) async {
    return await _apiService.delete(ApiEndpoints.deleteMenuItem(menuItemId));
  }
}
