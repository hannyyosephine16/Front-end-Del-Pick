// lib/features/auth/controllers/auth_controller.dart - No Notification Service
import 'package:get/get.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final ConnectivityService _connectivityService;
  final StorageService _storageService;

  AuthController(
    this._authRepository,
    this._connectivityService,
    this._storageService,
  );

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

  // ✅ Check auth status
  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check dari storage
      final isStoredLoggedIn = _storageService.isUserLoggedIn();
      final storedToken = _storageService.getCurrentUserToken();
      final storedUser = _storageService.getCurrentUser();
      final storedRole = _storageService.getCurrentUserRole();

      if (isStoredLoggedIn &&
          storedToken != null &&
          storedUser != null &&
          storedRole != null) {
        // Load dari storage
        final user = UserModel.fromJson(storedUser);
        currentUser.value = user;
        userRole.value = storedRole;
        token.value = storedToken;
        isLoggedIn.value = true;

        // Load role-specific data
        await _loadRoleSpecificData();

        // Navigate ke home
        _navigateToHome(storedRole);

        // Refresh data di background jika ada koneksi
        if (_connectivityService.isConnected) {
          refreshUserDataInBackground();
        }
        return;
      }

      // Tidak ada data valid, ke login
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('❌ CheckAuthStatus error: $e');
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Login method - minimal validation
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

        // Update state
        currentUser.value = user;
        userRole.value = user.role;
        isLoggedIn.value = true;
        token.value = authToken;

        // Store role-specific data
        if (loginResponse.hasDriver) {
          driverData.value = loginResponse.driver;
        }
        if (loginResponse.hasStore) {
          storeData.value = loginResponse.store;
        }

        // Save ke storage
        await _storageService.saveLoginSession(
          authToken,
          user.toJson(),
          user.role,
          driverData: loginResponse.driver?.toJson(),
          storeData: loginResponse.store?.toJson(),
        );

        // Navigate ke home
        _navigateToHome(user.role);

        _showSuccessSnackbar('Login Berhasil', 'Selamat datang ${user.name}');
        return true;
      } else {
        errorMessage.value = result.errorMessage;
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

  // ✅ Register method
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!_connectivityService.isConnected) {
        _showErrorSnackbar('No Internet', 'Periksa koneksi internet Anda');
        return false;
      }

      // Validasi role minimal
      if (!AppConstants.validRoles.contains(role)) {
        _showErrorSnackbar('Invalid Role', 'Pilih role yang valid');
        return false;
      }

      print('🔄 Register attempt: $email ($role)');

      final result = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      if (result.isSuccess) {
        print('✅ Register success');
        _showSuccessSnackbar('Registrasi Berhasil', 'Akun berhasil dibuat');
        Get.offAllNamed(Routes.LOGIN);
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        _showErrorSnackbar('Registrasi Gagal', result.errorMessage);
        return false;
      }
    } catch (e) {
      print('❌ Register error: $e');
      errorMessage.value = e.toString();
      _showErrorSnackbar(
          'Registration Error', 'Terjadi kesalahan saat registrasi');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Logout method
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call API logout
      try {
        if (_connectivityService.isConnected) {
          await _authRepository.logout();
        }
      } catch (e) {
        print('❌ API logout failed: $e');
      }

      // Clear storage dan state
      await _storageService.clearLoginSession();
      await _clearAuthData();

      Get.offAllNamed(Routes.LOGIN);
      _showSuccessSnackbar('Logout Berhasil', 'Sampai jumpa!');
    } catch (e) {
      print('❌ Logout error: $e');
      // Tetap clear local data
      await _storageService.clearLoginSession();
      await _clearAuthData();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Update profile method
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
      );

      if (result.isSuccess && result.data != null) {
        currentUser.value = result.data;
        await _saveUserDataToStorage(result.data!);
        _showSuccessSnackbar('Update Berhasil', 'Profil berhasil diperbarui');
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        _showErrorSnackbar('Update Gagal', result.errorMessage);
        return false;
      }
    } catch (e) {
      print('❌ Update profile error: $e');
      errorMessage.value = e.toString();
      _showErrorSnackbar(
          'Update Error', 'Terjadi kesalahan saat update profil');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Forgot password method
  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.forgotPassword(email);

      if (result.isSuccess) {
        _showSuccessSnackbar('Berhasil', 'Email reset password telah dikirim');
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        _showErrorSnackbar('Gagal', result.errorMessage);
        return false;
      }
    } catch (e) {
      print('❌ Forgot password error: $e');
      errorMessage.value = e.toString();
      _showErrorSnackbar('Error', 'Terjadi kesalahan');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ===============================================
  // PRIVATE HELPER METHODS
  // ===============================================

  Future<void> _loadRoleSpecificData() async {
    if (isDriver) {
      final driverDataMap = _storageService.getDriverData();
      if (driverDataMap != null) {
        driverData.value = DriverModel.fromJson(driverDataMap);
      }
    } else if (isStore) {
      final storeDataMap = _storageService.getStoreData();
      if (storeDataMap != null) {
        storeData.value = StoreModel.fromJson(storeDataMap);
      }
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

  Future<void> _clearAuthData() async {
    isLoggedIn.value = false;
    currentUser.value = null;
    userRole.value = '';
    token.value = '';
    errorMessage.value = '';
    driverData.value = null;
    storeData.value = null;
  }

  Future<void> refreshUserDataInBackground() async {
    try {
      final result = await _authRepository.getProfile();
      if (result.isSuccess && result.data != null) {
        currentUser.value = result.data;
        await _saveUserDataToStorage(result.data!);
      }
    } catch (e) {
      print('❌ Background refresh failed: $e');
    }
  }

  void _navigateToHome(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        Get.offAllNamed(Routes.CUSTOMER_HOME);
        break;
      case 'driver':
        Get.offAllNamed(Routes.DRIVER_HOME);
        break;
      case 'store':
        Get.offAllNamed(Routes.STORE_DASHBOARD);
        break;
      case 'admin':
        // Admin bisa redirect ke customer untuk testing
        Get.offAllNamed(Routes.CUSTOMER_HOME);
        break;
      default:
        Get.offAllNamed(Routes.LOGIN);
        break;
    }
  }

  // ✅ Simple snackbar methods (no notification service)
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
  }

  // ===============================================
  // GETTERS
  // ===============================================

  bool get hasValidRole =>
      AppConstants.validRoles.contains(userRole.value.toLowerCase());
  String get displayName => currentUser.value?.name ?? '';
  String get userEmail => currentUser.value?.email ?? '';
  String get userPhone => currentUser.value?.phone ?? '';
  String get userAvatar => currentUser.value?.avatar ?? '';

  // Role checkers
  bool get isCustomer =>
      userRole.value.toLowerCase() == AppConstants.roleCustomer;
  bool get isDriver => userRole.value.toLowerCase() == AppConstants.roleDriver;
  bool get isStore => userRole.value.toLowerCase() == AppConstants.roleStore;
  bool get isAdmin => userRole.value.toLowerCase() == 'admin';

  // Role-specific data getters
  DriverModel? get currentDriverData => driverData.value;
  StoreModel? get currentStoreData => storeData.value;

  // Utility methods
  void clearError() => errorMessage.value = '';

  Future<void> refreshUser() async {
    if (isLoggedIn.value && _connectivityService.isConnected) {
      await refreshUserDataInBackground();
    }
  }

  bool get hasOfflineData => _storageService.isUserLoggedIn();

  void updateCurrentUser(UserModel user) {
    currentUser.value = user;
    _saveUserDataToStorage(user);
  }

  // ✅ Test method untuk development
  void testApiConnection() async {
    try {
      print('🔄 Testing API connection...');
      await login(email: 'admin@delpick.com', password: 'password');
    } catch (e) {
      print('❌ API connection test failed: $e');
    }
  }
}
