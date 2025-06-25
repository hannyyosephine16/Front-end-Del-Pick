// lib/features/auth/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/core/services/external/notification_service.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/utils/helpers.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/data/models/auth/login_response_model.dart';

import '../../../data/models/driver/driver_model.dart';
import '../../../data/models/store/store_model.dart';

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

  // Additional data for driver/store
  final Rx<Map<String, dynamic>?> additionalData =
      Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Check if user is already logged in from storage
  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // First check from storage (offline capability)
      final isStoredLoggedIn = _storageService.readBoolWithDefault(
          StorageConstants.isLoggedIn, false);

      if (isStoredLoggedIn) {
        final storedToken =
            _storageService.readString(StorageConstants.authToken);
        final storedRole =
            _storageService.readString(StorageConstants.userRole);
        final storedUserData =
            _storageService.readJson(StorageConstants.userDataKey);

        if (storedToken != null &&
            storedRole != null &&
            storedUserData != null) {
          // Load from storage first
          final user = UserModel.fromJson(storedUserData);
          currentUser.value = user;
          userRole.value = storedRole;
          token.value = storedToken;
          isLoggedIn.value = true;

          // Load additional data from storage
          await _loadAdditionalDataFromStorage();

          // Navigate to home
          _navigateToHome(storedRole);

          // Try to refresh from API in background (if connected)
          if (_connectivityService.isConnected) {
            _refreshUserDataInBackground();
          }
          return;
        }
      }
      // No valid storage data, try API
      if (_connectivityService.isConnected) {
        final userData = await _authRepository.getCurrentUser();
        if (userData != null) {
          currentUser.value = userData;
          userRole.value = userData.role ?? '';
          isLoggedIn.value = true;

          // Save to storage
          await _saveUserDataToStorage(userData);

          // Navigate to appropriate home
          _navigateToHome(userData.role ?? '');
        } else {
          // API failed, clear storage and go to login
          await _clearAuthData();
          Get.offAllNamed(Routes.LOGIN);
        }
      } else {
        // No internet and no valid storage, go to login
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      // On error, try to use storage data or go to login
      final hasStorageData = _storageService.readBoolWithDefault(
          StorageConstants.isLoggedIn, false);

      if (hasStorageData) {
        Helpers.showWarningSnackbar(
          'Offline Mode',
          'Using cached data',
          Get.context!,
        );
      } else {
        Helpers.showErrorSnackbar(
          'Error',
          'Failed to check auth status',
          Get.context!,
        );
        Get.offAllNamed(Routes.LOGIN);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Login method - with storage persistence
  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check connectivity
      if (!_connectivityService.isConnected) {
        Helpers.showErrorSnackbar(
          'No Internet',
          'Please check your internet connection',
          Get.context!,
        );
        return false;
      }

      // Call the login repository method
      final result =
          await _authRepository.login(email: email, password: password);

      if (result.isSuccess && result.data != null) {
        // Convert result data to LoginResponseModel
        final loginResponse =
            LoginResponseModel.fromJson(result.data as Map<String, dynamic>);

        // Extract user data from login response
        final user = loginResponse.user;
        final authToken = loginResponse.token;

        // Update state
        currentUser.value = user;
        userRole.value = user.role ?? '';
        isLoggedIn.value = true;
        token.value = authToken;

        // Save to storage
        await _saveAuthDataToStorage(user, authToken, loginResponse.toJson());

        // Store additional data (driver/store info if any)
        _storeAdditionalData(loginResponse);

        // Navigate to appropriate home
        _navigateToHome(user.role ?? '');

        Helpers.showSuccessSnackbar(
          'Success',
          'Login successful',
          Get.context!,
        );
        return true;
      } else {
        errorMessage.value = result.message ?? 'Login failed';
        Helpers.showErrorSnackbar(
          'Login Failed',
          result.message ?? 'Unknown error',
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar(
        'Login Error',
        e.toString(),
        Get.context!,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Register method
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

      // Check connectivity
      if (!_connectivityService.isConnected) {
        Helpers.showErrorSnackbar(
          'No Internet',
          'Please check your internet connection',
          Get.context!,
        );
        return false;
      }

      // Validate role
      if (!AppConstants.validRoles.contains(role)) {
        Helpers.showErrorSnackbar(
          'Invalid Role',
          'Please select a valid role',
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
          'Success',
          'Registration successful. Please login.',
          Get.context!,
        );
        Get.offAllNamed(Routes.LOGIN);
        return true;
      } else {
        errorMessage.value = result.message ?? 'Registration failed';
        Helpers.showErrorSnackbar(
          'Registration Failed',
          result.message ?? 'Unknown error',
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar(
          'Registration Error', e.toString(), Get.context!);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method - clear storage
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call API logout (even if it fails, we clear local data)
      try {
        if (_connectivityService.isConnected) {
          await _authRepository.logout();
        }
      } catch (e) {
        // Continue with logout even if API fails
        print('API logout failed: $e');
      }

      // Clear all data
      await _clearAuthData();

      // Clear notifications
      await _notificationService.clearToken();

      // Navigate to login
      Get.offAllNamed(Routes.LOGIN);

      Helpers.showSuccessSnackbar(
          'Success', 'Logged out successfully', Get.context!);
    } catch (e) {
      // Still clear local data and navigate
      await _clearAuthData();
      Get.offAllNamed(Routes.LOGIN);
      Helpers.showErrorSnackbar(
        'Logout Error',
        e.toString(),
        Get.context!,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile - with storage update
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
          'Success',
          'Profile updated successfully',
          Get.context!,
        );
        return true;
      } else {
        errorMessage.value = result.message ?? 'Profile update failed';
        Helpers.showErrorSnackbar(
          'Update Failed',
          result.message ?? 'Unknown error',
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar('Update Error', e.toString(), Get.context!);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk update current user (dipanggil dari profile controller)
  void updateCurrentUser(UserModel user) {
    currentUser.value = user;
    _saveUserDataToStorage(user);
  }

  // Storage management methods
  Future<void> _saveAuthDataToStorage(UserModel user, String authToken,
      Map<String, dynamic> loginResponse) async {
    // Simpan data utama pengguna
    await _storageService.writeString(StorageConstants.authToken, authToken);
    await _storageService.writeJson(
        StorageConstants.userDataKey, user.toJson());
    await _storageService.writeString(
        StorageConstants.userRole, user.role ?? '');
    await _storageService.writeString(
        StorageConstants.userName, user.name ?? '');
    await _storageService.writeString(
        StorageConstants.userEmail, user.email ?? '');
    await _storageService.writeBool(StorageConstants.isLoggedIn, true);

    // Simpan optional fields
    if (user.phone != null) {
      await _storageService.writeString(
          StorageConstants.userPhone, user.phone!);
    }
    if (user.avatar != null) {
      await _storageService.writeString(
          StorageConstants.userAvatar, user.avatar!);
    }

    // Menyimpan data store dan driver jika ada
    if (loginResponse['store'] != null) {
      final storeData = StoreModel.fromJson(loginResponse['store']);
      await _storageService.writeJson(
          StorageConstants.storeDataKey, storeData.toJson());
    }
    if (loginResponse['driver'] != null) {
      final driverData = DriverModel.fromJson(loginResponse['driver']);
      await _storageService.writeJson(
          StorageConstants.driverDataKey, driverData.toJson());
    }
  }

  Future<void> _saveUserDataToStorage(UserModel user) async {
    await _storageService.writeJson(
        StorageConstants.userDataKey, user.toJson());
    await _storageService.writeString(
        StorageConstants.userName, user.name ?? '');
    await _storageService.writeString(
        StorageConstants.userEmail, user.email ?? '');

    if (user.phone != null) {
      await _storageService.writeString(
          StorageConstants.userPhone, user.phone!);
    }
    if (user.avatar != null) {
      await _storageService.writeString(
          StorageConstants.userAvatar, user.avatar!);
    }
  }

  Future<void> _loadAdditionalDataFromStorage() async {
    if (isDriver) {
      final driverData =
          _storageService.readJson(StorageConstants.driverDataKey);
      if (driverData != null) {
        additionalData.value = {'driver': driverData};
      }
    } else if (isStore) {
      final storeData = _storageService.readJson(StorageConstants.storeDataKey);
      if (storeData != null) {
        additionalData.value = {'store': storeData};
      }
    }
  }

  Future<void> _clearAuthData() async {
    // Clear state
    isLoggedIn.value = false;
    currentUser.value = null;
    userRole.value = '';
    token.value = '';
    errorMessage.value = '';
    additionalData.value = null;

    // Clear storage
    await _storageService.remove(StorageConstants.authToken);
    await _storageService.remove(StorageConstants.userDataKey);
    await _storageService.remove(StorageConstants.userRole);
    await _storageService.remove(StorageConstants.userName);
    await _storageService.remove(StorageConstants.userEmail);
    await _storageService.remove(StorageConstants.userPhone);
    await _storageService.remove(StorageConstants.userAvatar);
    await _storageService.remove(StorageConstants.fcmToken);
    await _storageService.remove(StorageConstants.driverDataKey);
    await _storageService.remove(StorageConstants.storeDataKey);
    await _storageService.writeBool(StorageConstants.isLoggedIn, false);
  }

  // Background refresh when app becomes active
  Future<void> _refreshUserDataInBackground() async {
    try {
      final userData = await _authRepository.getCurrentUser();
      if (userData != null) {
        currentUser.value = userData;
        await _saveUserDataToStorage(userData);
      }
    } catch (e) {
      // Silent failure for background refresh
      print('Background refresh failed: $e');
    }
  }

  // Other methods remain the same...
  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.forgotPassword(email);

      if (result.isSuccess) {
        Helpers.showSuccessSnackbar(
          'Success',
          'Password reset email sent',
          Get.context!,
        );
        return true;
      } else {
        errorMessage.value = result.message ?? 'Failed to send reset email';
        Helpers.showErrorSnackbar(
          'Failed',
          result.message ?? 'Unknown error',
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar('Error', e.toString(), Get.context!);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

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
            'Success', 'Password reset successful', Get.context!);
        Get.offAllNamed(Routes.LOGIN);
        return true;
      } else {
        errorMessage.value = result.message ?? 'Password reset failed';
        Helpers.showErrorSnackbar(
          'Failed',
          result.message ?? 'Unknown error',
          Get.context!,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Helpers.showErrorSnackbar(
        'Error',
        e.toString(),
        Get.context!,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _authRepository.updateFcmToken(fcmToken);
      await _storageService.writeString(StorageConstants.fcmToken, fcmToken);
    } catch (e) {
      print('Failed to update FCM token: $e');
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

  void _storeAdditionalData(LoginResponseModel loginResponse) {
    // Store data for driver if available
    if (loginResponse.isDriver && loginResponse.driver != null) {
      additionalData.value = {'driver': loginResponse.driver?.toJson()};
    }

    // Store data for store if available
    if (loginResponse.isStore && loginResponse.store != null) {
      additionalData.value = {'store': loginResponse.store?.toJson()};
    }
  }

  // Getters
  bool get hasValidRole =>
      AppConstants.validRoles.contains(userRole.value.toLowerCase());
  String get displayName => currentUser.value?.name ?? '';
  String get userEmail => currentUser.value?.email ?? '';
  String get userPhone => currentUser.value?.phone ?? '';
  String get userAvatar => currentUser.value?.avatar ?? '';

  // Role checkers
  bool get isCustomer => userRole.value.toLowerCase() == 'customer';
  bool get isDriver => userRole.value.toLowerCase() == 'driver';
  bool get isStore => userRole.value.toLowerCase() == 'store';

  // Additional data getters
  Map<String, dynamic>? get driverData {
    return additionalData.value?['driver'] as Map<String, dynamic>?;
  }

  Map<String, dynamic>? get storeData {
    return additionalData.value?['store'] as Map<String, dynamic>?;
  }

  // Utility methods
  void clearError() {
    errorMessage.value = '';
  }

  Future<void> refreshUser() async {
    if (isLoggedIn.value && _connectivityService.isConnected) {
      await _refreshUserDataInBackground();
    }
  }

  // Check if user has cached data (for offline mode)
  bool get hasOfflineData =>
      _storageService.readBoolWithDefault(StorageConstants.isLoggedIn, false);
}
