// lib/features/auth/screens/auth_wrapper_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/features/shared/splash_view.dart';
import 'package:del_pick/features/auth/screens/login_screen.dart';
import 'package:del_pick/features/customer/screens/home_screen.dart';
import 'package:del_pick/features/driver/screens/driver_home_screen.dart';
import 'package:del_pick/features/store/screens/store_dashboard_screen.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class AuthWrapperView extends GetView<AuthController> {
  const AuthWrapperView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show splash while loading
      if (controller.isLoading.value) {
        return const SplashView();
      }

      // Show login if not authenticated
      if (!controller.isLoggedIn.value) {
        return const LoginScreen();
      }

      // Navigate based on user role
      switch (controller.userRole.value) {
        case AppConstants.roleCustomer:
          return const CustomerHomeScreen();
        case AppConstants.roleDriver:
          return const DriverHomeScreen();
        case AppConstants.roleStore:
          return StoreDashboardScreen();
        default:
          return const LoginScreen();
      }
    });
  }
}

// ✅ Extension untuk AuthController untuk kemudahan debugging
extension AuthControllerExtension on AuthController {
  void debugPrintAuthState() {
    print('=== AUTH STATE DEBUG ===');
    print('isLoggedIn: ${isLoggedIn.value}');
    print('isLoading: ${isLoading.value}');
    print('userRole: ${userRole.value}');
    print('currentUser: ${currentUser.value?.toJson()}');
    print(
        'token: ${token.value.isNotEmpty ? "${token.value.substring(0, 20)}..." : "empty"}');
    print('hasValidRole: $hasValidRole');
    print('========================');
  }
}
