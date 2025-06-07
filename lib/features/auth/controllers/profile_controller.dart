// import 'package:get/get.dart';
// import 'package:del_pick/data/models/auth/user_model.dart';
// import 'package:del_pick/data/repositories/auth_repository.dart';
// import 'package:del_pick/core/services/local/storage_service.dart';
// import 'package:del_pick/core/constants/storage_constants.dart';
//
// class ProfileController extends GetxController {
//   final AuthRepository _authRepository;
//   final StorageService _storageService = Get.find<StorageService>();
//
//   ProfileController({required AuthRepository authRepository})
//       : _authRepository = authRepository;
//
//   // Observable state
//   final RxBool _isLoading = false.obs;
//   final Rx<UserModel?> _user = Rx<UserModel?>(null);
//   final RxString _errorMessage = ''.obs;
//   final RxBool _hasError = false.obs;
//
//   // Getters
//   bool get isLoading => _isLoading.value;
//   UserModel? get user => _user.value;
//   String get errorMessage => _errorMessage.value;
//   bool get hasError => _hasError.value;
//
//   // User info getters
//   String get userName => user?.name ?? 'Unknown User';
//   String get userEmail => user?.email ?? '';
//   String get userPhone => user?.phone ?? '';
//   String get userRole => user?.role ?? 'customer';
//   int get userId => user?.id ?? 0;
//   String? get userAvatar => user?.avatar;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadUserProfile();
//   }
//
//   Future<void> loadUserProfile() async {
//     _isLoading.value = true;
//     _hasError.value = false;
//     _errorMessage.value = '';
//
//     try {
//       // Try to get from local storage first
//       final localUser = await _getLocalUser();
//       if (localUser != null) {
//         _user.value = localUser;
//       }
//
//       // Then try to get from API
//       final result = await _authRepository.getProfile();
//       if (result.isSuccess && result.data != null) {
//         _user.value = result.data!;
//         await _saveLocalUser(result.data!);
//       } else if (localUser == null) {
//         // Only show error if no local data
//         _hasError.value = true;
//         _errorMessage.value = result.message ?? 'Failed to load profile';
//       }
//     } catch (e) {
//       if (_user.value == null) {
//         _hasError.value = true;
//         _errorMessage.value = 'Error loading profile: $e';
//       }
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<UserModel?> _getLocalUser() async {
//     try {
//       final userData = _storageService.readJson('user_profile');
//       if (userData != null) {
//         return UserModel.fromJson(userData);
//       }
//     } catch (e) {
//       print('Error loading local user: $e');
//     }
//     return null;
//   }
//
//   Future<void> _saveLocalUser(UserModel user) async {
//     try {
//       await _storageService.writeJson('user_profile', user.toJson());
//     } catch (e) {
//       print('Error saving local user: $e');
//     }
//   }
//
//   Future<void> refreshProfile() async {
//     await loadUserProfile();
//   }
//
//   Future<void> logout() async {
//     try {
//       _isLoading.value = true;
//       await _authRepository.logout();
//       await _storageService.remove('user_profile');
//       Get.offAllNamed('/login');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to logout: $e');
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   // Test image loading method
//   void testImageLoading() {
//     Get.snackbar(
//       'Test',
//       'Image loading test triggered',
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }
// }
// lib/features/auth/controllers/profile_controller.dart - FIXED VERSION

import 'package:get/get.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository;
  final StorageService _storageService = Get.find<StorageService>();

  ProfileController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxBool _isLogoutLoading = false.obs; // Separate loading for logout
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLogoutLoading => _isLogoutLoading.value;
  UserModel? get user => _user.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;

  // User info getters with null safety
  String get userName => user?.name ?? 'Unknown User';
  String get userEmail => user?.email ?? '';
  String get userPhone => user?.phone ?? '';
  String get userRole => user?.role ?? 'customer';
  int get userId => user?.id ?? 0;
  String? get userAvatar => user?.avatar;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      // Try to get from local storage first
      final localUser = await _getLocalUser();
      if (localUser != null) {
        _user.value = localUser;
        print(
            'ProfileController: Loaded user from local storage: ${localUser.name}');
      }

      // Then try to get from API
      final result = await _authRepository.getProfile();
      if (result.isSuccess && result.data != null) {
        _user.value = result.data!;
        await _saveLocalUser(result.data!);
        print('ProfileController: Loaded user from API: ${result.data!.name}');
      } else if (localUser == null) {
        // Only show error if no local data
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to load profile';
        print('ProfileController: Failed to load profile: ${result.message}');
      }
    } catch (e) {
      print('ProfileController: Exception loading profile: $e');
      if (_user.value == null) {
        _hasError.value = true;
        _errorMessage.value = 'Error loading profile: $e';
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<UserModel?> _getLocalUser() async {
    try {
      final userData = _storageService.readJson('user_profile');
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      print('ProfileController: Error loading local user: $e');
    }
    return null;
  }

  Future<void> _saveLocalUser(UserModel user) async {
    try {
      await _storageService.writeJson('user_profile', user.toJson());
    } catch (e) {
      print('ProfileController: Error saving local user: $e');
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  void navigateToEditProfile() {
    Get.toNamed('/edit_profile');
  }

  Future<void> logout() async {
    try {
      _isLogoutLoading.value = true; // Use separate loading state

      // Show loading snackbar
      Get.snackbar(
        'Logout',
        'Sedang logout...',
        backgroundColor: AppColors.info,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Call logout API
      final result = await _authRepository.logout();

      if (result.isSuccess) {
        // Clear local data
        await _clearAllUserData();

        // Show success message
        Get.snackbar(
          'Logout Berhasil',
          'Anda telah berhasil logout',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Even if API call fails, clear local data
        await _clearAllUserData();

        Get.snackbar(
          'Logout',
          'Logout berhasil (offline)',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      // Navigate to login and clear all previous routes
      await Future.delayed(
          const Duration(milliseconds: 500)); // Small delay for UX
      Get.offAllNamed('/login');
    } catch (e) {
      print('ProfileController: Logout error: $e');

      // Even if API call fails, clear local data
      await _clearAllUserData();

      Get.snackbar(
        'Logout',
        'Logout berhasil (offline)',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed('/login');
    } finally {
      _isLogoutLoading.value = false;
    }
  }

  Future<void> _clearAllUserData() async {
    try {
      // Clear user state first
      _user.value = null;

      // Clear all storage
      await _storageService.remove('user_profile');
      await _storageService.remove(StorageConstants.authToken);
      await _storageService.remove(StorageConstants.userId);
      await _storageService.remove(StorageConstants.userEmail);
      await _storageService.remove(StorageConstants.userName);
      await _storageService.remove(StorageConstants.userRole);
      await _storageService.remove(StorageConstants.isLoggedIn);

      print('ProfileController: All user data cleared');
    } catch (e) {
      print('ProfileController: Error clearing user data: $e');
    }
  }

  // Test image loading method
  void testImageLoading() {
    Get.snackbar(
      'Test',
      'Image loading test triggered',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  // Additional utility methods
  void showEditProfile() {
    Get.snackbar(
      'Edit Profile',
      'Fitur edit profile akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void changeProfilePicture() {
    Get.snackbar(
      'Change Photo',
      'Fitur ganti foto profil akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.accent,
      colorText: Colors.white,
    );
  }

  String get userDisplayName {
    if (userName.isNotEmpty && userName != 'Unknown User') {
      return userName;
    }
    return 'User';
  }

  String get roleDisplayName {
    switch (userRole.toLowerCase()) {
      case 'customer':
        return 'CUSTOMER';
      case 'driver':
        return 'DRIVER';
      case 'store':
        return 'STORE OWNER';
      case 'admin':
        return 'ADMIN';
      default:
        return userRole.toUpperCase();
    }
  }

  Color get roleColor {
    switch (userRole.toLowerCase()) {
      case 'customer':
        return AppColors.primary;
      case 'driver':
        return AppColors.secondary;
      case 'store':
        return AppColors.accent;
      case 'admin':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  // Method untuk testing tanpa API
  // void loadDummyData() {
  //   _user.value = UserModel(
  //     id: 2,
  //     name: 'customer tes',
  //     email: 'ct@gmail.com',
  //     phone: '081111222333',
  //     role: 'customer',
  //   );
  //   _isLoading.value = false;
  //   print('ProfileController: Dummy data loaded');
  // }

  // Method untuk check login status
  bool get isLoggedIn {
    final token = _storageService.readString(StorageConstants.authToken);
    return token != null && token.isNotEmpty && _user.value != null;
  }

  // Method untuk format phone number
  String get formattedPhone {
    if (userPhone.isEmpty) return 'Belum diatur';

    // Simple formatting for Indonesian phone numbers
    String phone = userPhone;
    if (phone.startsWith('62')) {
      phone = '0${phone.substring(2)}';
    }

    // Format: 0812-1234-5678
    if (phone.length >= 10) {
      return '${phone.substring(0, 4)}-${phone.substring(4, 8)}-${phone.substring(8)}';
    }

    return phone;
  }

  @override
  void onClose() {
    // Clean up any resources if needed
    super.onClose();
  }
}
