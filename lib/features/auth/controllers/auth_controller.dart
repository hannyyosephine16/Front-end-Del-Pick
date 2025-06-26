// lib/features/auth/controllers/auth_controller.dart - FIXED VERSION
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/services/local/storage_service_auth_extensions.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final ConnectivityService _connectivityService;
  final StorageService _storageService;
  late final ApiService _apiService;

  AuthController(
    this._authRepository,
    this._connectivityService,
    this._storageService,
  ) {
    _apiService = Get.find<ApiService>();
  }

  // Observable properties
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString userRole = ''.obs;
  final RxString token = ''.obs;
  final RxString errorMessage = ''.obs;

  // Role-specific data
  final Rx<DriverModel?> driverData = Rx<DriverModel?>(null);
  final Rx<StoreModel?> storeData = Rx<StoreModel?>(null);

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // ✅ Check auth status with proper token and avatar handling
  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔍 Checking auth status...');

      // Check dari storage
      final isStoredLoggedIn = _storageService.isUserLoggedIn();
      final storedToken = _storageService.getCurrentUserToken();
      final storedUser = _storageService.getCurrentUser();
      final storedRole = _storageService.getCurrentUserRole();

      print('📱 Storage check:');
      print('  - isLoggedIn: $isStoredLoggedIn');
      print('  - hasToken: ${storedToken != null}');
      print('  - hasUser: ${storedUser != null}');
      print('  - hasRole: ${storedRole != null}');

      if (isStoredLoggedIn &&
          storedToken != null &&
          storedUser != null &&
          storedRole != null) {
        // ✅ Load user dengan avatar dari storage
        final user = UserModel.fromJson(storedUser);
        currentUser.value = user;
        userRole.value = storedRole;
        token.value = storedToken;
        isLoggedIn.value = true;

        // ✅ SET TOKEN TO API SERVICE
        _apiService.setAuthToken(storedToken);
        print('✅ Token restored and set to API service');
        print('✅ User loaded: ${user.name}');
        print('✅ Avatar URL: ${user.avatar ?? 'No avatar'}');

        // ✅ Load role-specific data dari storage
        await _loadRoleSpecificData(storedRole);

        // Navigate ke home
        _navigateToHome(storedRole);
        return;
      }

      // Tidak ada data valid, ke login
      print('❌ No valid auth data found, redirecting to login');
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('❌ CheckAuthStatus error: $e');
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Load role-specific data from storage
  Future<void> _loadRoleSpecificData(String role) async {
    try {
      switch (role.toLowerCase()) {
        case 'driver':
          final storedDriverData = _storageService.getDriverData();
          if (storedDriverData != null) {
            driverData.value = DriverModel.fromJson(storedDriverData);
            print('✅ Driver data loaded from storage');
          }
          break;
        case 'store':
          final storedStoreData = _storageService.getStoreData();
          if (storedStoreData != null) {
            storeData.value = StoreModel.fromJson(storedStoreData);
            print('✅ Store data loaded from storage');
          }
          break;
      }
    } catch (e) {
      print('⚠️ Error loading role-specific data: $e');
    }
  }

  Future<void> _saveUserDataToStorage(UserModel user) async {
    await _storageService.writeJson(
        StorageConstants.userDataKey, user.toJson());
    await _storageService.writeString(StorageConstants.userName, user.name);
    await _storageService.writeString(StorageConstants.userEmail, user.email);
    if (user.phone != null) {
      await _storageService.writeString(
          StorageConstants.userPhone, user.phone!);
    }
    if (user.avatar != null) {
      await _storageService.writeString(
          StorageConstants.userAvatar, user.avatar!);
    }
  }

  Future<void> refreshUserDataInBackground() async {
    try {
      // Ensure token is set before making API call
      if (token.value.isNotEmpty) {
        _apiService.setAuthToken(token.value);
      }

      final result = await _authRepository.getProfile();
      if (result.isSuccess && result.data != null) {
        currentUser.value = result.data;
        await _saveUserDataToStorage(result.data!);
      }
    } catch (e) {
      print('❌ Background refresh failed: $e');
    }
  }

  // ✅ SIMPLIFIED LOGIN METHOD WITH PROPER TOKEN SAVE
  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!_connectivityService.isConnected) {
        _showErrorSnackbar('No Internet', 'Periksa koneksi internet Anda');
        return false;
      }

      print('🔄 Login attempt: $email');

      final result =
          await _authRepository.login(email: email, password: password);

      if (result.isSuccess && result.data != null) {
        final loginResponse = result.data!;
        final user = loginResponse.user;
        final authToken = loginResponse.token;

        print('✅ Login success: ${user.name} (${user.role})');
        print('✅ User avatar: ${user.avatar ?? 'No avatar'}');
        print('✅ Token length: ${authToken.length}');

        // ✅ Update state
        currentUser.value = user;
        userRole.value = user.role;
        isLoggedIn.value = true;
        token.value = authToken;

        // ✅ SET TOKEN TO API SERVICE IMMEDIATELY
        _apiService.setAuthToken(authToken);
        print('✅ Token set to API service successfully');

        // ✅ Store role-specific data
        if (loginResponse.hasDriver) {
          driverData.value = loginResponse.driver;
          print('✅ Driver data stored: ${loginResponse.driver?.id}');
        }
        if (loginResponse.hasStore) {
          storeData.value = loginResponse.store;
          print('✅ Store data stored: ${loginResponse.store?.id}');
        }

        // ✅ SAVE TO STORAGE WITH ALL DATA INCLUDING AVATAR
        await _saveCompleteLoginSession(loginResponse);

        // Navigate ke home based on role
        _navigateToHome(user.role);
        _showSuccessSnackbar('Login Berhasil', 'Selamat datang ${user.name}');
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        print('❌ Login failed: ${result.errorMessage}');
        _showErrorSnackbar('Login Gagal', result.errorMessage);
        return false;
      }
    } catch (e) {
      print('❌ Login error: $e');
      errorMessage.value = e.toString();
      _showErrorSnackbar('Login Error', 'Terjadi kesalahan saat login');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ SAVE COMPLETE LOGIN SESSION WITH PROPER TOKEN HANDLING
  Future<void> _saveCompleteLoginSession(dynamic loginResponse) async {
    try {
      print('💾 Saving complete login session...');

      // ✅ Save basic login data
      await _storageService.saveLoginSession(
        loginResponse.token,
        loginResponse.user.toJson(),
        loginResponse.user.role,
        driverData: loginResponse.driver?.toJson(),
        storeData: loginResponse.store?.toJson(),
      );

      // ✅ Verify token is saved correctly
      final savedToken = _storageService.getCurrentUserToken();
      if (savedToken == loginResponse.token) {
        print('✅ Token saved successfully');
      } else {
        print('❌ Token save verification failed');
        print('  - Expected: ${loginResponse.token.substring(0, 20)}...');
        print('  - Saved: ${savedToken?.substring(0, 20) ?? 'null'}...');
      }

      // ✅ Verify user data with avatar is saved
      final savedUser = _storageService.getCurrentUser();
      if (savedUser != null) {
        final user = UserModel.fromJson(savedUser);
        print(
            '✅ User saved successfully with avatar: ${user.avatar ?? 'No avatar'}');
      }

      print('✅ Complete login session saved successfully');
    } catch (e) {
      print('❌ Error saving login session: $e');
      throw e;
    }
  }

  // ✅ REFRESH USER PROFILE WITH AVATAR UPDATE
  Future<void> refreshUserProfile() async {
    try {
      if (!isLoggedIn.value || token.value.isEmpty) {
        print('❌ Cannot refresh profile: not logged in');
        return;
      }

      print('🔄 Refreshing user profile...');

      final result = await _authRepository.getProfile();
      if (result.isSuccess && result.data != null) {
        final updatedUser = result.data!;
        currentUser.value = updatedUser;

        print('✅ Profile refreshed successfully');
        print('✅ Updated avatar: ${updatedUser.avatar ?? 'No avatar'}');

        // ✅ Update storage dengan data terbaru
        // await _storageService.updateUserData(updatedUser.toJson());
      } else {
        print('❌ Failed to refresh profile: ${result.errorMessage}');
      }
    } catch (e) {
      print('❌ Error refreshing profile: $e');
    }
  }

  // ✅ UPDATE USER AVATAR
  // Future<bool> updateUserAvatar(String avatarBase64) async {
  //   try {
  //     print('📸 Updating user avatar...');
  //
  //     final result = await _authRepository.updateProfile(avatar: avatarBase64);
  //     if (result.isSuccess && result.data != null) {
  //       final updatedUser = result.data!;
  //       currentUser.value = updatedUser;
  //
  //       print('✅ Avatar updated successfully');
  //
  //       // Update storage
  //       // await _storageService.updateUserData(updatedUser.toJson());
  //
  //       _showSuccessSnackbar('Berhasil', 'Foto profil berhasil diperbarui');
  //       return true;
  //     } else {
  //       print('❌ Failed to update avatar: ${result.errorMessage}');
  //       _showErrorSnackbar('Gagal', result.errorMessage);
  //       return false;
  //     }
  //   } catch (e) {
  //     print('❌ Error updating avatar: $e');
  //     _showErrorSnackbar('Error', 'Gagal memperbarui foto profil');
  //     return false;
  //   }
  // }

  // ✅ NAVIGATION TO ROLE-BASED DASHBOARD
  void _navigateToHome(String role) {
    print('🚀 Navigating to home for role: $role');

    switch (role.toLowerCase()) {
      case 'customer':
        Get.offAllNamed(Routes.CUSTOMER_HOME);
        print('✅ Navigated to Customer Home');
        break;
      case 'driver':
        Get.offAllNamed(Routes.DRIVER_HOME);
        print('✅ Navigated to Driver Home');
        break;
      case 'store':
        Get.offAllNamed(Routes.STORE_DASHBOARD);
        print('✅ Navigated to Store Dashboard');
        break;
      default:
        print('❌ Unknown role: $role, redirecting to login');
        Get.offAllNamed(Routes.LOGIN);
        break;
    }
  }

  // ✅ LOGOUT WITH PROPER TOKEN CLEAR
  Future<void> logout() async {
    try {
      isLoading.value = true;
      print('🔄 Logging out...');

      // Call API logout
      try {
        if (_connectivityService.isConnected) {
          await _authRepository.logout();
          print('✅ API logout successful');
        }
      } catch (e) {
        print('❌ API logout failed: $e');
      }

      // ✅ CLEAR TOKEN FROM API SERVICE
      _apiService.clearAuthToken();
      print('✅ Token cleared from API service');

      // ✅ Clear storage dan state
      await _storageService.clearLoginSession();
      await _clearAuthData();
      print('✅ Local data cleared');

      Get.offAllNamed(Routes.LOGIN);
      _showSuccessSnackbar('Logout Berhasil', 'Sampai jumpa!');
    } catch (e) {
      print('❌ Logout error: $e');
      // Tetap clear local data
      _apiService.clearAuthToken();
      await _storageService.clearLoginSession();
      await _clearAuthData();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearAuthData() async {
    isLoggedIn.value = false;
    currentUser.value = null;
    userRole.value = '';
    token.value = '';
    errorMessage.value = '';
    driverData.value = null;
    storeData.value = null;
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
  }

  // ✅ GETTERS WITH AVATAR SUPPORT
  bool get isCustomer => userRole.value.toLowerCase() == 'customer';
  bool get isDriver => userRole.value.toLowerCase() == 'driver';
  bool get isStore => userRole.value.toLowerCase() == 'store';

  String get displayName => currentUser.value?.name ?? '';
  String get userEmail => currentUser.value?.email ?? '';
  String? get userAvatar => currentUser.value?.avatar;
  String get userPhone => currentUser.value?.phone ?? '';

  // ✅ Avatar-related getters
  bool get hasAvatar => userAvatar != null && userAvatar!.isNotEmpty;
  String get avatarUrl {
    if (hasAvatar) {
      // If it's already a full URL, return as is
      if (userAvatar!.startsWith('http')) {
        return userAvatar!;
      }
      // If it's a relative path, construct full URL
      return '${ApiEndpoints.baseUrl}${userAvatar!}';
    }
    return '';
  }

  void clearError() => errorMessage.value = '';
}
