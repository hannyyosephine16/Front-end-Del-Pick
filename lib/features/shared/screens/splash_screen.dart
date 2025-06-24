// // lib/features/shared/controllers/splash_controller.dart
// import 'package:get/get.dart';
// import 'package:del_pick/core/services/local/storage_service.dart';
// import 'package:del_pick/core/constants/storage_constants.dart';
// import 'package:del_pick/app/routes/app_routes.dart';
//
// class SplashController extends GetxController {
//   final StorageService _storageService = Get.find<StorageService>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeApp();
//   }
//
//   Future<void> _initializeApp() async {
//     try {
//       // Tunggu 2 detik untuk splash animation
//       await Future.delayed(const Duration(seconds: 2));
//
//       // Check authentication status
//       await _checkAuthenticationStatus();
//     } catch (e) {
//       print('Error initializing app: $e');
//       // Jika ada error, arahkan ke login
//       Get.offAllNamed(Routes.LOGIN);
//     }
//   }
//
//   Future<void> _checkAuthenticationStatus() async {
//     try {
//       // Cek apakah user sudah login
//       final isLoggedIn = _storageService.readBoolWithDefault(
//           StorageConstants.isLoggedIn, false);
//
//       final token = _storageService.readString(StorageConstants.authToken);
//
//       if (isLoggedIn && token != null && token.isNotEmpty) {
//         // User sudah login, arahkan berdasarkan role
//         _navigateBasedOnRole();
//       } else {
//         // User belum login, arahkan ke login
//         Get.offAllNamed(Routes.LOGIN);
//       }
//     } catch (e) {
//       print('Error checking auth status: $e');
//       Get.offAllNamed(Routes.LOGIN);
//     }
//   }
//
//   void _navigateBasedOnRole() {
//     final userRole = _storageService.readString(StorageConstants.userRole);
//
//     switch (userRole) {
//       case 'customer':
//         Get.offAllNamed(Routes.CUSTOMER_HOME);
//         break;
//       case 'driver':
//         Get.offAllNamed(Routes.DRIVER_MAIN);
//         break;
//       case 'store':
//         Get.offAllNamed(Routes.STORE_DASHBOARD);
//         break;
//       default:
//         Get.offAllNamed(Routes.LOGIN);
//     }
//   }
// }
// lib/features/shared/screens/splash_screen.dart
// lib/features/shared/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/shared/controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ PASTIKAN INI ADA
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delivery_dining,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'DelPick',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Food Delivery App',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
