import 'package:get/get.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final StorageService _storageService = Get.find<StorageService>();

  AuthController(this._authRepository);

  // Observable variables
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxString _userRole = ''.obs;
  final Rx<Map<String, dynamic>?> _rawUserData =
      Rx<Map<String, dynamic>?>(null);

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  UserModel? get currentUser => _currentUser.value;
  String get userRole => _userRole.value;
  Map<String, dynamic>? get rawUserData => _rawUserData.value;

  // Role checkers
  bool get isCustomer => userRole == AppConstants.roleCustomer;
  bool get isDriver => userRole == AppConstants.roleDriver;
  bool get isStore => userRole == AppConstants.roleStore;
  bool get isAdmin => userRole == AppConstants.roleAdmin;

  // Driver and Store data getters
  Map<String, dynamic>? get driverData {
    if (rawUserData != null && rawUserData!.containsKey('driver')) {
      return rawUserData!['driver'] as Map<String, dynamic>?;
    }
    return null;
  }

  Map<String, dynamic>? get storeData {
    if (rawUserData != null && rawUserData!.containsKey('store')) {
      return rawUserData!['store'] as Map<String, dynamic>?;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      _isLoading.value = true;

      final isLoggedIn = _storageService.readBoolWithDefault(
        StorageConstants.isLoggedIn,
        false,
      );

      if (isLoggedIn) {
        final token = _storageService.readString(StorageConstants.authToken);
        final role = _storageService.readString(StorageConstants.userRole);

        if (token != null && token.isNotEmpty && role != null) {
          _isLoggedIn.value = true;
          _userRole.value = role;

          // Load user profile and raw data
          await _loadUserProfile();
        } else {
          await _clearAuthData();
        }
      }
    } catch (e) {
      await _clearAuthData();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await _authRepository.getProfile();

      if (result.isSuccess && result.data != null) {
        _currentUser.value = result.data;
        _userRole.value = result.data!.role;

        // Load raw data from storage
        final rawDataKey =
            '${StorageConstants.userRole}_${result.data!.role}_raw';
        final rawData = _storageService.readJson(rawDataKey);
        if (rawData != null) {
          _rawUserData.value = rawData;
        }
      } else {
        // Try to use cached data
        final userData = _storageService.readJson(StorageConstants.userId);
        if (userData != null) {
          try {
            _currentUser.value = UserModel.fromJson(userData);
            final rawDataKey =
                '${StorageConstants.userRole}_${_currentUser.value!.role}_raw';
            final rawData = _storageService.readJson(rawDataKey);
            if (rawData != null) {
              _rawUserData.value = rawData;
            }
          } catch (e) {
            await _clearAuthData();
          }
        } else {
          await _clearAuthData();
        }
      }
    } catch (e) {
      // Try cached data as fallback
      final userData = _storageService.readJson(StorageConstants.userId);
      if (userData != null) {
        try {
          _currentUser.value = UserModel.fromJson(userData);
          final rawDataKey =
              '${StorageConstants.userRole}_${_currentUser.value!.role}_raw';
          final rawData = _storageService.readJson(rawDataKey);
          if (rawData != null) {
            _rawUserData.value = rawData;
          }
        } catch (e) {
          await _clearAuthData();
        }
      }
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading.value = true;

      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.data != null) {
        final data = result.data!;

        // Extract user data
        Map<String, dynamic> userData = Map<String, dynamic>.from(data['user']);

        // Merge driver/store data if exists
        if (data.containsKey('driver') && data['driver'] != null) {
          userData['driver'] = data['driver'];
        }

        if (data.containsKey('store') && data['store'] != null) {
          userData['store'] = data['store'];
        }

        // Store raw user data
        _rawUserData.value = userData;

        // Create UserModel from basic user data
        final basicUserData = Map<String, dynamic>.from(userData);
        basicUserData.remove('driver');
        basicUserData.remove('store');

        final user = UserModel.fromJson(basicUserData);
        _currentUser.value = user;
        _userRole.value = user.role;
        _isLoggedIn.value = true;

        // Save to storage
        await _saveUserDataToStorage(user, userData, data['token']);

        // Navigate based on role
        _navigateBasedOnRole(user.role);

        Get.snackbar(
          'Success',
          'Login successful',
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Login failed',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during login',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      _isLoading.value = true;

      final result = await _authRepository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
      );

      if (result.isSuccess && result.data != null) {
        _currentUser.value = result.data;

        // Update storage
        await _storageService.writeJson(
            StorageConstants.userId, result.data!.toJson());
        await _storageService.writeString(
            StorageConstants.userName, result.data!.name);
        await _storageService.writeString(
            StorageConstants.userEmail, result.data!.email);

        if (result.data!.phone != null) {
          await _storageService.writeString(
              StorageConstants.userPhone, result.data!.phone!);
        }

        if (result.data!.avatar != null) {
          await _storageService.writeString(
              StorageConstants.userAvatar, result.data!.avatar!);
        }

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Update failed',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during update',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateFcmToken(String fcmToken) async {
    try {
      // Note: This would need to be implemented in AuthRepository
      // For now, just store locally
      await _storageService.writeString(StorageConstants.fcmToken, fcmToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _isLoading.value = true;

      final result = await _authRepository.forgotPassword(email);

      if (result.isSuccess) {
        Get.snackbar(
          'Success',
          'Password reset email sent',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to send reset email',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;

      final result = await _authRepository.resetPassword(
        token: token,
        password: newPassword, // ✅ FIXED: Use 'password' parameter name
      );

      if (result.isSuccess) {
        Get.snackbar(
          'Success',
          'Password reset successfully',
          snackPosition: SnackPosition.TOP,
        );

        Get.offAllNamed(Routes.LOGIN);
        return true;
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Password reset failed',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Call API logout
      await _authRepository.logout();

      // Clear local data
      await _clearAuthData();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      // Still clear local data even if API call fails
      await _clearAuthData();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _saveUserDataToStorage(
      UserModel user, Map<String, dynamic> rawData, String token) async {
    // Save basic auth data
    await _storageService.writeString(StorageConstants.authToken, token);
    await _storageService.writeJson(StorageConstants.userId, user.toJson());
    await _storageService.writeString(StorageConstants.userRole, user.role);
    await _storageService.writeString(StorageConstants.userEmail, user.email);
    await _storageService.writeString(StorageConstants.userName, user.name);
    await _storageService.writeBool(StorageConstants.isLoggedIn, true);

    // Save optional fields
    if (user.phone != null) {
      await _storageService.writeString(
          StorageConstants.userPhone, user.phone!);
    }

    if (user.avatar != null) {
      await _storageService.writeString(
          StorageConstants.userAvatar, user.avatar!);
    }

    // Save raw data with role-specific key
    final rawDataKey = '${StorageConstants.userRole}_${user.role}_raw';
    await _storageService.writeJson(rawDataKey, rawData);
  }

  Future<void> _clearAuthData() async {
    _currentUser.value = null;
    _userRole.value = '';
    _isLoggedIn.value = false;
    _rawUserData.value = null;

    // Clear all auth-related storage
    await _storageService.remove(StorageConstants.authToken);
    await _storageService.remove(StorageConstants.refreshToken);
    await _storageService.remove(StorageConstants.userId);
    await _storageService.remove(StorageConstants.userRole);
    await _storageService.remove(StorageConstants.userEmail);
    await _storageService.remove(StorageConstants.userName);
    await _storageService.remove(StorageConstants.userPhone);
    await _storageService.remove(StorageConstants.userAvatar);
    await _storageService.remove(StorageConstants.fcmToken);
    await _storageService.writeBool(StorageConstants.isLoggedIn, false);

    // Clear role-specific raw data
    for (final role in AppConstants.validRoles) {
      await _storageService.remove('${StorageConstants.userRole}_${role}_raw');
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        Get.offAllNamed(Routes.CUSTOMER_HOME);
        break;
      case AppConstants.roleDriver:
        Get.offAllNamed(Routes.DRIVER_MAIN);
        break;
      case AppConstants.roleStore:
        Get.offAllNamed(Routes.STORE_DASHBOARD);
        break;
      default:
        Get.offAllNamed(Routes.LOGIN);
    }
  }

  void updateCurrentUser(UserModel user) {
    _currentUser.value = user;
    _userRole.value = user.role;

    // Update storage
    _storageService.writeJson(StorageConstants.userId, user.toJson());
    _storageService.writeString(StorageConstants.userRole, user.role);
    _storageService.writeString(StorageConstants.userEmail, user.email);
    _storageService.writeString(StorageConstants.userName, user.name);

    if (user.phone != null) {
      _storageService.writeString(StorageConstants.userPhone, user.phone!);
    }

    if (user.avatar != null) {
      _storageService.writeString(StorageConstants.userAvatar, user.avatar!);
    }
  }

  // Quick access methods
  String get userName => currentUser?.name ?? '';
  String get userEmail => currentUser?.email ?? '';
  String? get userAvatar => currentUser?.avatar;
  String? get userPhone => currentUser?.phone;

  // Permission check methods
  bool canAccessCustomerFeatures() => isCustomer;
  bool canAccessDriverFeatures() => isDriver;
  bool canAccessStoreFeatures() => isStore;
  bool canAccessAdminFeatures() => isAdmin;
}
