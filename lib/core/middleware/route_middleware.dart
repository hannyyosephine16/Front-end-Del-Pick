// lib/core/middleware/route_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/services/external/permission_service.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';

// ✅ Auth Middleware - Check if user is authenticated
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();
      final isLoggedIn = authController.isLoggedIn.value;

      if (!isLoggedIn && _requiresAuth(route)) {
        return const RouteSettings(name: Routes.LOGIN);
      }

      return null;
    } catch (e) {
      print('Auth middleware error: $e');
      return const RouteSettings(name: Routes.LOGIN);
    }
  }

  bool _requiresAuth(String? route) {
    if (route == null) return false;

    final protectedRoutes = [
      Routes.CUSTOMER_HOME,
      Routes.DRIVER_HOME,
      Routes.STORE_DASHBOARD,
      Routes.PROFILE,
    ];
    return protectedRoutes.contains(route);
  }
}

// ✅ Role Middleware - Check if user has access to route based on role
class RoleMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();
      final isLoggedIn = authController.isLoggedIn.value;
      final userRole = authController.userRole.value;

      if (isLoggedIn && !_canAccessWithRole(route, userRole)) {
        // Redirect to appropriate home based on role
        final defaultRoute = _getDefaultRouteForRole(userRole);
        return RouteSettings(name: defaultRoute);
      }

      return null;
    } catch (e) {
      print('Role middleware error: $e');
      return const RouteSettings(name: Routes.LOGIN);
    }
  }

  bool _canAccessWithRole(String? route, String role) {
    if (route == null || route.isEmpty) return false;

    switch (role.toLowerCase()) {
      case 'customer':
        return route.startsWith('/customer');
      case 'driver':
        return route.startsWith('/driver');
      case 'store':
        return route.startsWith('/store');
      default:
        return false;
    }
  }

  String _getDefaultRouteForRole(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return Routes.CUSTOMER_HOME;
      case 'driver':
        return Routes.DRIVER_HOME;
      case 'store':
        return Routes.STORE_DASHBOARD;
      default:
        return Routes.LOGIN;
    }
  }
}

// ✅ Permission Middleware - Check location/camera permissions
class PermissionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      // Check if route requires location permission
      if (!_requiresLocation(route)) {
        return null; // Route doesn't need location, continue
      }

      // Try to get permission service
      final permissionService = Get.find<PermissionService>();

      // Get permission status with explicit boolean conversion
      bool hasLocationPermission = false;
      try {
        final permissionResult = permissionService.hasLocationPermission();
        hasLocationPermission = (permissionResult == true);
      } catch (e) {
        print('Permission check error: $e');
        hasLocationPermission = false;
      }

      // If no permission, show dialog and redirect
      if (hasLocationPermission == false) {
        // Show permission request dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showPermissionDialog(permissionService);
        });

        // Return to previous route or fallback
        final previousRoute = Get.previousRoute;
        final fallbackRoute =
            (previousRoute.isNotEmpty) ? previousRoute : Routes.LOGIN;
        return RouteSettings(name: fallbackRoute);
      }

      return null;
    } catch (e) {
      // If permission service not found, continue navigation
      print('Permission middleware error: $e');
      return null;
    }
  }

  void _showPermissionDialog(PermissionService permissionService) {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text('This feature requires location access.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              permissionService.requestLocationPermission();
            },
            child: const Text('Grant Permission'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  bool _requiresLocation(String? route) {
    if (route == null) return false;

    final locationRoutes = [
      Routes.DRIVER_HOME,
      Routes.ORDER_TRACKING,
      Routes.NAVIGATION,
    ];
    return locationRoutes.contains(route);
  }
}

// ✅ Connectivity Middleware - Check internet connection for route navigation
class ConnectivityMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      // Check if route can be accessed offline first
      if (_canAccessOffline(route)) {
        return null; // Route can be accessed offline, continue
      }

      // Check connectivity
      final connectivityService = Get.find<ConnectivityService>();
      bool isConnected = false;

      try {
        isConnected = connectivityService.isConnected;
      } catch (e) {
        print('Connectivity check error: $e');
        isConnected = false;
      }

      // If not connected and route requires connection, redirect to no internet page
      if (isConnected == false) {
        return const RouteSettings(name: Routes.NO_INTERNET);
      }

      return null;
    } catch (e) {
      // If connectivity service not found, continue navigation
      print('Connectivity middleware error: $e');
      return null;
    }
  }

  bool _canAccessOffline(String? route) {
    if (route == null) return false;

    final offlineRoutes = [
      Routes.NO_INTERNET,
      Routes.SPLASH,
      Routes.LOGIN,
      Routes.REGISTER,
      Routes.PROFILE, // Cached data
      Routes.SETTINGS,
      Routes.ABOUT,
      Routes.HELP,
      Routes.PRIVACY_POLICY,
      Routes.TERMS_OF_SERVICE,
    ];
    return offlineRoutes.contains(route);
  }
}
