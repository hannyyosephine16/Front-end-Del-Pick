// lib/core/config/middleware_setup.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/core/middleware/route_middleware.dart';
import 'package:del_pick/core/middleware/connectivity_middleware.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/services/external/connectivity_listener.dart';
import 'package:del_pick/app/routes/app_routes.dart';

/// Setup semua middleware untuk aplikasi DelPick
/// Focus: Customer, Driver, Store roles only
class MiddlewareSetup {
  /// Setup route middleware untuk GetX navigation
  static List<GetPage> setupRouteMiddleware(List<GetPage> pages) {
    return pages.map((page) {
      final middlewares = <GetMiddleware>[];

      // Add auth middleware for protected routes
      if (_requiresAuth(page.name)) {
        middlewares.add(AuthMiddleware());
      }

      // Add role middleware for role-specific routes
      if (_requiresRoleCheck(page.name)) {
        middlewares.add(RoleMiddleware());
      }

      // Add permission middleware for permission-required routes
      if (_requiresPermissions(page.name)) {
        middlewares.add(PermissionMiddleware());
      }

      // Add connectivity middleware for online-only routes
      if (_requiresConnection(page.name)) {
        middlewares.add(ConnectivityMiddleware());
      }

      return page.copyWith(middlewares: middlewares);
    }).toList();
  }

  /// Setup Dio interceptors untuk HTTP requests
  static Dio setupDioMiddleware(Dio dio) {
    // Add connectivity interceptor
    dio.interceptors
        .add(DioConnectivityMiddleware.getConnectivityInterceptor());

    // Add retry interceptor for failed connections
    dio.interceptors.add(DioConnectivityMiddleware.getRetryInterceptor(
      maxRetries: 3,
      retryDelay: const Duration(seconds: 2),
    ));

    // Add auth token interceptor
    dio.interceptors.add(_createAuthInterceptor());

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }

    // Set default timeouts
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);

    return dio;
  }

  /// Create auth interceptor for automatic token handling
  static Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add Bearer token from local storage
        try {
          final authService = Get.find<AuthService>();
          if (authService.isLoggedIn.value) {
            final token = authService.user.value?.token;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
        } catch (e) {
          print('Error adding auth token: $e');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - redirect to login
        if (error.response?.statusCode == 401) {
          try {
            final authService = Get.find<AuthService>();
            await authService.logout();
            Get.offAllNamed(Routes.LOGIN);
          } catch (e) {
            print('Error handling 401: $e');
          }
        }
        handler.next(error);
      },
    );
  }

  /// Check if route requires authentication
  static bool _requiresAuth(String route) {
    final protectedRoutes = [
      // Customer routes
      Routes.CUSTOMER_HOME,
      Routes.STORE_LIST,
      Routes.STORE_DETAIL,
      Routes.MENU,
      Routes.CART,
      Routes.CHECKOUT,
      Routes.ORDER_HISTORY,
      Routes.ORDER_TRACKING,
      Routes.ORDER_DETAIL,

      // Driver routes
      Routes.DRIVER_HOME,
      Routes.DRIVER_ORDERS,
      Routes.DRIVER_EARNINGS,
      Routes.DRIVER_MAP,
      Routes.DRIVER_PROFILE,

      // Store routes
      Routes.STORE_DASHBOARD,
      Routes.STORE_ORDERS,
      Routes.MENU_MANAGEMENT,
      Routes.ADD_MENU_ITEM,
      Routes.EDIT_MENU_ITEM,
      Routes.STORE_ANALYTICS,

      // Common protected routes
      Routes.PROFILE,
      Routes.EDIT_PROFILE,
      Routes.SETTINGS,
      Routes.NOTIFICATIONS,
    ];

    return protectedRoutes.any(
        (protectedRoute) => route.startsWith(protectedRoute.split('?')[0]));
  }

  /// Check if route requires role-based access control
  static bool _requiresRoleCheck(String route) {
    final roleSpecificRoutes = {
      '/customer/': ['customer'],
      '/driver/': ['driver'],
      '/store/': ['store'],
    };

    return roleSpecificRoutes.keys
        .any((roleRoute) => route.startsWith(roleRoute));
  }

  /// Check if route requires special permissions (location, camera, etc.)
  static bool _requiresPermissions(String route) {
    final permissionRoutes = [
      Routes.DRIVER_HOME,
      Routes.DRIVER_MAP,
      Routes.ORDER_TRACKING,
      Routes.LOCATION_PICKER,
      Routes.MAP_VIEW,
      Routes.CHECKOUT, // for location permission
    ];

    return permissionRoutes.contains(route);
  }

  /// Check if route requires internet connection
  static bool _requiresConnection(String route) {
    final onlineOnlyRoutes = [
      Routes.LOGIN,
      Routes.REGISTER,
      Routes.FORGOT_PASSWORD,
      Routes.RESET_PASSWORD,
      Routes.STORE_LIST,
      Routes.STORE_DETAIL,
      Routes.MENU,
      Routes.CHECKOUT,
      Routes.ORDER_TRACKING,
      Routes.MENU_MANAGEMENT,
      Routes.ADD_MENU_ITEM,
      Routes.EDIT_MENU_ITEM,
      Routes.DRIVER_ORDERS,
      Routes.STORE_ORDERS,
    ];

    return onlineOnlyRoutes.contains(route);
  }

  /// Get role-specific routes mapping
  static Map<String, List<String>> getRoleRoutesMapping() {
    return {
      'customer': [
        Routes.CUSTOMER_HOME,
        Routes.STORE_LIST,
        Routes.STORE_DETAIL,
        Routes.MENU,
        Routes.CART,
        Routes.CHECKOUT,
        Routes.ORDER_HISTORY,
        Routes.ORDER_TRACKING,
        Routes.ORDER_DETAIL,
      ],
      'driver': [
        Routes.DRIVER_HOME,
        Routes.DRIVER_ORDERS,
        Routes.DRIVER_EARNINGS,
        Routes.DRIVER_MAP,
        Routes.DRIVER_PROFILE,
      ],
      'store': [
        Routes.STORE_DASHBOARD,
        Routes.STORE_ORDERS,
        Routes.MENU_MANAGEMENT,
        Routes.ADD_MENU_ITEM,
        Routes.EDIT_MENU_ITEM,
        Routes.STORE_ANALYTICS,
      ],
    };
  }
}

/// Extension for GetPage copy with middlewares
extension GetPageExtension on GetPage {
  GetPage copyWith({
    String? name,
    GetPageBuilder? page,
    bool? popGesture,
    Map<String, String>? parameters,
    String? title,
    Transition? transition,
    Curve? curve,
    Alignment? alignment,
    bool? maintainState,
    bool? opaque,
    Bindings? binding,
    List<Bindings>? bindings,
    List<GetMiddleware>? middlewares,
    Duration? transitionDuration,
    bool? fullscreenDialog,
    List<GetPage>? children,
  }) {
    return GetPage(
      name: name ?? this.name,
      page: page ?? this.page,
      popGesture: popGesture ?? this.popGesture,
      parameters: parameters ?? this.parameters,
      title: title ?? this.title,
      transition: transition ?? this.transition,
      curve: curve ?? this.curve,
      alignment: alignment ?? this.alignment,
      maintainState: maintainState ?? this.maintainState,
      opaque: opaque ?? this.opaque,
      binding: binding ?? this.binding,
      bindings: bindings ?? this.bindings,
      middlewares: middlewares ?? this.middlewares,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      children: children ?? this.children,
    );
  }
}

/// Connection status listener untuk UI updates
class ConnectionStatusListener {
  static void startListening() {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      final connectivityListener = Get.put(ConnectivityListener());

      // Listen to connection changes using RxBool stream
      connectivityService.isConnected.listen((bool isConnected) {
        print('Connection status changed: $isConnected');

        if (isConnected) {
          _handleOnlineStatus();
        } else {
          _handleOfflineStatus();
        }
      });
    } catch (e) {
      print('Error starting connection listener: $e');
    }
  }

  static void _handleOnlineStatus() {
    // Trigger any online-specific operations
    print('Device is online');
  }

  static void _handleOfflineStatus() {
    // Handle offline state
    print('Device is offline');
  }
}

/// Helper class untuk setup middleware di main app
class AppMiddlewareConfig {
  /// Initialize semua middleware di app startup
  static void initialize() {
    // Start connection status listener
    ConnectionStatusListener.startListening();
  }

  /// Get configured Dio instance dengan semua interceptors
  static Dio createConfiguredDio() {
    final dio = Dio();
    return MiddlewareSetup.setupDioMiddleware(dio);
  }

  /// Setup GetX routes dengan middleware
  static List<GetPage> getRoutesWithMiddleware(List<GetPage> appRoutes) {
    return MiddlewareSetup.setupRouteMiddleware(appRoutes);
  }

  /// Check if current user can access specific route
  static bool canAccessRoute(String route, String userRole) {
    final roleRoutes = MiddlewareSetup.getRoleRoutesMapping();
    final allowedRoutes = roleRoutes[userRole] ?? [];

    // Check if route is role-specific or public
    return allowedRoutes.contains(route) || _isPublicRoute(route);
  }

  /// Check if route is public (accessible by all roles)
  static bool _isPublicRoute(String route) {
    final publicRoutes = [
      Routes.SPLASH,
      Routes.ONBOARDING,
      Routes.LOGIN,
      Routes.REGISTER,
      Routes.FORGOT_PASSWORD,
      Routes.RESET_PASSWORD,
      Routes.PROFILE,
      Routes.EDIT_PROFILE,
      Routes.SETTINGS,
      Routes.NOTIFICATIONS,
    ];

    return publicRoutes.contains(route);
  }
}

/// Usage example in main.dart:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize dependencies first
///   await initDependencies();
///
///   // Initialize middleware
///   AppMiddlewareConfig.initialize();
///
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return GetMaterialApp(
///       title: 'DelPick',
///       initialRoute: Routes.SPLASH,
///       getPages: AppMiddlewareConfig.getRoutesWithMiddleware(AppPages.routes),
///       defaultTransition: Transition.fadeIn,
///       transitionDuration: const Duration(milliseconds: 300),
///     );
///   }
/// }
/// ```
