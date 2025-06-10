import 'dart:ui';

import 'package:get/get.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class DriverProfileController extends GetxController {
  final DriverRepository _driverRepository;
  final AuthRepository _authRepository;

  DriverProfileController({
    required DriverRepository driverRepository,
    required AuthRepository authRepository,
  })  : _driverRepository = driverRepository,
        _authRepository = authRepository;

  // Observable variables
  final RxBool _isLoading = false.obs;
  final Rx<DriverModel?> _driverProfile = Rx<DriverModel?>(null);
  final Rx<UserModel?> _userProfile = Rx<UserModel?>(null);
  final RxMap<String, dynamic> _driverStats = <String, dynamic>{}.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  DriverModel? get driverProfile => _driverProfile.value;
  UserModel? get userProfile => _userProfile.value;
  Map<String, dynamic> get driverStats => _driverStats;

  // Computed properties
  String get driverName => userProfile?.name ?? 'Driver';
  String get driverEmail => userProfile?.email ?? '';
  String get driverPhone => userProfile?.phone ?? '';
  String get driverStatus => driverProfile?.status ?? 'inactive';
  String get vehicleNumber => driverProfile?.vehicleNumber ?? '';
  double get rating => driverProfile?.rating ?? 0.0;
  int get reviewsCount => driverProfile?.reviewsCount ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadDriverProfile();
  }

  Future<void> loadDriverProfile() async {
    try {
      _isLoading.value = true;

      // ✅ FIXED: Get current user info from AuthController
      final authController = Get.find<AuthController>();
      _userProfile.value = authController.currentUser;

      // ✅ FIXED: Try to extract driver data from current user first
      if (_userProfile.value != null) {
        await _extractDriverDataFromUser(_userProfile.value!);
        await _loadDriverStats();
      }
    } catch (e) {
      print('Error in loadDriverProfile: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ✅ NEW: Extract driver data from AuthController raw data
  Future<void> _extractDriverDataFromUser(UserModel user) async {
    try {
      print('Extracting driver data for user: ${user.name}');

      // ✅ SOLUTION: Get raw data from AuthController
      final authController = Get.find<AuthController>();
      final driverData = authController.driverData;

      if (driverData != null) {
        print('Found driver data in AuthController: $driverData');

        // Create DriverModel from raw data
        _driverProfile.value = DriverModel.fromJson(driverData);
        print(
            'Driver profile set successfully: ${_driverProfile.value?.vehicleNumber}');
        return;
      }

      // ✅ FALLBACK: If no raw driver data, try to get from API
      print('No raw driver data found, trying API...');
      await _loadDriverDataFromAPI(user.id);
    } catch (e) {
      print('Error extracting driver data: $e');
      // Final fallback: try API
      await _loadDriverDataFromAPI(user.id);
    }
  }

  // ✅ MODIFIED: Fallback method to load from API
  Future<void> _loadDriverDataFromAPI(int userId) async {
    try {
      print('Loading driver data from API for userId: $userId');

      // Try to get driver profile directly first
      final profileResult = await _authRepository.getProfile();

      if (profileResult.isSuccess && profileResult.data != null) {
        final userData = profileResult.data!.toJson();

        if (userData.containsKey('driver') && userData['driver'] != null) {
          final driverData = userData['driver'] as Map<String, dynamic>;
          _driverProfile.value = DriverModel.fromJson(driverData);
          print('Driver profile loaded from getProfile API');
          return;
        }
      }

      // Fallback: Try getAllDrivers
      final result = await _driverRepository.getAllDrivers();

      if (result.isSuccess && result.data != null) {
        final drivers = result.data!.data;
        final driver = drivers.firstWhereOrNull(
          (driver) => driver.userId == userId,
        );

        if (driver != null) {
          _driverProfile.value = driver;
          print('Driver profile loaded from getAllDrivers');
        } else {
          print('Driver not found in getAllDrivers for userId: $userId');
        }
      } else {
        print('Failed to load from getAllDrivers: ${result.message}');
      }
    } catch (e) {
      print('Error loading driver data from API: $e');
    }
  }

  Future<void> _loadDriverStats() async {
    try {
      // Simulate loading driver statistics
      _driverStats.value = {
        'totalDeliveries': 156,
        'totalEarnings': 2500000,
        'monthlyDeliveries': 42,
        'monthlyEarnings': 750000,
        'averageRating': rating,
        'completionRate': 98.5,
        'onTimeRate': 96.2,
        'totalDistance': 1245.6,
      };
    } catch (e) {
      print('Error loading driver stats: $e');
    }
  }

  // ✅ FIXED: updateDriverStatus method
  Future<void> updateDriverStatus(String newStatus) async {
    try {
      _isLoading.value = true;

      final result = await _driverRepository.updateDriverStatus({
        'status': newStatus,
      });

      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('driver')) {
            try {
              _driverProfile.value =
                  DriverModel.fromJson(responseData['driver']);
            } catch (e) {
              print('Error parsing driver from response: $e');
              _updateDriverStatusLocally(newStatus);
            }
          } else if (responseData.containsKey('id') &&
              responseData.containsKey('status')) {
            try {
              _driverProfile.value = DriverModel.fromJson(responseData);
            } catch (e) {
              print('Error parsing driver response: $e');
              _updateDriverStatusLocally(newStatus);
            }
          } else {
            _updateDriverStatusLocally(newStatus);
          }
        }

        Get.snackbar(
          'Success',
          'Status updated successfully',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to update status',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _updateDriverStatusLocally(String newStatus) {
    if (_driverProfile.value != null) {
      _driverProfile.value = _driverProfile.value!.copyWith(status: newStatus);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? vehicleNumber,
  }) async {
    try {
      _isLoading.value = true;

      // Update user profile
      if (name != null || email != null) {
        final userResult = await _authRepository.updateProfile(
          name: name,
          email: email,
        );

        if (userResult.isSuccess && userResult.data != null) {
          _userProfile.value = userResult.data;
        }
      }

      // Update driver profile
      if (vehicleNumber != null) {
        final driverData = <String, dynamic>{};
        if (vehicleNumber.isNotEmpty) {
          driverData['vehicleNumber'] = vehicleNumber;
        }

        if (driverData.isNotEmpty) {
          final driverResult =
              await _driverRepository.updateDriverProfile(driverData);

          if (driverResult.isSuccess && driverResult.data != null) {
            _driverProfile.value = driverResult.data;
          }
        }
      }

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void logout() async {
    try {
      _isLoading.value = true;

      final authController = Get.find<AuthController>();
      await authController.logout();

      // Navigation will be handled by AuthController
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ✅ NEW: Method to refresh driver data
  Future<void> refreshDriverData() async {
    if (_userProfile.value != null) {
      await _extractDriverDataFromUser(_userProfile.value!);
    }
  }

  // Helper methods for formatting
  String get formattedRating => rating.toStringAsFixed(1);

  String get formattedTotalEarnings {
    final earnings = driverStats['totalEarnings'] ?? 0;
    return 'Rp ${earnings.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get formattedMonthlyEarnings {
    final earnings = driverStats['monthlyEarnings'] ?? 0;
    return 'Rp ${earnings.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get statusDisplayName {
    switch (driverStatus) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'busy':
        return 'Sibuk';
      case 'offline':
        return 'Offline';
      default:
        return driverStatus;
    }
  }

  Color get statusColor {
    switch (driverStatus) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'busy':
        return const Color(0xFFFF9800);
      case 'inactive':
      case 'offline':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Navigation methods
  void navigateToEditProfile() {
    Get.toNamed(Routes.EDIT_PROFILE);
  }

  void navigateToSettings() {
    Get.toNamed('/driver/settings');
  }

  void navigateToEarnings() {
    Get.toNamed('/driver/earnings');
  }

  void navigateToOrderHistory() {
    Get.toNamed('/driver/orders');
  }
}
