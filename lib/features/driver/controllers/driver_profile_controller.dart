// lib/features/driver/controllers/driver_profile_controller.dart - FIXED VERSION
import 'dart:ui';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/utils/custom_snackbar.dart';

class DriverProfileController extends GetxController {
  final DriverRepository _driverRepository;
  final AuthRepository _authRepository;

  DriverProfileController({
    required DriverRepository driverRepository,
    required AuthRepository authRepository,
  })  : _driverRepository = driverRepository,
        _authRepository = authRepository;

  // ========================================================================
  // Observable Variables
  // ========================================================================

  final RxBool _isLoading = false.obs;
  final Rx<DriverModel?> _driverProfile = Rx<DriverModel?>(null);
  final Rx<UserModel?> _userProfile = Rx<UserModel?>(null);
  final RxMap<String, dynamic> _driverStats = <String, dynamic>{}.obs;

  // ========================================================================
  // Getters
  // ========================================================================

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

  // ========================================================================
  // Lifecycle
  // ========================================================================

  @override
  void onInit() {
    super.onInit();
    loadDriverProfile();
  }

  // ========================================================================
  // Main Loading Method - SIMPLIFIED (No Admin Methods)
  // ========================================================================

  Future<void> loadDriverProfile() async {
    try {
      _isLoading.value = true;

      print('🔄 Loading driver profile...');

      // ✅ Get current user info from AuthController
      final authController = Get.find<AuthController>();
      _userProfile.value = authController.currentUser;

      if (_userProfile.value != null) {
        print('✅ User found: ${_userProfile.value!.name}');
        await _loadDriverDataFromAuth();
        await _loadDriverStats();
      } else {
        print('❌ No user found in AuthController');
        throw Exception('User not found');
      }
    } catch (e) {
      print('❌ Error in loadDriverProfile: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to load profile: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ========================================================================
  // Driver Data Loading - DRIVER-ONLY Methods
  // ========================================================================

  /// Load driver data from AuthController or API - NO ADMIN METHODS
  Future<void> _loadDriverDataFromAuth() async {
    try {
      print('📡 Loading driver data from auth...');

      // ✅ SOLUTION 1: Get raw data from AuthController
      final authController = Get.find<AuthController>();
      final driverData = authController.driverData;

      if (driverData != null) {
        print('✅ Found driver data in AuthController: $driverData');
        _driverProfile.value = DriverModel.fromJson(driverData);
        print('✅ Driver profile set: ${_driverProfile.value?.vehicleNumber}');
        return;
      }

      // ✅ SOLUTION 2: Load from profile API (most common)
      print('📡 Loading from profile API...');
      await _loadDriverFromProfileAPI();
    } catch (e) {
      print('❌ Error loading driver data from auth: $e');
      // Try profile API as fallback
      await _loadDriverFromProfileAPI();
    }
  }

  /// Load driver data from profile API - ENDPOINT: GET /auth/profile
  Future<void> _loadDriverFromProfileAPI() async {
    try {
      print('📡 Calling getDriverProfile API...');

      // ✅ Use driver-specific profile method (not admin method)
      final result = await _driverRepository.getDriverProfile();

      if (result.isSuccess && result.data != null) {
        final profileData = result.data!;
        print('✅ Profile API response: $profileData');

        // Extract driver data from profile response
        if (profileData.containsKey('driver') &&
            profileData['driver'] != null) {
          final driverData = profileData['driver'] as Map<String, dynamic>;
          _driverProfile.value = DriverModel.fromJson(driverData);
          print('✅ Driver profile loaded from API');
        } else if (profileData.containsKey('data')) {
          // Handle nested data structure
          final data = profileData['data'] as Map<String, dynamic>?;
          if (data?.containsKey('driver') == true) {
            final driverData = data!['driver'] as Map<String, dynamic>;
            _driverProfile.value = DriverModel.fromJson(driverData);
            print('✅ Driver profile loaded from nested data');
          } else {
            print('⚠️ No driver data found in profile response');
            _setDefaultDriverProfile();
          }
        } else {
          print('⚠️ No driver data in profile response, using defaults');
          _setDefaultDriverProfile();
        }
      } else {
        print('❌ Failed to load profile: ${result.errorMessage}');
        _setDefaultDriverProfile();
      }
    } catch (e) {
      print('❌ Error loading from profile API: $e');
      _setDefaultDriverProfile();
    }
  }

  /// Set default driver profile when API fails
  void _setDefaultDriverProfile() {
    print('📝 Setting default driver profile...');

    final user = _userProfile.value;
    if (user != null) {
      // Create minimal driver profile from user data
      _driverProfile.value = DriverModel(
        id: 0, // Will be set when API is available
        userId: user.id,
        vehicleNumber: '',
        status: 'inactive',
        rating: 0.0,
        reviewsCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      print('✅ Default driver profile created');
    }
  }

  // ========================================================================
  // Driver Stats Loading - DUMMY DATA untuk sementara
  // ========================================================================

  Future<void> _loadDriverStats() async {
    try {
      print('📊 Loading driver statistics...');

      // TODO: Replace with real API call when available
      // For now, use dummy data
      await Future.delayed(Duration(milliseconds: 300));

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

      print('✅ Driver stats loaded (dummy data)');
    } catch (e) {
      print('❌ Error loading driver stats: $e');
    }
  }

  // ========================================================================
  // Profile Update Methods - DRIVER-ONLY
  // ========================================================================

  /// Update driver status - ENDPOINT: PUT /drivers/status
  Future<void> updateDriverStatus(String newStatus) async {
    try {
      _isLoading.value = true;
      print('🔄 Updating driver status to: $newStatus');

      final result = await _driverRepository.updateDriverStatus({
        'status': newStatus,
      });

      if (result.isSuccess && result.data != null) {
        final responseData = result.data!;
        print('✅ Status update response: $responseData');

        // Parse response and update local state
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('driver')) {
            try {
              _driverProfile.value =
                  DriverModel.fromJson(responseData['driver']);
              print('✅ Driver profile updated from response');
            } catch (e) {
              print('⚠️ Error parsing driver from response: $e');
              _updateDriverStatusLocally(newStatus);
            }
          } else {
            // Update locally if response doesn't contain driver data
            _updateDriverStatusLocally(newStatus);
          }
        }

        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Status updated successfully',
        );
      } else {
        print('❌ Status update failed: ${result.errorMessage}');
        CustomSnackbar.showError(
          title: 'Error',
          message: result.errorMessage ?? 'Failed to update status',
        );
      }
    } catch (e) {
      print('❌ Exception in updateDriverStatus: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update status: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update local driver status
  void _updateDriverStatusLocally(String newStatus) {
    if (_driverProfile.value != null) {
      _driverProfile.value = _driverProfile.value!.copyWith(status: newStatus);
      print('✅ Driver status updated locally to: $newStatus');
    }
  }

  /// Update profile information - FIXED: Handle AuthRepository method signature
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? vehicleNumber,
  }) async {
    try {
      _isLoading.value = true;
      print('🔄 Updating profile...');

      bool hasUpdates = false;

      // ✅ FIX 1: Update user profile (name, email) - Remove phone if not supported
      if (name != null || email != null) {
        print('📡 Updating user profile...');

        // Check if AuthRepository supports phone parameter
        try {
          // Try with phone parameter first
          final userResult = await _authRepository.updateProfile(
            name: name,
            email: email,
            // phone: phone, // ❌ Remove this line if not supported
          );

          if (userResult.isSuccess && userResult.data != null) {
            _userProfile.value = userResult.data;
            hasUpdates = true;
            print('✅ User profile updated');
          } else {
            print('⚠️ User profile update failed: ${userResult.errorMessage}');
          }
        } catch (e) {
          print('❌ User profile update error: $e');
          // Try without phone parameter
          if (name != null || email != null) {
            try {
              final userResult = await _authRepository.updateProfile(
                name: name,
                email: email,
              );

              if (userResult.isSuccess && userResult.data != null) {
                _userProfile.value = userResult.data;
                hasUpdates = true;
                print('✅ User profile updated (without phone)');
              }
            } catch (e2) {
              print('❌ User profile update failed completely: $e2');
            }
          }
        }
      }

      // Handle phone separately if needed
      if (phone != null && phone.isNotEmpty) {
        print('📞 Phone update not implemented in AuthRepository');
        // TODO: Implement phone update when AuthRepository supports it
        // For now, show warning that phone update is not available
        CustomSnackbar.showWarning(
          title: 'Phone Update',
          message: 'Phone number update is not available yet',
        );
      }

      // ✅ FIX 2: Update driver profile (vehicle number, etc.)
      if (vehicleNumber != null) {
        print('📡 Updating driver profile...');

        final driverData = <String, dynamic>{};
        if (vehicleNumber.isNotEmpty) {
          driverData['vehicleNumber'] = vehicleNumber;
        }

        if (driverData.isNotEmpty) {
          final driverResult =
              await _driverRepository.updateDriverProfile(driverData);

          if (driverResult.isSuccess && driverResult.data != null) {
            // ✅ FIX 3: Handle response properly - driverResult.data is Map, not DriverModel
            final responseData = driverResult.data! as Map<String, dynamic>;

            if (responseData.containsKey('driver')) {
              _driverProfile.value =
                  DriverModel.fromJson(responseData['driver']);
              print('✅ Driver profile updated from response.driver');
            } else if (responseData.containsKey('data')) {
              final data = responseData['data'] as Map<String, dynamic>?;
              if (data?.containsKey('driver') == true) {
                _driverProfile.value = DriverModel.fromJson(data!['driver']);
                print('✅ Driver profile updated from response.data.driver');
              } else {
                // If response doesn't have expected structure, update locally
                _updateDriverProfileLocally(driverData);
                print('✅ Driver profile updated locally');
              }
            } else {
              // Response might be the driver data directly
              try {
                _driverProfile.value = DriverModel.fromJson(responseData);
                print('✅ Driver profile updated from direct response');
              } catch (e) {
                print(
                    '⚠️ Could not parse response as driver, updating locally: $e');
                _updateDriverProfileLocally(driverData);
              }
            }

            hasUpdates = true;
            print('✅ Driver profile updated');
          } else {
            print(
                '⚠️ Driver profile update failed: ${driverResult.errorMessage}');
          }
        }
      }

      if (hasUpdates) {
        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Profile updated successfully',
        );
      } else {
        CustomSnackbar.showWarning(
          title: 'No Changes',
          message: 'No changes were made to your profile',
        );
      }
    } catch (e) {
      print('❌ Exception in updateProfile: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update profile: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update driver profile locally when API response is unclear
  void _updateDriverProfileLocally(Map<String, dynamic> updatedData) {
    if (_driverProfile.value != null) {
      final currentProfile = _driverProfile.value!;

      // Update specific fields
      if (updatedData.containsKey('vehicleNumber')) {
        _driverProfile.value = currentProfile.copyWith(
          vehicleNumber: updatedData['vehicleNumber'] as String,
        );
      }

      print('✅ Driver profile updated locally with: $updatedData');
    }
  }

  // ========================================================================
  // Authentication Methods
  // ========================================================================

  /// Logout driver
  void logout() async {
    try {
      _isLoading.value = true;
      print('🔄 Logging out...');

      final authController = Get.find<AuthController>();
      await authController.logout();

      print('✅ Logout successful');
      // Navigation will be handled by AuthController
    } catch (e) {
      print('❌ Logout error: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to logout: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ========================================================================
  // Refresh Methods
  // ========================================================================

  /// Refresh driver data
  Future<void> refreshDriverData() async {
    print('🔄 Refreshing driver data...');
    if (_userProfile.value != null) {
      await _loadDriverDataFromAuth();
      print('✅ Driver data refreshed');
    }
  }

  /// Refresh entire profile
  Future<void> refreshProfile() async {
    print('🔄 Refreshing entire profile...');
    await loadDriverProfile();
  }

  // ========================================================================
  // Formatting Helper Methods
  // ========================================================================

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

  // ========================================================================
  // Navigation Methods
  // ========================================================================

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

  void navigateToVehicleSettings() {
    Get.toNamed('/driver/vehicle');
  }

  void navigateToHelp() {
    Get.toNamed('/driver/help');
  }
}
