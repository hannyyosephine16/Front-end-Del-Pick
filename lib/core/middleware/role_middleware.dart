// lib/core/middleware/route_middleware.dart
// ✅ HANYA UNTUK GETX ROUTE NAVIGATION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/core/middleware/auth_middleware.dart';
import 'package:del_pick/app/routes/app_routes.dart';

/// Auth Middleware untuk GetX route navigation
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Skip untuk public routes
    if (_isPublicRoute(route)) {
      return null;
    }

    // Check authentication
    if (!AuthHelper.isAuthenticated()) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    return null;
  }

  bool _isPublicRoute(String? route) {
    if (route == null) return false;

    final publicRoutes = [
      Routes.SPLASH,
      Routes.LOGIN,
      Routes.REGISTER,
      Routes.FORGOT_PASSWORD,
      Routes.RESET_PASSWORD,
    ];

    return publicRoutes.contains(route);
  }
}

/// Role Middleware untuk route access control
class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;
  final String? redirectRoute;

  RoleMiddleware({required this.allowedRoles, this.redirectRoute});

  @override
  RouteSettings? redirect(String? route) {
    // Skip untuk public routes
    if (_isPublicRoute(route)) {
      return null;
    }

    // Check authentication first
    if (!AuthHelper.isAuthenticated()) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // Check role permission
    final userRole = AuthHelper.getCurrentUserRole();
    if (userRole == null || !allowedRoles.contains(userRole)) {
      _showAccessDeniedMessage();
      final redirectTo = redirectRoute ?? AuthHelper.getHomeRoute();
      return RouteSettings(name: redirectTo);
    }

    return null;
  }

  bool _isPublicRoute(String? route) {
    if (route == null) return false;

    final publicRoutes = [
      Routes.SPLASH,
      Routes.LOGIN,
      Routes.REGISTER,
      Routes.FORGOT_PASSWORD,
      Routes.RESET_PASSWORD,
    ];

    return publicRoutes.contains(route);
  }

  void _showAccessDeniedMessage() {
    Get.snackbar(
      'Access Denied',
      'You don\'t have permission to access this page',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
  }
}

/// Middleware untuk customer-only routes
class CustomerOnlyMiddleware extends RoleMiddleware {
  CustomerOnlyMiddleware() : super(allowedRoles: ['customer']);
}

/// Middleware untuk driver-only routes
class DriverOnlyMiddleware extends RoleMiddleware {
  DriverOnlyMiddleware() : super(allowedRoles: ['driver']);
}

/// Middleware untuk store-only routes
class StoreOnlyMiddleware extends RoleMiddleware {
  StoreOnlyMiddleware() : super(allowedRoles: ['store']);
}

/// Guest middleware - redirect logged in users
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AuthHelper.isAuthenticated()) {
      return RouteSettings(name: AuthHelper.getHomeRoute());
    }
    return null;
  }
}
