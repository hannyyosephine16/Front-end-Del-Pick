import 'package:del_pick/data/datasources/remote/menu_remote_datasource.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';

class MenuRepository {
  final MenuRemoteDataSource _remoteDataSource;

  MenuRepository(this._remoteDataSource);

  Future<Result<List<MenuItemModel>>> getAllMenuItems({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _remoteDataSource.getAllMenuItems(params: params);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'];

        List<dynamic> menuItemsData;
        if (data is List) {
          menuItemsData = data;
        } else if (data is Map<String, dynamic>) {
          menuItemsData = data['menuItems'] as List? ?? [];
        } else {
          menuItemsData = [];
        }

        final menuItems = menuItemsData
            .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(menuItems);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to fetch menu items');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<MenuItemModel>>> getMenuItemsByStoreId(
    int storeId, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _remoteDataSource.getMenuItemsByStoreId(
        storeId,
        params: params,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'];

        List<dynamic> menuItemsData;
        if (data is List) {
          menuItemsData = data;
        } else if (data is Map<String, dynamic>) {
          menuItemsData = data['menuItems'] as List? ?? [];
        } else {
          menuItemsData = [];
        }

        final menuItems = menuItemsData
            .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(menuItems);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to fetch menu items');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<MenuItemModel>> getMenuItemById(int menuItemId) async {
    try {
      final response = await _remoteDataSource.getMenuItemById(menuItemId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final menuItem = MenuItemModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
        return Result.success(menuItem);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Menu item not found');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  String _handleDioError(DioException e) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      return response!.data['message'] ?? 'Network error occurred';
    }
    return 'Network error occurred';
  }
}
