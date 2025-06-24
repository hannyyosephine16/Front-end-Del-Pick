// lib/features/shared/controllers/splash_controller.dart
import 'package:get/get.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

// lib/features/shared/controllers/splash_controller.dart
// lib/features/shared/controllers/splash_controller.dart
import 'package:get/get.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class SplashController extends GetxController {
  StorageService? _storageService;

  @override
  void onInit() {
    super.onInit();
    print('🟡 SplashController onInit() called');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🟡 Initializing app...');

      // ✅ Cek apakah StorageService tersedia
      try {
        _storageService = Get.find<StorageService>();
        print('🟢 StorageService found');
      } catch (e) {
        print('🔴 StorageService not found: $e');
        // Fallback: langsung ke login
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      print('🟡 Waiting 2 seconds...');
      await Future.delayed(const Duration(seconds: 2));

      print('🟡 Checking authentication status...');
      await _checkAuthenticationStatus();
    } catch (e) {
      print('🔴 Error in _initializeApp: $e');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      if (_storageService == null) {
        print('🔴 StorageService is null, going to login');
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      final isLoggedIn = _storageService!
          .readBoolWithDefault(StorageConstants.isLoggedIn, false);
      final token = _storageService!.readString(StorageConstants.authToken);

      print('🟡 isLoggedIn: $isLoggedIn');
      print('🟡 token exists: ${token != null && token.isNotEmpty}');

      if (isLoggedIn && token != null && token.isNotEmpty) {
        print('🟢 User is authenticated, navigating by role...');
        _navigateBasedOnRole();
      } else {
        print('🟢 User not authenticated, going to login...');
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print('🔴 Error in _checkAuthenticationStatus: $e');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _navigateBasedOnRole() {
    try {
      final userRole = _storageService!.readString(StorageConstants.userRole);
      print('🟡 User role: $userRole');

      switch (userRole) {
        case 'customer':
          print('🟢 Navigating to customer home');
          Get.offAllNamed(Routes.CUSTOMER_HOME);
          break;
        case 'driver':
          print('🟢 Navigating to driver main');
          Get.offAllNamed(Routes.DRIVER_MAIN);
          break;
        case 'store':
          print('🟢 Navigating to store dashboard');
          Get.offAllNamed(Routes.STORE_DASHBOARD);
          break;
        default:
          print('🟢 Unknown/null role ($userRole), going to login');
          Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print('🔴 Error in _navigateBasedOnRole: $e');
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
// class SplashController extends GetxController {
//   final StorageService _storageService = Get.find<StorageService>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     print('🟡 SplashController initialized');
//     _initializeApp();
//   }
//
//   Future<void> _initializeApp() async {
//     try {
//       print('🟡 Waiting 2 seconds...');
//       await Future.delayed(const Duration(seconds: 2));
//
//       print('🟡 Checking authentication status...');
//       await _checkAuthenticationStatus();
//     } catch (e) {
//       print('🔴 Error in _initializeApp: $e');
//       Get.offAllNamed(Routes.LOGIN);
//     }
//   }
//
//   Future<void> _checkAuthenticationStatus() async {
//     try {
//       final isLoggedIn = _storageService.readBoolWithDefault(
//           StorageConstants.isLoggedIn, false);
//       final token = _storageService.readString(StorageConstants.authToken);
//
//       print('🟡 isLoggedIn: $isLoggedIn');
//       print('🟡 token exists: ${token != null && token.isNotEmpty}');
//
//       if (isLoggedIn && token != null && token.isNotEmpty) {
//         print('🟢 User is authenticated, navigating by role...');
//         _navigateBasedOnRole();
//       } else {
//         print('🟢 User not authenticated, going to login...');
//         Get.offAllNamed(Routes.LOGIN);
//       }
//     } catch (e) {
//       print('🔴 Error in _checkAuthenticationStatus: $e');
//       Get.offAllNamed(Routes.LOGIN);
//     }
//   }
//
//   void _navigateBasedOnRole() {
//     final userRole = _storageService.readString(StorageConstants.userRole);
//     print('🟡 User role: $userRole');
//
//     switch (userRole) {
//       case 'customer':
//         print('🟢 Navigating to customer home');
//         Get.offAllNamed(Routes.CUSTOMER_HOME);
//         break;
//       case 'driver':
//         print('🟢 Navigating to driver main');
//         Get.offAllNamed(Routes.DRIVER_MAIN);
//         break;
//       case 'store':
//         print('🟢 Navigating to store dashboard');
//         Get.offAllNamed(Routes.STORE_DASHBOARD);
//         break;
//       default:
//         print('🟢 Unknown/null role, going to login');
//         Get.offAllNamed(Routes.LOGIN);
//     }
//   }
// }
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
