// import 'package:get/get.dart';
// import 'package:del_pick/features/shared/screens/splash_screen.dart';
// import 'package:del_pick/features/shared/screens/onboarding_screen.dart';
// import 'package:del_pick/features/shared/screens/main_navigation_screen.dart';
// import 'package:del_pick/features/shared/screens/no_internet_screen.dart';
// import 'package:del_pick/features/shared/screens/maintenance_screen.dart';
// import 'package:del_pick/features/shared/screens/error_screen.dart';
// import 'package:del_pick/features/shared/controllers/splash_controller.dart';
//
// // Auth imports
// import 'package:del_pick/features/auth/screens/login_screen.dart';
// import 'package:del_pick/features/auth/screens/register_screen.dart';
// import 'package:del_pick/features/auth/screens/forgot_password_screen.dart';
// import 'package:del_pick/features/auth/screens/reset_password_screen.dart';
// import 'package:del_pick/features/auth/screens/profile_screen.dart';
// import 'package:del_pick/features/auth/screens/edit_profile_screen.dart';
//
// // Customer imports
// import 'package:del_pick/features/customer/screens/home_screen.dart';
// import 'package:del_pick/features/customer/screens/store_list_screen.dart';
// import 'package:del_pick/features/customer/screens/store_detail_screen.dart';
// import 'package:del_pick/features/customer/screens/menu_screen.dart';
// import 'package:del_pick/features/customer/screens/menu_item_detail_screen.dart';
// import 'package:del_pick/features/customer/screens/cart_screen.dart';
// import 'package:del_pick/features/customer/screens/checkout_screen.dart';
// import 'package:del_pick/features/customer/screens/order_history_screen.dart';
// import 'package:del_pick/features/customer/screens/order_detail_screen.dart';
// import 'package:del_pick/features/customer/screens/order_tracking_screen.dart';
// import 'package:del_pick/features/customer/screens/review_screen.dart';
// import 'package:del_pick/features/customer/screens/customer_profile_screen.dart';
//
// // Driver imports
// import 'package:del_pick/features/driver/screens/driver_home_screen.dart';
// import 'package:del_pick/features/driver/screens/driver_requests_screen.dart';
// import 'package:del_pick/features/driver/screens/request_detail_screen.dart';
// import 'package:del_pick/features/driver/screens/delivery_screen.dart';
// import 'package:del_pick/features/driver/screens/navigation_screen.dart';
// import 'package:del_pick/features/driver/screens/driver_orders_screen.dart';
// import 'package:del_pick/features/driver/screens/driver_earnings_screen.dart';
// import 'package:del_pick/features/driver/screens/driver_profile_screen.dart';
// import 'package:del_pick/features/driver/screens/driver_settings_screen.dart';
//
// // Store imports
// import 'package:del_pick/features/store/screens/store_dashboard_screen.dart';
// import 'package:del_pick/features/store/screens/store_analytics_screen.dart';
// import 'package:del_pick/features/store/screens/menu_management_screen.dart';
// import 'package:del_pick/features/store/screens/add_menu_item_screen.dart';
// import 'package:del_pick/features/store/screens/edit_menu_item_screen.dart';
// import 'package:del_pick/features/store/screens/store_orders_screen.dart';
// import 'package:del_pick/features/store/screens/order_detail_screen.dart';
// import 'package:del_pick/features/store/screens/store_profile_screen.dart';
// import 'package:del_pick/features/store/screens/store_settings_screen.dart';
//
// import '../../core/middleware/role_middleware.dart';
// import '../../features/driver/screens/driver_main_screen.dart';
// import 'app_routes.dart';
// import '../bindings/auth_binding.dart';
// import '../bindings/customer_binding.dart';
// import '../bindings/driver_binding.dart';
// import '../bindings/store_binding.dart';
//
// class AppPages {
//   AppPages._();
//
//   static const INITIAL = Routes.SPLASH;
//
//   static final routes = [
//     // // Shared routes
//     // // GetPage(name: Routes.SPLASH, page: () => const SplashScreen()),
//     // // Splash Screen
//     // GetPage(
//     //   name: Routes.SPLASH,
//     //   page: () => const SplashScreen(),
//     //   binding: BindingsBuilder(() {
//     //     Get.lazyPut<SplashController>(() => SplashController());
//     //   }),
//     // ),
//     // GetPage(name: Routes.ONBOARDING, page: () => const OnboardingScreen()),
//     // GetPage(
//     //   name: Routes.MAIN_NAVIGATION,
//     //   page: () => const MainNavigationScreen(),
//     // ),
//     // GetPage(name: Routes.NO_INTERNET, page: () => const NoInternetScreen()),
//     // GetPage(name: Routes.MAINTENANCE, page: () => const MaintenanceScreen()),
//     // GetPage(name: Routes.ERROR, page: () => const ErrorScreen()),
//     //
//     // // Auth routes
//     // GetPage(
//     //   name: Routes.LOGIN,
//     //   page: () => const LoginScreen(),
//     //   binding: AuthBinding(),
//     // ),
//     // GetPage(
//     //   name: Routes.FORGOT_PASSWORD,
//     //   page: () => const ForgotPasswordScreen(),
//     //   binding: AuthBinding(),
//     //   // middlewares: [AuthMiddleware()],
//     // ),
//     // GetPage(
//     //   name: Routes.RESET_PASSWORD,
//     //   page: () => const ResetPasswordScreen(),
//     //   binding: AuthBinding(),
//     //   middlewares: [AuthMiddleware()],
//     // ),
//     // GetPage(
//     //   name: Routes.PROFILE,
//     //   page: () => const ProfileScreen(),
//     //   binding: AuthBinding(),
//     //   middlewares: [AuthMiddleware()],
//     // ),
//     // GetPage(
//     //   name: Routes.EDIT_PROFILE,
//     //   page: () => const EditProfileScreen(),
//     //   binding: AuthBinding(),
//     //   middlewares: [AuthMiddleware()],
//     // ),
//     // ✅ SPLASH - Tanpa middleware
//     GetPage(
//       name: Routes.SPLASH,
//       page: () => const SplashScreen(),
//     ),
//
//     // ✅ AUTH ROUTES - Gunakan GuestMiddleware (redirect ke home jika sudah login)
//     GetPage(
//       name: Routes.LOGIN,
//       page: () => const LoginScreen(),
//       binding: AuthBinding(),
//       middlewares: [GuestMiddleware()], // ✅ Redirect ke home jika sudah login
//     ),
//     GetPage(
//       name: Routes.REGISTER,
//       page: () => const RegisterScreen(),
//       binding: AuthBinding(),
//       middlewares: [GuestMiddleware()],
//     ),
//     GetPage(
//       name: Routes.FORGOT_PASSWORD,
//       page: () => const ForgotPasswordScreen(),
//       binding: AuthBinding(),
//       middlewares: [GuestMiddleware()],
//     ),
//
//     // ✅ PROTECTED ROUTES - Gunakan AuthMiddleware + RoleMiddleware
//     GetPage(
//       name: Routes.RESET_PASSWORD,
//       page: () => const ResetPasswordScreen(),
//       binding: AuthBinding(),
//       middlewares: [AuthMiddleware()],
//     ),
//     GetPage(
//       name: Routes.PROFILE,
//       page: () => const ProfileScreen(),
//       binding: AuthBinding(),
//       middlewares: [AuthMiddleware()], // ✅ Semua role bisa akses
//     ),
//
//     // ✅ CUSTOMER ROUTES
//     GetPage(
//       name: Routes.CUSTOMER_HOME,
//       page: () => const CustomerHomeScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()], // ✅ Hanya customer
//     ),
//
//     // ✅ DRIVER ROUTES
//     GetPage(
//       name: Routes.DRIVER_MAIN,
//       page: () => const DriverMainScreen(),
//       binding: DriverBinding(),
//       middlewares: [DriverOnlyMiddleware()], // ✅ Hanya driver
//     ),
//
//     // ✅ STORE ROUTES
//     GetPage(
//       name: Routes.STORE_DASHBOARD,
//       page: () => const StoreDashboardScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()], // ✅ Hanya store
//     ),
//
//     // Customer routes
//     // GetPage(
//     //   name: Routes.CUSTOMER_HOME,
//     //   page: () => const CustomerHomeScreen(),
//     //   binding: CustomerBinding(),
//     //   middlewares: [CustomerOnlyMiddleware()],
//     // ),
//     GetPage(
//       name: Routes.STORE_LIST,
//       page: () => StoreListScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.STORE_DETAIL,
//       page: () => const StoreDetailScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.MENU,
//       page: () => const MenuScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.MENU_ITEM_DETAIL,
//       page: () => const MenuItemDetailScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.CART,
//       page: () => const CartScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.CHECKOUT,
//       page: () => const CheckoutScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.ORDER_HISTORY,
//       page: () => const OrderHistoryScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.CUSTOMER_ORDER_DETAIL,
//       page: () => const CustomerOrderDetailScreen(),
//       binding: CustomerBinding(),
//     ),
//     GetPage(
//       name: Routes.ORDER_TRACKING,
//       page: () => const OrderTrackingScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.REVIEW,
//       page: () => const ReviewScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.CUSTOMER_PROFILE,
//       page: () => const CustomerProfileScreen(),
//       binding: CustomerBinding(),
//       middlewares: [CustomerOnlyMiddleware()],
//     ),
//
//     // Store routes
//     // GetPage(
//     //   name: Routes.STORE_DASHBOARD,
//     //   page: () => const StoreDashboardScreen(),
//     //   binding: StoreBinding(),
//     //   middlewares: [StoreOnlyMiddleware()],
//     // ),
//     GetPage(
//       name: Routes.STORE_ANALYTICS,
//       page: () => const StoreAnalyticsScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.MENU_MANAGEMENT,
//       page: () => const MenuManagementScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.ADD_MENU_ITEM,
//       page: () => const AddMenuItemScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.EDIT_MENU_ITEM,
//       page: () => const EditMenuItemScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.STORE_ORDERS,
//       page: () => const StoreOrdersScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.STORE_ORDER_DETAIL,
//       page: () => const StoreOrderDetailScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.STORE_PROFILE,
//       page: () => const StoreProfileScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.STORE_SETTINGS,
//       page: () => const StoreSettingsScreen(),
//       binding: StoreBinding(),
//       middlewares: [StoreOnlyMiddleware()],
//     ),
//
//     // Driver routes
//     GetPage(
//       name: Routes.DRIVER_MAIN,
//       page: () => const DriverMainScreen(),
//       binding: DriverBinding(),
//     ),
//
//     // GetPage(
//     //   name: Routes.DRIVER_HOME,
//     //   page: () => const DriverHomeScreen(),
//     //   binding: DriverBinding(),
//     // ),
//     // GetPage(
//     //   name: Routes.DRIVER_REQUESTS,
//     //   page: () => const DriverRequestsScreen(),
//     //   binding: DriverBinding(),
//     // ),
//     // GetPage(
//     //   name: Routes.REQUEST_DETAIL,
//     //   page: () => const RequestDetailScreen(),
//     //   binding: DriverBinding(),
//     // ),
//     // GetPage(
//     //   name: Routes.DELIVERY,
//     //   page: () => const DeliveryScreen(),
//     //   binding: DriverBinding(),
//     // ),
//     GetPage(
//       name: Routes.NAVIGATION,
//       page: () => const NavigationScreen(),
//       binding: DriverBinding(),
//       middlewares: [DriverOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.DRIVER_ORDERS,
//       page: () => const DriverOrdersScreen(),
//       binding: DriverBinding(),
//       middlewares: [DriverOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.DRIVER_EARNINGS,
//       page: () => const DriverEarningsScreen(),
//       binding: DriverBinding(),
//       middlewares: [DriverOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.DRIVER_PROFILE,
//       page: () => const DriverProfileScreen(),
//       binding: DriverBinding(),
//       middlewares: [DriverOnlyMiddleware()],
//     ),
//     GetPage(
//       name: Routes.DRIVER_SETTINGS,
//       page: () => const DriverSettingsScreen(),
//       binding: DriverBinding(),
//       middlewares: [DriverOnlyMiddleware()],
//     ),
//   ];
// }
// lib/app/routes/app_pages.dart (COMPLETE CONFIGURATION)
import 'package:del_pick/features/auth/screens/profile_screen.dart';
import 'package:del_pick/features/customer/screens/home_screen.dart';
import 'package:del_pick/features/customer/screens/order_history_screen.dart';
import 'package:del_pick/features/driver/screens/driver_home_screen.dart';
import 'package:del_pick/features/store/screens/order_detail_screen.dart';
import 'package:del_pick/features/store/screens/store_dashboard_screen.dart';
import 'package:del_pick/features/store/screens/store_orders_screen.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/middleware/route_middleware.dart';

// ✅ Import all screens
// Shared screens
import 'package:del_pick/features/shared/screens/splash_screen.dart';
import 'package:del_pick/features/shared/screens/onboarding_screen.dart';
import 'package:del_pick/features/shared/screens/no_internet_screen.dart';
import 'package:del_pick/features/shared/screens/error_screen.dart';
import 'package:del_pick/features/shared/screens/maintenance_screen.dart';

// Auth screens
import 'package:del_pick/features/auth/screens/login_screen.dart';
import 'package:del_pick/features/auth/screens/register_screen.dart';
import 'package:del_pick/features/auth/screens/forgot_password_screen.dart';
import 'package:del_pick/features/auth/screens/reset_password_screen.dart';
import 'package:del_pick/features/auth/screens/edit_profile_screen.dart';

// Customer screens
// import 'package:del_pick/features/customer/views/customer_home_view.dart';
// import 'package:del_pick/features/customer/views/store_list_view.dart';
// import 'package:del_pick/features/customer/views/store_detail_view.dart';
// import 'package:del_pick/features/customer/views/menu_detail_view.dart';
// import 'package:del_pick/features/customer/views/customer_order_detail_view.dart';
// import 'package:del_pick/features/customer/views/customer_order_history_view.dart';
// import 'package:del_pick/features/customer/views/order_tracking_view.dart';
// import 'package:del_pick/features/customer/views/review_order_view.dart';
// import 'package:del_pick/features/customer/views/customer_profile_view.dart';

// Driver screens
// import 'package:del_pick/features/driver/views/driver_home_view.dart';
// import 'package:del_pick/features/driver/views/driver_request_view.dart';
// import 'package:del_pick/features/driver/views/driver_order_detail_view.dart';
// import 'package:del_pick/features/driver/views/driver_order_history_view.dart';
// import 'package:del_pick/features/driver/views/navigation_view.dart';
// import 'package:del_pick/features/driver/views/driver_profile_view.dart';

// Store screens
// import 'package:del_pick/features/store/views/store_home_view.dart';
// import 'package:del_pick/features/store/views/menu_management_view.dart';
// import 'package:del_pick/features/store/views/add_menu_item_view.dart';
// import 'package:del_pick/features/store/views/edit_menu_item_view.dart';
// import 'package:del_pick/features/store/views/store_order_detail_view.dart';
// import 'package:del_pick/features/store/views/store_order_history_view.dart';
// import 'package:del_pick/features/store/views/store_analytics_view.dart';
// import 'package:del_pick/features/store/views/store_profile_view.dart';

// ✅ Import bindings
import 'package:del_pick/app/bindings/initial_binding.dart';
import 'package:del_pick/app/bindings/auth_binding.dart';
import 'package:del_pick/app/bindings/customer_binding.dart';
import 'package:del_pick/app/bindings/driver_binding.dart';
import 'package:del_pick/app/bindings/store_binding.dart';

class AppPages {
  AppPages._();

  // ✅ FIXED: Splash as initial route
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // ✅ === INITIAL ROUTES ===
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // ✅ === AUTH ROUTES ===
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileScreen(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware(), PermissionMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // ✅ === CUSTOMER ROUTES ===
    GetPage(
      name: Routes.CUSTOMER_HOME,
      page: () => const CustomerHomeScreen(),
      binding: CustomerBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    GetPage(
      name: Routes.STORE_LIST,
      page: () => const StoreOrdersScreen(),
      binding: CustomerBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(),
        ConnectivityMiddleware()
      ],
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    GetPage(
      name: Routes.STORE_DETAIL,
      page: () => const StoreOrderDetailScreen(),
      binding: CustomerBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(),
        ConnectivityMiddleware()
      ],
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // GetPage(
    //   name: Routes.MENU_ITEM_DETAIL,
    //   page: () => const MenuDetailView(),
    //   binding: CustomerBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    // GetPage(
    //   name: Routes.CUSTOMER_ORDER_DETAIL,
    //   page: () => const CustomerOrderDetailView(),
    //   binding: CustomerBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    // GetPage(
    //   name: Routes.ORDER_HISTORY,
    //   page: () => const CustomerOrderHistoryView(),
    //   binding: CustomerBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    // GetPage(
    //   name: Routes.ORDER_TRACKING,
    //   page: () => const OrderTrackingView(),
    //   binding: CustomerBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware(), PermissionMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    // GetPage(
    //   name: Routes.REVIEW,
    //   page: () => const ReviewOrderView(),
    //   binding: CustomerBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    GetPage(
      name: Routes.CUSTOMER_PROFILE,
      page: () => const ProfileScreen(),
      binding: CustomerBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // ✅ === DRIVER ROUTES ===
    // GetPage(
    //   name: Routes.DRIVER_MAIN,
    //   page: () => const DriverHomeView(),
    //   binding: DriverBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.fadeIn,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    GetPage(
      name: Routes.DRIVER_HOME,
      page: () => const DriverHomeScreen(),
      binding: DriverBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // GetPage(
    //   name: Routes.DRIVER_REQUESTS,
    //   page: () => const DriverRequestView(),
    //   binding: DriverBinding(),
    //   middlewares: [
    //     AuthMiddleware(),
    //     RoleMiddleware(),
    //     ConnectivityMiddleware()
    //   ],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    // GetPage(
    //   name: Routes.REQUEST_DETAIL,
    //   page: () => const DriverOrderDetailView(),
    //   binding: DriverBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    GetPage(
      name: Routes.DRIVER_ORDERS,
      page: () => const OrderHistoryScreen(),
      binding: DriverBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // GetPage(
    //   name: Routes.NAVIGATION,
    //   page: () => const NavigationView(),
    //   binding: DriverBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware(), PermissionMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    GetPage(
      name: Routes.DRIVER_PROFILE,
      page: () => const ProfileScreen(),
      binding: DriverBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // ✅ === STORE ROUTES ===
    GetPage(
      name: Routes.STORE_DASHBOARD,
      page: () => const StoreDashboardScreen(),
      binding: StoreBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // GetPage(
    //   name: Routes.MENU_MANAGEMENT,
    //   page: () => const MenuManagementView(),
    //   binding: StoreBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),
    //
    // GetPage(
    //   name: Routes.ADD_MENU_ITEM,
    //   page: () => const AddMenuItemView(),
    //   binding: StoreBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware(), PermissionMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),
    //
    // GetPage(
    //   name: Routes.EDIT_MENU_ITEM,
    //   page: () => const EditMenuItemView(),
    //   binding: StoreBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware(), PermissionMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),
    //
    // GetPage(
    //   name: Routes.STORE_ORDERS,
    //   page: () => const StoreOrderHistoryView(),
    //   binding: StoreBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    // GetPage(
    //   name: Routes.STORE_ORDER_DETAIL,
    //   page: () => const StoreOrderDetailView(),
    //   binding: StoreBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    // GetPage(
    //   name: Routes.STORE_ANALYTICS,
    //   page: () => const StoreAnalyticsView(),
    //   binding: StoreBinding(),
    //   middlewares: [
    //     AuthMiddleware(),
    //     RoleMiddleware(),
    //     ConnectivityMiddleware()
    //   ],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),
    //
    // GetPage(
    //   name: Routes.STORE_PROFILE,
    //   page: () => const StoreProfileView(),
    //   binding: StoreBinding(),
    //   middlewares: [AuthMiddleware(), RoleMiddleware()],
    //   transition: Transition.rightToLeft,
    //   transitionDuration: RouteConfig.transitionDuration,
    // ),

    // ✅ === ERROR & UTILITY ROUTES ===
    GetPage(
      name: Routes.NO_INTERNET,
      page: () => const NoInternetScreen(),
      transition: Transition.fadeIn,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    GetPage(
      name: Routes.ERROR,
      page: () => const ErrorScreen(),
      transition: Transition.fadeIn,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    GetPage(
      name: Routes.MAINTENANCE,
      page: () => const MaintenanceScreen(),
      transition: Transition.fadeIn,
      transitionDuration: RouteConfig.transitionDuration,
    ),

    // ✅ === CATCH-ALL ROUTE (404) ===
    GetPage(
      name: '/404',
      page: () => const ErrorScreen(),
      transition: Transition.fadeIn,
    ),
  ];

  // ✅ Get page by name (untuk debugging)
  static GetPage? getPageByName(String name) {
    try {
      return routes.firstWhere((page) => page.name == name);
    } catch (e) {
      return null;
    }
  }

  // ✅ Check if route exists
  static bool routeExists(String route) {
    return routes.any((page) => page.name == route);
  }

  // ✅ Get all route names
  static List<String> get allRouteNames {
    return routes.map((page) => page.name).toList();
  }

  // ✅ Get routes by role
  static List<String> getRoutesByRole(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return RouteConfig.customerRoutes;
      case 'driver':
        return RouteConfig.driverRoutes;
      case 'store':
        return RouteConfig.storeRoutes;
      default:
        return RouteConfig.publicRoutes;
    }
  }
}
