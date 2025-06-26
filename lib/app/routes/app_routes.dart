// lib/app/routes/app_routes.dart (COMPLETE WITH HELPER & CONFIG)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Routes {
  Routes._();

  // ✅ Initial routes - Navigation flow: splash -> onboarding -> login -> main_navigation based on role
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const MAIN_NAVIGATION = '/main_navigation';

  // ✅ Auth routes
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot_password';
  static const RESET_PASSWORD = '/reset_password';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/edit_profile';

  // ✅ Customer routes
  static const CUSTOMER_HOME = '/customer/home';
  static const STORE_LIST = '/customer/store_list';
  static const STORE_DETAIL = '/customer/store_detail';
  static const MENU = '/customer/menu';
  static const MENU_ITEM_DETAIL = '/customer/menu_item_detail';
  static const CART = '/customer/cart';
  static const CHECKOUT = '/customer/checkout';
  static const ORDER_HISTORY = '/customer/order_history';
  static const CUSTOMER_ORDER_DETAIL = '/customer/order_detail';
  static const ORDER_TRACKING = '/customer/order_tracking';
  static const REVIEW = '/customer/review';
  static const CUSTOMER_PROFILE = '/customer/profile';

  // ✅ Driver routes
  static const DRIVER_HOME = '/driver/home';
  static const DRIVER_MAIN = '/driver/main';
  static const DRIVER_REQUESTS = '/driver/requests';
  static const DRIVER_MAP = '/driver/map';
  static const DRIVER_REQUEST_DETAIL = '/driver/request_detail';
  // static const DRIVER_ORDER_DETAIL = '/driver/order_detail';
  static const DRIVER_NAVIGATION = '/driver/navigation';
  static const DRIVER_TRACKING = '/driver/tracking';
  static const DELIVERY = '/driver/delivery';
  static const NAVIGATION = '/driver/navigation';
  static const DRIVER_ORDERS = '/driver/orders';
  static const DRIVER_EARNINGS = '/driver/earnings';
  static const DRIVER_PROFILE = '/driver/profile';
  static const DRIVER_SETTINGS = '/driver/settings';

  // ✅ Store routes
  static const STORE_DASHBOARD = '/store/dashboard';
  static const STORE_ANALYTICS = '/store/analytics';
  static const MENU_MANAGEMENT = '/store/menu_management';
  static const ADD_MENU_ITEM = '/store/add_menu_item';
  static const EDIT_MENU_ITEM = '/store/edit_menu_item';
  static const STORE_ORDERS = '/store/orders';
  static const STORE_ORDER_DETAIL = '/store/order_detail';
  static const STORE_PROFILE = '/store/profile';
  static const STORE_SETTINGS = '/store/settings';

  // ✅ Shared routes
  static const NO_INTERNET = '/no_internet';
  static const MAINTENANCE = '/maintenance';
  static const ERROR = '/error';

  // ✅ Settings routes
  static const SETTINGS = '/settings';
  static const LANGUAGE_SETTINGS = '/settings/language';
  static const THEME_SETTINGS = '/settings/theme';
  static const NOTIFICATION_SETTINGS = '/settings/notifications';
  static const PRIVACY_POLICY = '/privacy_policy';
  static const TERMS_OF_SERVICE = '/terms_of_service';
  static const ABOUT = '/about';
  static const HELP = '/help';
  static const CONTACT_US = '/contact_us';

  // ✅ Address routes
  static const ADDRESS_LIST = '/address/list';
  static const ADD_ADDRESS = '/address/add';
  static const EDIT_ADDRESS = '/address/edit';
  static const SELECT_ADDRESS = '/address/select';

  // ✅ Search routes
  static const SEARCH = '/search';
  static const SEARCH_RESULTS = '/search/results';

  // ✅ Filter routes
  static const FILTER = '/filter';

  // ✅ Map routes
  static const MAP_VIEW = '/map';
  static const LOCATION_PICKER = '/location_picker';

  // ✅ Notification routes
  static const NOTIFICATIONS = '/notifications';
  static const NOTIFICATION_DETAIL = '/notification_detail';

  // ✅ Chat routes (if implementing chat feature)
  static const CHAT_LIST = '/chat/list';
  static const CHAT_DETAIL = '/chat/detail';

  // ✅ Favorites routes
  static const FAVORITES = '/favorites';

  // ✅ Coupon routes (if implementing coupon system)
  static const COUPONS = '/coupons';
  static const COUPON_DETAIL = '/coupon_detail';
}

// ✅ Route Helper Class untuk parameter handling & navigation utilities
class RouteHelper {
  RouteHelper._();

  // ✅ Customer route helpers with parameters
  static String storeDetail({required String storeId}) =>
      '${Routes.STORE_DETAIL}?storeId=$storeId';

  static String menuItemDetail({required String menuId, String? storeId}) =>
      '${Routes.MENU_ITEM_DETAIL}?menuId=$menuId${storeId != null ? '&storeId=$storeId' : ''}';

  static String customerOrderDetail({required String orderId}) =>
      '${Routes.CUSTOMER_ORDER_DETAIL}?orderId=$orderId';

  static String orderTracking({required String orderId}) =>
      '${Routes.ORDER_TRACKING}?orderId=$orderId';

  static String review({required String orderId, String? type}) =>
      '${Routes.REVIEW}?orderId=$orderId${type != null ? '&type=$type' : ''}';

  // ✅ Driver route helpers with parameters
  String driverRequestDetail({required String requestId}) =>
      '${Routes.DRIVER_REQUEST_DETAIL}?requestId=$requestId';

  // String driverOrderDetail({required String orderId}) =>
  //     '${Routes.DRIVER_ORDER_DETAIL}?orderId=$orderId';

  void goToDriverRequestDetail(String requestId) =>
      Get.toNamed(driverRequestDetail(requestId: requestId));

  // void goToDriverOrderDetail(String orderId) =>
  //     Get.toNamed(driverOrderDetail(orderId: orderId));

  static String requestDetail({required String requestId}) =>
      '${Routes.DRIVER_REQUEST_DETAIL}?requestId=$requestId';

  static String delivery({required String orderId}) =>
      '${Routes.DELIVERY}?orderId=$orderId';

  static String navigation({required String orderId, String? destination}) =>
      '${Routes.NAVIGATION}?orderId=$orderId${destination != null ? '&destination=$destination' : ''}';

  // ✅ Store route helpers with parameters
  static String editMenuItem({required String menuId}) =>
      '${Routes.EDIT_MENU_ITEM}?menuId=$menuId';

  static String storeOrderDetail({required String orderId}) =>
      '${Routes.STORE_ORDER_DETAIL}?orderId=$orderId';

  // ✅ Address route helpers
  static String editAddress({required String addressId}) =>
      '${Routes.EDIT_ADDRESS}?addressId=$addressId';

  static String selectAddress({String? returnRoute}) =>
      '${Routes.SELECT_ADDRESS}${returnRoute != null ? '?returnRoute=$returnRoute' : ''}';

  // ✅ Search route helpers
  static String searchResults(
      {required String query, String? category, String? storeId}) {
    String route = '${Routes.SEARCH_RESULTS}?query=$query';
    if (category != null) route += '&category=$category';
    if (storeId != null) route += '&storeId=$storeId';
    return route;
  }

  // ✅ Map route helpers
  static String locationPicker(
      {String? returnRoute, double? lat, double? lng}) {
    String route = Routes.LOCATION_PICKER;
    List<String> params = [];
    if (returnRoute != null) params.add('returnRoute=$returnRoute');
    if (lat != null) params.add('lat=$lat');
    if (lng != null) params.add('lng=$lng');
    return params.isNotEmpty ? '$route?${params.join('&')}' : route;
  }

  // ✅ Notification route helpers
  static String notificationDetail({required String notificationId}) =>
      '${Routes.NOTIFICATION_DETAIL}?notificationId=$notificationId';

  // ✅ Chat route helpers
  static String chatDetail({required String chatId, String? userName}) =>
      '${Routes.CHAT_DETAIL}?chatId=$chatId${userName != null ? '&userName=$userName' : ''}';

  // ✅ Coupon route helpers
  static String couponDetail({required String couponId}) =>
      '${Routes.COUPON_DETAIL}?couponId=$couponId';

  // ✅ Auth route helpers
  static String resetPassword({required String token}) =>
      '${Routes.RESET_PASSWORD}?token=$token';

  // ✅ Utility methods for navigation
  static void goToStoreDetail(String storeId) =>
      Get.toNamed(storeDetail(storeId: storeId));

  static void goToOrderTracking(String orderId) =>
      Get.toNamed(orderTracking(orderId: orderId));

  static void goToCustomerOrderDetail(String orderId) =>
      Get.toNamed(customerOrderDetail(orderId: orderId));

  // ✅ Role-based navigation helpers
  static void navigateToRoleHome(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        Get.offAllNamed(Routes.CUSTOMER_HOME);
        break;
      case 'driver':
        Get.offAllNamed(Routes.DRIVER_MAIN);
        break;
      case 'store':
        Get.offAllNamed(Routes.STORE_DASHBOARD);
        break;
      default:
        Get.offAllNamed(Routes.LOGIN);
    }
  }

  // ✅ Back navigation with fallback
  static void goBack({String? fallbackRoute}) {
    if (Get.routing.previous.isNotEmpty) {
      Get.back();
    } else if (fallbackRoute != null) {
      Get.offAllNamed(fallbackRoute);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}

// ✅ Route Configuration class untuk better organization & validation
class RouteConfig {
  RouteConfig._();

  // ✅ Transition settings
  static const Duration transitionDuration = Duration(milliseconds: 300);
  static const Curve transitionCurve = Curves.easeInOut;
  static const Duration splashDuration = Duration(seconds: 3);

  // ✅ Route groups for role-based access control
  static const List<String> customerRoutes = [
    Routes.CUSTOMER_HOME,
    Routes.STORE_LIST,
    Routes.STORE_DETAIL,
    Routes.MENU,
    Routes.MENU_ITEM_DETAIL,
    Routes.CART,
    Routes.CHECKOUT,
    Routes.ORDER_HISTORY,
    Routes.CUSTOMER_ORDER_DETAIL,
    Routes.ORDER_TRACKING,
    Routes.REVIEW,
    Routes.CUSTOMER_PROFILE,
  ];

  static const List<String> driverRoutes = [
    Routes.DRIVER_HOME,
    Routes.DRIVER_MAIN,
    Routes.DRIVER_REQUESTS,
    Routes.DRIVER_MAP,
    Routes.DRIVER_REQUEST_DETAIL,
    Routes.DELIVERY,
    Routes.NAVIGATION,
    Routes.DRIVER_ORDERS,
    Routes.DRIVER_EARNINGS,
    Routes.DRIVER_PROFILE,
    Routes.DRIVER_SETTINGS,
  ];

  static const List<String> storeRoutes = [
    Routes.STORE_DASHBOARD,
    Routes.STORE_ANALYTICS,
    Routes.MENU_MANAGEMENT,
    Routes.ADD_MENU_ITEM,
    Routes.EDIT_MENU_ITEM,
    Routes.STORE_ORDERS,
    Routes.STORE_ORDER_DETAIL,
    Routes.STORE_PROFILE,
    Routes.STORE_SETTINGS,
  ];

  // ✅ Public routes (no authentication required)
  static const List<String> publicRoutes = [
    Routes.SPLASH,
    Routes.ONBOARDING,
    Routes.LOGIN,
    Routes.REGISTER,
    Routes.FORGOT_PASSWORD,
    Routes.RESET_PASSWORD,
    Routes.NO_INTERNET,
    Routes.ERROR,
    Routes.MAINTENANCE,
    Routes.PRIVACY_POLICY,
    Routes.TERMS_OF_SERVICE,
  ];

  // ✅ Shared routes (accessible by all authenticated users)
  static const List<String> sharedRoutes = [
    Routes.PROFILE,
    Routes.EDIT_PROFILE,
    Routes.SETTINGS,
    Routes.LANGUAGE_SETTINGS,
    Routes.THEME_SETTINGS,
    Routes.NOTIFICATION_SETTINGS,
    Routes.ABOUT,
    Routes.HELP,
    Routes.CONTACT_US,
    Routes.ADDRESS_LIST,
    Routes.ADD_ADDRESS,
    Routes.EDIT_ADDRESS,
    Routes.SELECT_ADDRESS,
    Routes.SEARCH,
    Routes.SEARCH_RESULTS,
    Routes.FILTER,
    Routes.MAP_VIEW,
    Routes.LOCATION_PICKER,
    Routes.NOTIFICATIONS,
    Routes.NOTIFICATION_DETAIL,
    Routes.CHAT_LIST,
    Routes.CHAT_DETAIL,
    Routes.FAVORITES,
    Routes.COUPONS,
    Routes.COUPON_DETAIL,
  ];

  // ✅ Routes that require authentication
  static List<String> get authRequiredRoutes => [
        ...customerRoutes,
        ...driverRoutes,
        ...storeRoutes,
        ...sharedRoutes,
      ];

  // ✅ Bottom navigation routes for each role
  static const Map<String, List<String>> roleBottomNavRoutes = {
    'customer': [
      Routes.CUSTOMER_HOME,
      Routes.STORE_LIST,
      Routes.ORDER_HISTORY,
      Routes.FAVORITES,
      Routes.CUSTOMER_PROFILE,
    ],
    'driver': [
      Routes.DRIVER_HOME,
      Routes.DRIVER_REQUESTS,
      Routes.DRIVER_ORDERS,
      Routes.DRIVER_EARNINGS,
      Routes.DRIVER_PROFILE,
    ],
    'store': [
      Routes.STORE_DASHBOARD,
      Routes.MENU_MANAGEMENT,
      Routes.STORE_ORDERS,
      Routes.STORE_ANALYTICS,
      Routes.STORE_PROFILE,
    ],
  };

  // ✅ Routes that should show bottom navigation
  static List<String> getBottomNavRoutes(String role) =>
      roleBottomNavRoutes[role.toLowerCase()] ?? [];

  // ✅ Default routes for each role
  static const Map<String, String> roleDefaultRoutes = {
    'customer': Routes.CUSTOMER_HOME,
    'driver': Routes.DRIVER_MAIN,
    'store': Routes.STORE_DASHBOARD,
  };

  // ✅ Routes that require location permission
  static const List<String> locationRequiredRoutes = [
    Routes.DRIVER_MAP,
    Routes.NAVIGATION,
    Routes.DELIVERY,
    Routes.MAP_VIEW,
    Routes.LOCATION_PICKER,
    Routes.ORDER_TRACKING,
  ];

  // ✅ Routes that require camera permission
  static const List<String> cameraRequiredRoutes = [
    Routes.EDIT_PROFILE,
    Routes.ADD_MENU_ITEM,
    Routes.EDIT_MENU_ITEM,
    Routes.STORE_PROFILE,
  ];

  // ✅ Routes that can be accessed offline
  static const List<String> offlineAccessibleRoutes = [
    Routes.PROFILE,
    Routes.SETTINGS,
    Routes.ABOUT,
    Routes.HELP,
    Routes.PRIVACY_POLICY,
    Routes.TERMS_OF_SERVICE,
    Routes.ORDER_HISTORY, // if cached
    Routes.FAVORITES, // if cached
  ];
}

// ✅ Extension untuk route validation & utilities
extension RouteValidation on String {
  // Check if route belongs to specific role
  bool get isCustomerRoute => RouteConfig.customerRoutes
      .any((route) => startsWith(route.split('?')[0]));
  bool get isDriverRoute =>
      RouteConfig.driverRoutes.any((route) => startsWith(route.split('?')[0]));
  bool get isStoreRoute =>
      RouteConfig.storeRoutes.any((route) => startsWith(route.split('?')[0]));
  bool get isSharedRoute =>
      RouteConfig.sharedRoutes.any((route) => startsWith(route.split('?')[0]));
  bool get isPublicRoute =>
      RouteConfig.publicRoutes.any((route) => startsWith(route.split('?')[0]));

  // Check permissions required
  bool get requiresAuth => RouteConfig.authRequiredRoutes
      .any((route) => startsWith(route.split('?')[0]));
  bool get requiresLocation => RouteConfig.locationRequiredRoutes
      .any((route) => startsWith(route.split('?')[0]));
  bool get requiresCamera => RouteConfig.cameraRequiredRoutes
      .any((route) => startsWith(route.split('?')[0]));
  bool get canAccessOffline => RouteConfig.offlineAccessibleRoutes
      .any((route) => startsWith(route.split('?')[0]));

  // Check if route should show bottom navigation
  bool shouldShowBottomNav(String userRole) =>
      RouteConfig.getBottomNavRoutes(userRole)
          .any((route) => startsWith(route.split('?')[0]));

  // Get role for route
  String? get routeRole {
    if (isCustomerRoute) return 'customer';
    if (isDriverRoute) return 'driver';
    if (isStoreRoute) return 'store';
    return null;
  }

  // Validate access for user role
  bool canAccessWithRole(String userRole) {
    if (isPublicRoute || isSharedRoute) return true;
    return routeRole == userRole.toLowerCase();
  }

  // Extract route without parameters
  String get routeWithoutParams => split('?')[0];

  // Extract parameters from route
  Map<String, String> get routeParams {
    if (!contains('?')) return {};

    final params = split('?')[1];
    final paramMap = <String, String>{};

    for (final param in params.split('&')) {
      final keyValue = param.split('=');
      if (keyValue.length == 2) {
        paramMap[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
      }
    }

    return paramMap;
  }
}

// ✅ Route Guard untuk security & validation
class RouteGuard {
  static bool canNavigate({
    required String route,
    required String userRole,
    required bool isAuthenticated,
    required bool hasLocationPermission,
    required bool hasCameraPermission,
    required bool isOnline,
  }) {
    // Check if route exists
    if (!_isValidRoute(route)) return false;

    // Check authentication
    if (route.requiresAuth && !isAuthenticated) return false;

    // Check role access
    if (!route.canAccessWithRole(userRole)) return false;

    // Check location permission
    if (route.requiresLocation && !hasLocationPermission) return false;

    // Check camera permission
    if (route.requiresCamera && !hasCameraPermission) return false;

    // Check offline access
    if (!isOnline && !route.canAccessOffline) return false;

    return true;
  }

  static bool _isValidRoute(String route) {
    final allRoutes = [
      ...RouteConfig.publicRoutes,
      ...RouteConfig.customerRoutes,
      ...RouteConfig.driverRoutes,
      ...RouteConfig.storeRoutes,
      ...RouteConfig.sharedRoutes,
    ];

    return allRoutes
        .any((validRoute) => route.routeWithoutParams == validRoute);
  }

  static String getRedirectRoute({
    required String attemptedRoute,
    required String userRole,
    required bool isAuthenticated,
  }) {
    if (!isAuthenticated) return Routes.LOGIN;

    if (!attemptedRoute.canAccessWithRole(userRole)) {
      return RouteConfig.roleDefaultRoutes[userRole.toLowerCase()] ??
          Routes.LOGIN;
    }

    return attemptedRoute;
  }
}
