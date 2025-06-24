// lib/core/middleware/role_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;
  final String? redirectRoute;

  // Cache untuk performa
  static String? _cachedUserRole;
  static bool? _cachedIsLoggedIn;
  static DateTime? _cacheExpiry;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  RoleMiddleware({required this.allowedRoles, this.redirectRoute});

  @override
  RouteSettings? redirect(String? route) {
    // ✅ PENTING: Skip middleware untuk route auth agar tidak loop
    if (route == Routes.LOGIN ||
        route == Routes.REGISTER ||
        route == Routes.FORGOT_PASSWORD ||
        route == Routes.RESET_PASSWORD ||
        route == Routes.SPLASH) {
      return null; // Biarkan akses route tersebut
    }

    try {
      final storageService = Get.find<StorageService>();

      // Use cached values if available and not expired
      final now = DateTime.now();
      if (_cacheExpiry == null || now.isAfter(_cacheExpiry!)) {
        _refreshCache(storageService);
        _cacheExpiry = now.add(_cacheTimeout);
      }

      // Check authentication first
      if (!(_cachedIsLoggedIn ?? false)) {
        clearCache();
        return const RouteSettings(name: Routes.LOGIN);
      }

      // Check role permission
      if (_cachedUserRole == null || !allowedRoles.contains(_cachedUserRole)) {
        _showAccessDeniedMessage();
        final redirectTo =
            redirectRoute ?? _getDefaultRouteForRole(_cachedUserRole);
        return RouteSettings(name: redirectTo);
      }

      return null; // Allow access
    } catch (e) {
      // Fallback on error
      return const RouteSettings(name: Routes.LOGIN);
    }
  }

  void _refreshCache(StorageService storageService) {
    _cachedUserRole = storageService.readString(StorageConstants.userRole);
    _cachedIsLoggedIn = storageService.readBoolWithDefault(
      StorageConstants.isLoggedIn,
      false,
    );
  }

  static void clearCache() {
    _cachedUserRole = null;
    _cachedIsLoggedIn = null;
    _cacheExpiry = null;
  }

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

/// ✅ Middleware untuk customer-only routes
class CustomerOnlyMiddleware extends RoleMiddleware {
  CustomerOnlyMiddleware() : super(allowedRoles: ['customer']);
}

/// ✅ Middleware untuk driver-only routes
class DriverOnlyMiddleware extends RoleMiddleware {
  DriverOnlyMiddleware() : super(allowedRoles: ['driver']);
}

/// ✅ Middleware untuk store-only routes
class StoreOnlyMiddleware extends RoleMiddleware {
  StoreOnlyMiddleware() : super(allowedRoles: ['store']);
}

/// ✅ PERBAIKAN: AuthMiddleware yang aman dari loop
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // ✅ PENTING: Skip middleware untuk route auth agar tidak loop
    if (route == Routes.LOGIN ||
        route == Routes.REGISTER ||
        route == Routes.FORGOT_PASSWORD ||
        route == Routes.RESET_PASSWORD ||
        route == Routes.SPLASH) {
      return null; // Biarkan akses route tersebut
    }

    if (!RoleHelper.isAuthenticated()) {
      RoleMiddleware.clearCache();
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

/// ✅ Middleware untuk guest users (belum login)
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (RoleHelper.isAuthenticated()) {
      return RouteSettings(name: RoleHelper.getHomeRoute());
    }
    return null;
  }
}

/// ✅ Helper class
class RoleHelper {
  static final StorageService _storageService = Get.find<StorageService>();

  // Cache untuk performa
  static String? _cachedRole;
  static bool? _cachedAuth;
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheTimeout = Duration(seconds: 30);

  static String? getCurrentRole() {
    _refreshCacheIfNeeded();
    return _cachedRole;
  }

  static bool isAuthenticated() {
    _refreshCacheIfNeeded();
    return _cachedAuth ?? false;
  }

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

  static void clearCache() {
    _cachedRole = null;
    _cachedAuth = null;
    _lastCacheUpdate = null;
    RoleMiddleware.clearCache();
  }

  static bool hasRole(String role) {
    return getCurrentRole() == role;
  }

  static bool hasAnyRole(List<String> roles) {
    final userRole = getCurrentRole();
    return userRole != null && roles.contains(userRole);
  }

  static bool isCustomer() => hasRole('customer');
  static bool isDriver() => hasRole('driver');
  static bool isStore() => hasRole('store');

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

  static bool canAccess(List<String> requiredRoles) {
    if (!isAuthenticated()) return false;
    return hasAnyRole(requiredRoles);
  }

  static const List<String> validRoles = ['customer', 'driver', 'store'];

  static bool isValidRole(String? role) {
    return role != null && validRoles.contains(role);
  }
}
