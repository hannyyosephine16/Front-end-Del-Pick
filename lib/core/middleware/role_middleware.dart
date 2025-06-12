import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;
  final String? redirectRoute;

  // ✅ CACHE untuk menghindari storage reads berulang
  static String? _cachedUserRole;
  static bool? _cachedIsLoggedIn;
  static DateTime? _cacheExpiry;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  RoleMiddleware({required this.allowedRoles, this.redirectRoute});

  @override
  RouteSettings? redirect(String? route) {
    try {
      final storageService = Get.find<StorageService>();

      // ✅ Use cached values if available and not expired
      final now = DateTime.now();
      if (_cacheExpiry == null || now.isAfter(_cacheExpiry!)) {
        _refreshCache(storageService);
        _cacheExpiry = now.add(_cacheTimeout);
      }

      // ✅ Check authentication first
      if (!(_cachedIsLoggedIn ?? false)) {
        clearCache();
        return const RouteSettings(name: Routes.LOGIN);
      }

      // ✅ Check role permission
      if (_cachedUserRole == null || !allowedRoles.contains(_cachedUserRole)) {
        _showAccessDeniedMessage();
        final redirectTo =
            redirectRoute ?? _getDefaultRouteForRole(_cachedUserRole);
        return RouteSettings(name: redirectTo);
      }

      return null; // Allow access
    } catch (e) {
      // ✅ Fallback on error
      return const RouteSettings(name: Routes.LOGIN);
    }
  }

  /// ✅ Refresh cache from storage
  void _refreshCache(StorageService storageService) {
    _cachedUserRole = storageService.readString(StorageConstants.userRole);
    _cachedIsLoggedIn = storageService.readBoolWithDefault(
      StorageConstants.isLoggedIn,
      false,
    );
  }

  /// ✅ Clear cache (call on logout)
  static void clearCache() {
    _cachedUserRole = null;
    _cachedIsLoggedIn = null;
    _cacheExpiry = null;
  }

  /// ✅ Show access denied message
  void _showAccessDeniedMessage() {
    Get.snackbar(
      'Access Denied',
      'You don\'t have permission to access this page',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// ✅ Get default route - hanya 3 role
  String _getDefaultRouteForRole(String? userRole) {
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
}

/// ✅ Middleware for customer-only routes
class CustomerOnlyMiddleware extends RoleMiddleware {
  CustomerOnlyMiddleware() : super(allowedRoles: ['customer']);
}

/// ✅ Middleware for driver-only routes
class DriverOnlyMiddleware extends RoleMiddleware {
  DriverOnlyMiddleware() : super(allowedRoles: ['driver']);
}

/// ✅ Middleware for store-only routes
class StoreOnlyMiddleware extends RoleMiddleware {
  StoreOnlyMiddleware() : super(allowedRoles: ['store']);
}

/// ✅ Middleware for authenticated users (any role)
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!RoleHelper.isAuthenticated()) {
      RoleMiddleware.clearCache();
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

/// ✅ Middleware for guest users (not logged in)
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (RoleHelper.isAuthenticated()) {
      return RouteSettings(name: RoleHelper.getHomeRoute());
    }
    return null;
  }
}

/// ✅ Helper class - simplified untuk 3 role saja
class RoleHelper {
  static final StorageService _storageService = Get.find<StorageService>();

  // ✅ Cache untuk performa
  static String? _cachedRole;
  static bool? _cachedAuth;
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheTimeout = Duration(seconds: 30);

  /// ✅ Get cached or fresh role
  static String? getCurrentRole() {
    _refreshCacheIfNeeded();
    return _cachedRole;
  }

  /// ✅ Check authentication with cache
  static bool isAuthenticated() {
    _refreshCacheIfNeeded();
    return _cachedAuth ?? false;
  }

  /// ✅ Refresh cache if expired
  static void _refreshCacheIfNeeded() {
    final now = DateTime.now();
    if (_lastCacheUpdate == null ||
        now.difference(_lastCacheUpdate!).compareTo(_cacheTimeout) > 0) {
      _cachedRole = _storageService.readString(StorageConstants.userRole);
      _cachedAuth = _storageService.readBoolWithDefault(
        StorageConstants.isLoggedIn,
        false,
      );
      _lastCacheUpdate = now;
    }
  }

  /// ✅ Clear cache on logout
  static void clearCache() {
    _cachedRole = null;
    _cachedAuth = null;
    _lastCacheUpdate = null;
    RoleMiddleware.clearCache();
  }

  /// ✅ Check specific role
  static bool hasRole(String role) {
    return getCurrentRole() == role;
  }

  /// ✅ Check multiple roles
  static bool hasAnyRole(List<String> roles) {
    final userRole = getCurrentRole();
    return userRole != null && roles.contains(userRole);
  }

  /// ✅ Role-specific checks - hanya 3 role
  static bool isCustomer() => hasRole('customer');
  static bool isDriver() => hasRole('driver');
  static bool isStore() => hasRole('store');

  /// ✅ Home route - hanya 3 role
  static String getHomeRoute() {
    final userRole = getCurrentRole();
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

  /// ✅ Check if user can access resource
  static bool canAccess(List<String> requiredRoles) {
    if (!isAuthenticated()) return false;
    return hasAnyRole(requiredRoles);
  }

  /// ✅ Valid roles untuk validasi
  static const List<String> validRoles = ['customer', 'driver', 'store'];

  /// ✅ Check if role is valid
  static bool isValidRole(String? role) {
    return role != null && validRoles.contains(role);
  }
}
