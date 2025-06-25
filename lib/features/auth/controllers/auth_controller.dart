// lib/features/auth/controllers/auth_controller.dart - FIXED
import 'package:get/get.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/auth/login_response_model.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/core/services/external/notification_service.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/utils/helpers.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;
  final ConnectivityService _connectivityService;
  final StorageService _storageService;

  AuthController(
    this._authRepository,
    this._notificationService,
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

  // ✅ Check auth status dari storage dan API
  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check dari storage terlebih dahulu
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
          _refreshUserDataInBackground();
        }
        return;
      }

      // Tidak ada data valid di storage, coba dari API
      if (_connectivityService.isConnected) {
        final result = await _authRepository.getProfile();
        if (result.isSuccess && result.data != null) {
          currentUser.value = result.data;
          userRole.value = result.data!.role;
          isLoggedIn.value = true;

          // Save ke storage
          await _saveUserDataToStorage(result.data!);
          await _loadRoleSpecificData();

          _navigateToHome(result.data!.role);
        } else {
          // API gagal, clear storage dan ke login
          await _clearAuthData();
          Get.offAllNamed(Routes.LOGIN);
        }
      } else {
        // Tidak ada internet dan tidak ada data valid
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print('❌ CheckAuthStatus error: $e');
      final hasStorageData = _storageService.isUserLoggedIn();

      if (hasStorageData) {
        Helpers.showWarningSnackbar(
          'Offline Mode',
          'Menggunakan data tersimpan',
          Get.context!,
        );
      } else {
        Helpers.showErrorSnackbar(
          'Error',
          'Gagal memeriksa status login',
          Get.context!,
        );
        Get.offAllNamed(Routes.LOGIN);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Login method - sesuai dengan backend response
  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!_connectivityService.isConnected) {
        Helpers.showErrorSnackbar(
          'No Internet',
          'Periksa koneksi internet Anda',
          Get.context!,
        );
        return false;
      }

      final result =
          await _authRepository.login(email: email, password: password);

      if (result.isSuccess && result.data != null) {
        // Data dari backend sudah dalam format LoginResponseModel
        final loginResponse = result.data!;
        final user = loginResponse.user;
        final authToken = loginResponse.token;

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

        // Save ke storage menggunakan method yang sudah ada
        await _storageService.saveLoginSession(
          authToken,
          user.toJson(),
          user.role,
          driverData: loginResponse.driver?.toJson(),
          storeData: loginResponse.store?.toJson(),
        );

        // Navigate ke home
        _navigateToHome(user.role);

        Helpers.showSuccessSnackbar(
          'Berhasil',
          AppConstants.successLogin,
          Get.context!,
        );
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        Helpers.showErrorSnackbar(
          'Login Gagal',
          result.errorMessage,
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      print('❌ Login error: $e');
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar(
        'Login Error',
        'Terjadi kesalahan saat login',
        Get.context!,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Register method - sesuai dengan backend
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
        Helpers.showErrorSnackbar(
          'No Internet',
          'Periksa koneksi internet Anda',
          Get.context!,
        );
        return false;
      }

      // Validasi role
      if (!AppConstants.validRoles.contains(role)) {
        Helpers.showErrorSnackbar(
          'Invalid Role',
          'Pilih role yang valid',
          Get.context!,
        );
        return false;
      }

      final result = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      if (result.isSuccess) {
        Helpers.showSuccessSnackbar(
          'Berhasil',
          AppConstants.successRegister,
          Get.context!,
        );
        Get.offAllNamed(Routes.LOGIN);
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        Helpers.showErrorSnackbar(
          'Registrasi Gagal',
          result.errorMessage,
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      print('❌ Register error: $e');
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar(
        'Registration Error',
        'Terjadi kesalahan saat registrasi',
        Get.context!,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Logout method - clear semua data
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call API logout (bahkan jika gagal, tetap clear local data)
      try {
        if (_connectivityService.isConnected) {
          await _authRepository.logout();
        }
      } catch (e) {
        print('❌ API logout failed: $e');
      }

      // Clear semua data menggunakan method storage
      await _storageService.clearLoginSession();
      await _clearAuthData();

      // Clear notifications
      await _notificationService.clearToken();

      // Navigate ke login
      Get.offAllNamed(Routes.LOGIN);

      Helpers.showSuccessSnackbar(
        'Berhasil',
        'Logout berhasil',
        Get.context!,
      );
    } catch (e) {
      print('❌ Logout error: $e');
      // Tetap clear local data dan navigate
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

        // Update storage
        await _saveUserDataToStorage(result.data!);

        Helpers.showSuccessSnackbar(
          'Berhasil',
          AppConstants.successUpdate,
          Get.context!,
        );
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        Helpers.showErrorSnackbar(
          'Update Gagal',
          result.errorMessage,
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      print('❌ Update profile error: $e');
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar(
        'Update Error',
        'Terjadi kesalahan saat update profil',
        Get.context!,
      );
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
        Helpers.showSuccessSnackbar(
          'Berhasil',
          'Email reset password telah dikirim',
          Get.context!,
        );
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        Helpers.showErrorSnackbar(
          'Gagal',
          result.errorMessage,
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      print('❌ Forgot password error: $e');
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar(
        'Error',
        'Terjadi kesalahan',
        Get.context!,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Reset password method
  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.resetPassword(
        token: token,
        password: password,
      );

      if (result.isSuccess) {
        Helpers.showSuccessSnackbar(
          'Berhasil',
          'Password berhasil direset',
          Get.context!,
        );
        Get.offAllNamed(Routes.LOGIN);
        return true;
      } else {
        errorMessage.value = result.errorMessage;
        Helpers.showErrorSnackbar(
          'Gagal',
          result.errorMessage,
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      print('❌ Reset password error: $e');
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar(
        'Error',
        'Terjadi kesalahan',
        Get.context!,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _authRepository.updateFcmToken(fcmToken);
      await _storageService.saveFCMToken(fcmToken);
    } catch (e) {
      print('❌ Failed to update FCM token: $e');
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
    // Clear reactive state
    isLoggedIn.value = false;
    currentUser.value = null;
    userRole.value = '';
    token.value = '';
    errorMessage.value = '';
    driverData.value = null;
    storeData.value = null;
  }

  Future<void> _refreshUserDataInBackground() async {
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
      default:
        Get.offAllNamed(Routes.LOGIN);
        break;
    }
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

  // Role-specific data getters
  DriverModel? get currentDriverData => driverData.value;
  StoreModel? get currentStoreData => storeData.value;

  // Utility methods
  void clearError() => errorMessage.value = '';

  Future<void> refreshUser() async {
    if (isLoggedIn.value && _connectivityService.isConnected) {
      await _refreshUserDataInBackground();
    }
  }

  bool get hasOfflineData => _storageService.isUserLoggedIn();

  // Method untuk update current user (dipanggil dari profile controller)
  void updateCurrentUser(UserModel user) {
    currentUser.value = user;
    _saveUserDataToStorage(user);
  }
}
