// lib/core/services/api/menu_item_service.dart - FIXED VERSION
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class MenuItemApiService {
  final ApiService _apiService;

  MenuItemApiService(this._apiService);

  // Get All Menu Itmes
  Future<Response> getAllMenuItems({Map<String, dynamic>? queryParams}) async {
    return await _apiService.get(
      ApiEndpoints.getAllMenuItems,
      queryParameters: queryParams,
    );
  }

  //Menu Items by Store
  Future<Response> getMenuItemsByStore(
    int storeId, {
    Map<String, dynamic>? queryParams,
  }) async {
    return await _apiService.get(
      ApiEndpoints.getMenuItemsByStoreId(storeId),
      queryParameters: queryParams,
    );
  }

  //Menu Item by Id
  Future<Response> getMenuItemById(int menuItemId) async {
    return await _apiService.get(ApiEndpoints.getMenuItemById(menuItemId));
  }

  // Create Menu by Store
  Future<Response> createMenuItem(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createMenuItem, data: data);
  }

  //  Update Menu by Store
  Future<Response> updateMenuItem(
    int menuItemId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.put(
      ApiEndpoints.updateMenuItem(menuItemId),
      data: data,
    );
  }

  // ✅ ADDED: Missing updateMenuItemStatus method
  Future<Response> updateMenuItemStatus(
    int menuItemId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.patch(
      ApiEndpoints.updateMenuItemStatus(menuItemId),
      data: data,
    );
  }

  // ✅ FIXED: Use helper method from ApiEndpoints
  Future<Response> deleteMenuItem(int menuItemId) async {
    return await _apiService.delete(ApiEndpoints.deleteMenuItem(menuItemId));
  }

  // ✅ ADDED: Helper method for filtered menu items
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
    return await _apiService.get(
      ApiEndpoints.getMenuItemsWithFilters(
        storeId: storeId,
        category: category,
        isAvailable: isAvailable,
        minPrice: minPrice,
        maxPrice: maxPrice,
        search: search,
        page: page,
        limit: limit,
      ),
    );
  }
}
