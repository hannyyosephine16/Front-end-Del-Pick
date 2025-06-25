// lib/core/middleware/auth_middleware.dart
// ✅ HANYA UNTUK DIO INTERCEPTORS (HTTP Auth)
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

/// HTTP Auth Middleware untuk Dio requests - HANYA UNTUK API CALLS
class HttpAuthMiddleware {
  static final StorageService _storageService = getx.Get.find<StorageService>();

  /// Dio Interceptor untuk JWT token handling
  static InterceptorsWrapper getAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add JWT Bearer token
        final token = _storageService.readString(StorageConstants.authToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Standard headers
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';

        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _handleUnauthorized();
        } else if (error.response?.statusCode == 403) {
          _handleForbidden();
        }
        handler.next(error);
      },
    );
  }

  static Future<void> _handleUnauthorized() async {
    await _clearAuthData();
    final currentRoute = getx.Get.currentRoute;
    if (currentRoute != Routes.LOGIN &&
        currentRoute != Routes.REGISTER &&
        currentRoute != Routes.SPLASH) {
      getx.Get.offAllNamed(Routes.LOGIN);
      getx.Get.snackbar(
        'Session Expired',
        'Please login again to continue',
        snackPosition: getx.SnackPosition.TOP,
      );
    }
  }

  static void _handleForbidden() {
    getx.Get.snackbar(
      'Access Denied',
      'You don\'t have permission to perform this action',
      snackPosition: getx.SnackPosition.TOP,
    );
  }

  static Future<void> _clearAuthData() async {
    final keys = [
      StorageConstants.authToken,
      StorageConstants.userId,
      StorageConstants.userRole,
      StorageConstants.userEmail,
      StorageConstants.userName,
      StorageConstants.userPhone,
      StorageConstants.userAvatar,
      StorageConstants.fcmToken,
    ];

    for (final key in keys) {
      await _storageService.remove(key);
    }
    await _storageService.writeBool(StorageConstants.isLoggedIn, false);
  }
}

/// Auth Helper untuk checking authentication status
class AuthHelper {
  static final StorageService _storageService = getx.Get.find<StorageService>();

  static bool isAuthenticated() {
    final token = _storageService.readString(StorageConstants.authToken);
    final isLoggedIn =
        _storageService.readBoolWithDefault(StorageConstants.isLoggedIn, false);
    return token != null && token.isNotEmpty && isLoggedIn;
  }

  static String? getCurrentUserRole() {
    return _storageService.readString(StorageConstants.userRole);
  }

  static bool hasRole(String role) {
    final userRole = getCurrentUserRole();
    return userRole == role;
  }

  static bool isCustomer() => hasRole('customer');
  static bool isDriver() => hasRole('driver');
  static bool isStore() => hasRole('store');

  static String getHomeRoute() {
    final userRole = getCurrentUserRole();
    switch (userRole) {
      case 'customer':
        return Routes.CUSTOMER_HOME;
      case 'driver':
        return Routes.DRIVER_MAIN;
      case 'store':
        return Routes.STORE_DASHBOARD;
      default:
        return Routes.LOGIN;
    }
  }

  static Future<void> forceLogout() async {
    final keys = [
      StorageConstants.authToken,
      StorageConstants.userId,
      StorageConstants.userRole,
      StorageConstants.userEmail,
      StorageConstants.userName,
      StorageConstants.userPhone,
      StorageConstants.userAvatar,
      StorageConstants.fcmToken,
    ];

    for (final key in keys) {
      await _storageService.remove(key);
    }
    await _storageService.writeBool(StorageConstants.isLoggedIn, false);
    getx.Get.offAllNamed(Routes.LOGIN);
  }
}
