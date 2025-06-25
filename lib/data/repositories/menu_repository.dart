// lib/data/repositories/menu_repository.dart
import 'package:del_pick/data/datasources/remote/menu_remote_datasource.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';

class MenuRepository {
  final MenuRemoteDataSource _remoteDataSource;

  MenuRepository(this._remoteDataSource);

  /// Get all menu items
  /// Backend: GET /api/v1/menu
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

  /// Get menu items by store ID
  /// Backend: GET /api/v1/menu/store/{store_id}
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

  /// Get menu item by ID
  /// Backend: GET /api/v1/menu/{id}
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

  /// Get menu items with advanced filters
  /// Backend: GET /api/v1/menu with query parameters
  Future<Result<List<MenuItemModel>>> getMenuItemsWithFilters({
    int? storeId,
    String? category,
    bool? isAvailable,
    double? minPrice,
    double? maxPrice,
    String? search,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.getMenuItemsWithFilters(
        storeId: storeId,
        category: category,
        isAvailable: isAvailable,
        minPrice: minPrice,
        maxPrice: maxPrice,
        search: search,
        page: page,
        limit: limit,
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

  /// Create new menu item (Store only)
  /// Backend: POST /api/v1/menu
  Future<Result<MenuItemModel>> createMenuItem(
      Map<String, dynamic> menuItemData) async {
    try {
      final response = await _remoteDataSource.createMenuItem(menuItemData);

      if (response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final menuItem = MenuItemModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
        return Result.success(menuItem);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to create menu item');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Update menu item (Store only)
  /// Backend: PUT /api/v1/menu/{id}
  Future<Result<MenuItemModel>> updateMenuItem(
    int menuItemId,
    Map<String, dynamic> menuItemData,
  ) async {
    try {
      final response = await _remoteDataSource.updateMenuItem(
        menuItemId,
        menuItemData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final menuItem = MenuItemModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
        return Result.success(menuItem);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to update menu item');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Update menu item status (Store only)
  /// Backend: PATCH /api/v1/menu/{id}/status
  Future<Result<MenuItemModel>> updateMenuItemStatus(
    int menuItemId,
    Map<String, dynamic> statusData,
  ) async {
    try {
      final response = await _remoteDataSource.updateMenuItemStatus(
        menuItemId,
        statusData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final menuItem = MenuItemModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
        return Result.success(menuItem);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to update menu item status');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Delete menu item (Store only)
  /// Backend: DELETE /api/v1/menu/{id}
  Future<Result<void>> deleteMenuItem(int menuItemId) async {
    try {
      final response = await _remoteDataSource.deleteMenuItem(menuItemId);

      if (response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to delete menu item');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Enhanced error handling sesuai dengan backend response structure
  String _handleDioError(DioException e) {
    final response = e.response;

    // Handle different HTTP status codes
    switch (e.response?.statusCode) {
      case 400:
        return _extractErrorMessage(response) ??
            'Bad request - Invalid data provided';
      case 401:
        return 'Unauthorized - Please login again';
      case 403:
        return 'Forbidden - You don\'t have permission to perform this action';
      case 404:
        return 'Not found - The requested resource was not found';
      case 422:
        return _extractErrorMessage(response) ?? 'Validation failed';
      case 429:
        return 'Too many requests - Please try again later';
      case 500:
        return 'Server error - Please try again later';
      default:
        if (e.type == DioExceptionType.connectionTimeout) {
          return 'Connection timeout - Please check your internet connection';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          return 'Request timeout - Please try again';
        } else if (e.type == DioExceptionType.connectionError) {
          return 'No internet connection';
        } else {
          return _extractErrorMessage(response) ?? 'Network error occurred';
        }
    }
  }

  /// Extract error message from response
  String? _extractErrorMessage(Response? response) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;

      // Try different possible error message fields
      if (data['message'] != null) {
        return data['message'] as String;
      } else if (data['error'] != null) {
        return data['error'] as String;
      } else if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is String) {
          return errors;
        } else if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        } else if (errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
      }
    }
    return null;
  }

  /// Helper method untuk pagination
  bool hasMoreData(Response response) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final pagination = data['pagination'] as Map<String, dynamic>?;

      if (pagination != null) {
        final currentPage = pagination['currentPage'] as int? ?? 1;
        final totalPages = pagination['totalPages'] as int? ?? 1;
        return currentPage < totalPages;
      }
    }
    return false;
  }

  /// Helper method untuk mendapatkan total items
  int getTotalItems(Response response) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      // Try different possible total fields
      if (data['totalItems'] != null) {
        return data['totalItems'] as int;
      } else if (data['total'] != null) {
        return data['total'] as int;
      } else if (data['pagination'] != null) {
        final pagination = data['pagination'] as Map<String, dynamic>;
        return pagination['totalItems'] as int? ?? 0;
      }
    }
    return 0;
  }
}
// import 'package:del_pick/data/datasources/remote/menu_remote_datasource.dart';
// import 'package:del_pick/data/models/menu/menu_item_model.dart';
// import 'package:del_pick/core/utils/result.dart';
// import 'package:dio/dio.dart';
//
// class MenuRepository {
//   final MenuRemoteDataSource _remoteDataSource;
//
//   MenuRepository(this._remoteDataSource);
//
//   Future<Result<List<MenuItemModel>>> getAllMenuItems({
//     Map<String, dynamic>? params,
//   }) async {
//     try {
//       final response = await _remoteDataSource.getAllMenuItems(params: params);
//
//       if (response.statusCode == 200) {
//         final responseData = response.data as Map<String, dynamic>;
//         final data = responseData['data'];
//
//         List<dynamic> menuItemsData;
//         if (data is List) {
//           menuItemsData = data;
//         } else if (data is Map<String, dynamic>) {
//           menuItemsData = data['menuItems'] as List? ?? [];
//         } else {
//           menuItemsData = [];
//         }
//
//         final menuItems = menuItemsData
//             .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
//             .toList();
//
//         return Result.success(menuItems);
//       } else {
//         return Result.failure(
//             response.data['message'] ?? 'Failed to fetch menu items');
//       }
//     } on DioException catch (e) {
//       return Result.failure(_handleDioError(e));
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   Future<Result<List<MenuItemModel>>> getMenuItemsByStoreId(
//     int storeId, {
//     Map<String, dynamic>? params,
//   }) async {
//     try {
//       final response = await _remoteDataSource.getMenuItemsByStoreId(
//         storeId,
//         params: params,
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = response.data as Map<String, dynamic>;
//         final data = responseData['data'];
//
//         List<dynamic> menuItemsData;
//         if (data is List) {
//           menuItemsData = data;
//         } else if (data is Map<String, dynamic>) {
//           menuItemsData = data['menuItems'] as List? ?? [];
//         } else {
//           menuItemsData = [];
//         }
//
//         final menuItems = menuItemsData
//             .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
//             .toList();
//
//         return Result.success(menuItems);
//       } else {
//         return Result.failure(
//             response.data['message'] ?? 'Failed to fetch menu items');
//       }
//     } on DioException catch (e) {
//       return Result.failure(_handleDioError(e));
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   Future<Result<MenuItemModel>> getMenuItemById(int menuItemId) async {
//     try {
//       final response = await _remoteDataSource.getMenuItemById(menuItemId);
//
//       if (response.statusCode == 200) {
//         final responseData = response.data as Map<String, dynamic>;
//         final menuItem = MenuItemModel.fromJson(
//             responseData['data'] as Map<String, dynamic>);
//         return Result.success(menuItem);
//       } else {
//         return Result.failure(
//             response.data['message'] ?? 'Menu item not found');
//       }
//     } on DioException catch (e) {
//       return Result.failure(_handleDioError(e));
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   String _handleDioError(DioException e) {
//     final response = e.response;
//     if (response?.data is Map<String, dynamic>) {
//       return response!.data['message'] ?? 'Network error occurred';
//     }
//     return 'Network error occurred';
//   }
// }
