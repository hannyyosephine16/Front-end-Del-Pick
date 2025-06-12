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
  bool get isCustomer => userRole == AppConstants.roleCustomer;
  bool get isDriver => userRole == AppConstants.roleDriver;
  bool get isStore => userRole == AppConstants.roleStore;
  bool get isAdmin => userRole == AppConstants.roleAdmin;

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

          // Try to get fresh user data
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
        // Store the user model
        _currentUser.value = result.data;
        _userRole.value = result.data!.role;

        //  Try to get raw data from storage if needed
        if (_rawUserData.value == null) {
          final rawData =
              _storageService.readJson(StorageConstants.userRole + '_raw');
          if (rawData != null) {
            _rawUserData.value = rawData;
            print('Raw user data loaded from storage');
          }
        }
      } else {
        await _clearAuthData();
      }
    } catch (e) {
      // Try to use cached data
      final userData = _storageService.readJson(StorageConstants.userId);
      final rawData =
          _storageService.readJson(StorageConstants.userRole + '_raw');

      if (userData != null) {
        try {
          _currentUser.value = UserModel.fromJson(userData);
          if (rawData != null) {
            _rawUserData.value = rawData;
          }
        } catch (e) {
          await _clearAuthData();
        }
      }
    }
  }

  // Future<void> _loadUserProfile() async {
  //   try {
  //     final result = await _authRepository.getProfile();
  //
  //     if (result.isSuccess && result.data != null) {
  //       _currentUser.value = result.data;
  //       _userRole.value = result.data!.role;
  //     } else {
  //       // If profile fetch fails, clear auth data
  //       await _clearAuthData();
  //     }
  //   } catch (e) {
  //     // If error occurs, try to use cached user data
  //     final userData = _storageService.readJson(StorageConstants.userId);
  //     if (userData != null) {
  //       try {
  //         _currentUser.value = UserModel.fromJson(userData);
  //       } catch (e) {
  //         await _clearAuthData();
  //       }
  //     }
  //   }
  // }

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading.value = true;

      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.data != null) {
        final data = result.data!;

        //  Handle user data with embedded driver/store data
        Map<String, dynamic> userData = Map<String, dynamic>.from(data['user']);

        // Merge separate driver/store data into user data
        if (data.containsKey('driver') && data['driver'] != null) {
          userData['driver'] = data['driver'];
          print('Driver data merged: ${data['driver']}');
        }

        if (data.containsKey('store') && data['store'] != null) {
          userData['store'] = data['store'];
          print('Store data merged: ${data['store']}');
        }

        // Store raw user data
        _rawUserData.value = userData;

        // Create UserModel from basic user data (without driver/store)
        final basicUserData = Map<String, dynamic>.from(userData);
        basicUserData.remove('driver');
        basicUserData.remove('store');

        final user = UserModel.fromJson(basicUserData);

        _currentUser.value = user;
        _userRole.value = user.role;
        _isLoggedIn.value = true;

        // Save raw data to storage for persistence
        await _storageService.writeJson(
            StorageConstants.userRole + '_raw', userData);

        // Navigate based on user role
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
      print('Login error: $e');
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

  // Future<bool> login({required String email, required String password}) async {
  //   try {
  //     _isLoading.value = true;
  //
  //     final result = await _authRepository.login(
  //       email: email,
  //       password: password,
  //     );
  //
  //     if (result.isSuccess && result.data != null) {
  //       final data = result.data!;
  //       final user = UserModel.fromJson(data['user']);
  //
  //       _currentUser.value = user;
  //       _userRole.value = user.role;
  //       _isLoggedIn.value = true;
  //
  //       // Navigate based on user role
  //       _navigateBasedOnRole(user.role);
  //
  //       Get.snackbar(
  //         'Success',
  //         'Login successful',
  //         snackPosition: SnackPosition.TOP,
  //       );
  //
  //       return true;
  //     } else {
  //       Get.snackbar(
  //         'Error',
  //         result.message ?? 'Login failed',
  //         snackPosition: SnackPosition.TOP,
  //       );
  //       return false;
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'An error occurred during login',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     return false;
  //   } finally {
  //     _isLoading.value = false;
  //   }
  // }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? password,
    String? avatar,
  }) async {
    try {
      _isLoading.value = true;

      final result = await _authRepository.updateProfile(
        name: name,
        email: email,
        password: password,
        avatar: avatar,
      );

      if (result.isSuccess && result.data != null) {
        _currentUser.value = result.data;

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
        newPassword: newPassword,
      );

      if (result.isSuccess) {
        Get.snackbar(
          'Success',
          'Password reset successfully',
          snackPosition: SnackPosition.TOP,
        );

        // Navigate to login
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

      // Call API logout (optional, continue even if it fails)
      await _authRepository.logout();

      // Clear local data
      await _clearAuthData();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.TOP,
      );

      // Navigate to login
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      // Still clear local data even if API call fails
      await _clearAuthData();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _clearAuthData() async {
    _currentUser.value = null;
    _userRole.value = '';
    _isLoggedIn.value = false;

    // Clear storage
    await _storageService.remove(StorageConstants.authToken);
    await _storageService.remove(StorageConstants.refreshToken);
    await _storageService.remove(StorageConstants.userId);
    await _storageService.remove(StorageConstants.userRole);
    await _storageService.remove(StorageConstants.userEmail);
    await _storageService.remove(StorageConstants.userName);
    await _storageService.remove(StorageConstants.userPhone);
    await _storageService.remove(StorageConstants.userAvatar);
    await _storageService.remove(StorageConstants.userRole + '_raw');
    await _storageService.writeBool(StorageConstants.isLoggedIn, false);
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

    // Update local storage with new user data
    final storageService = Get.find<StorageService>();
    storageService.writeJson(StorageConstants.userId, user.toJson());
    storageService.writeString(StorageConstants.userRole, user.role);
    storageService.writeString(StorageConstants.userEmail, user.email);
    storageService.writeString(StorageConstants.userName, user.name);

    if (user.phone != null) {
      storageService.writeString(StorageConstants.userPhone, user.phone!);
    }

    if (user.avatar != null) {
      storageService.writeString(StorageConstants.userAvatar, user.avatar!);
    }
  }

  // Quick access methods
  String get userName => currentUser?.name ?? '';
  String get userEmail => currentUser?.email ?? '';
  String? get userAvatar => currentUser?.avatar;
  String? get userPhone => currentUser?.phone;

  // Check if user can perform certain actions
  bool canAccessCustomerFeatures() => isCustomer;
  bool canAccessDriverFeatures() => isDriver;
  bool canAccessStoreFeatures() => isStore;
  bool canAccessAdminFeatures() => isAdmin;
}
