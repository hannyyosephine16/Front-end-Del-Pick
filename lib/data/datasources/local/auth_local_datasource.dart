import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/data/models/auth/user_model.dart';

/// ✅ AuthLocalDataSource yang sesuai dengan backend DelPick - COMPLETE FIXED
class AuthLocalDataSource {
  final StorageService _storageService;

  AuthLocalDataSource(this._storageService);

  /// Save auth token (backend DelPick returns single token, no refresh token)
  Future<void> saveAuthToken(String token) async {
    await _storageService.writeString(StorageConstants.authToken, token);
    await _storageService.writeBool(StorageConstants.isLoggedIn, true);
    await _storageService.writeDateTime(
      StorageConstants.lastLoginTime,
      DateTime.now(),
    );
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    return _storageService.readString(StorageConstants.authToken);
  }

  /// Save complete user data (sesuai response backend)
  Future<void> saveUser(UserModel user) async {
    await _storageService.writeJson(
        StorageConstants.userDataKey, user.toJson());
    await _storageService.writeString(StorageConstants.userRole, user.role);
    await _storageService.writeString(StorageConstants.userEmail, user.email);
    await _storageService.writeString(StorageConstants.userName, user.name);
    await _storageService.writeInt(StorageConstants.userId, user.id);

    // Save optional fields
    if (user.phone != null) {
      await _storageService.writeString(
          StorageConstants.userPhone, user.phone!);
    }
    if (user.avatar != null) {
      await _storageService.writeString(
          StorageConstants.userAvatar, user.avatar!);
    }
    if (user.fcmToken != null) {
      await _storageService.writeString(
          StorageConstants.fcmToken, user.fcmToken!);
    }
  }

  /// Get stored user data
  Future<UserModel?> getUser() async {
    final userData = _storageService.readJson(StorageConstants.userDataKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  /// Save driver data (untuk role driver)
  Future<void> saveDriverData(Map<String, dynamic> driverData) async {
    await _storageService.writeJson(StorageConstants.driverDataKey, driverData);

    // Extract driver specific fields for quick access
    if (driverData['license_number'] != null) {
      await _storageService.writeString(
          StorageConstants.driverLicenseNumber, driverData['license_number']);
    }
    if (driverData['vehicle_plate'] != null) {
      await _storageService.writeString(
          StorageConstants.driverVehicleNumber, driverData['vehicle_plate']);
    }
    if (driverData['status'] != null) {
      await _storageService.writeString(
          StorageConstants.driverStatus, driverData['status']);
    }
    if (driverData['latitude'] != null) {
      await _storageService.writeDouble(StorageConstants.driverLatitude,
          (driverData['latitude'] as num).toDouble());
    }
    if (driverData['longitude'] != null) {
      await _storageService.writeDouble(StorageConstants.driverLongitude,
          (driverData['longitude'] as num).toDouble());
    }
    if (driverData['rating'] != null) {
      await _storageService.writeDouble(
          'driver_rating', (driverData['rating'] as num).toDouble());
    }
    if (driverData['reviews_count'] != null) {
      await _storageService.writeInt(
          'driver_reviews_count', driverData['reviews_count']);
    }
  }

  /// Get driver data
  Future<Map<String, dynamic>?> getDriverData() async {
    return _storageService.readJson(StorageConstants.driverDataKey);
  }

  /// Save store data (untuk role store)
  Future<void> saveStoreData(Map<String, dynamic> storeData) async {
    await _storageService.writeJson(StorageConstants.storeDataKey, storeData);

    // Extract store specific fields for quick access
    if (storeData['id'] != null) {
      await _storageService.writeInt(StorageConstants.storeId, storeData['id']);
    }
    if (storeData['name'] != null) {
      await _storageService.writeString(
          StorageConstants.storeName, storeData['name']);
    }
    if (storeData['status'] != null) {
      await _storageService.writeString(
          StorageConstants.storeStatus, storeData['status']);
    }
    if (storeData['address'] != null) {
      await _storageService.writeString(
          StorageConstants.storeAddress, storeData['address']);
    }
    if (storeData['description'] != null) {
      await _storageService.writeString(
          StorageConstants.storeDescription, storeData['description']);
    }
    if (storeData['image_url'] != null) {
      await _storageService.writeString(
          StorageConstants.storeImageUrl, storeData['image_url']);
    }
    if (storeData['phone'] != null) {
      await _storageService.writeString(
          StorageConstants.storePhone, storeData['phone']);
    }
    if (storeData['open_time'] != null) {
      await _storageService.writeString(
          StorageConstants.storeOpenTime, storeData['open_time']);
    }
    if (storeData['close_time'] != null) {
      await _storageService.writeString(
          StorageConstants.storeCloseTime, storeData['close_time']);
    }
    if (storeData['latitude'] != null) {
      await _storageService.writeDouble(StorageConstants.storeLatitude,
          (storeData['latitude'] as num).toDouble());
    }
    if (storeData['longitude'] != null) {
      await _storageService.writeDouble(StorageConstants.storeLongitude,
          (storeData['longitude'] as num).toDouble());
    }
    if (storeData['rating'] != null) {
      await _storageService.writeDouble(StorageConstants.storeRating,
          (storeData['rating'] as num).toDouble());
    }
    if (storeData['total_products'] != null) {
      await _storageService.writeInt(
          StorageConstants.storeTotalProducts, storeData['total_products']);
    }
    if (storeData['review_count'] != null) {
      await _storageService.writeInt(
          'store_review_count', storeData['review_count']);
    }
  }

  /// Get store data
  Future<Map<String, dynamic>?> getStoreData() async {
    return _storageService.readJson(StorageConstants.storeDataKey);
  }

  /// Check if user has valid authentication
  Future<bool> hasValidToken() async {
    final token = await getAuthToken();
    final isLoggedIn = await this.isLoggedIn();
    return token != null && token.isNotEmpty && isLoggedIn;
  }

  /// Check login status
  Future<bool> isLoggedIn() async {
    return _storageService.readBoolWithDefault(
        StorageConstants.isLoggedIn, false);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return _storageService.readString(StorageConstants.userRole);
  }

  /// Get user ID
  Future<int?> getUserId() async {
    return _storageService.readInt(StorageConstants.userId);
  }

  /// Get last login time
  Future<DateTime?> getLastLoginTime() async {
    return _storageService.readDateTime(StorageConstants.lastLoginTime);
  }

  /// Save FCM token for push notifications
  Future<void> saveFcmToken(String fcmToken) async {
    await _storageService.writeString(StorageConstants.fcmToken, fcmToken);

    // Update current user data with new FCM token
    final currentUser = await getUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(fcmToken: fcmToken);
      await saveUser(updatedUser);
    }
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    return _storageService.readString(StorageConstants.fcmToken);
  }

  /// Enable/disable biometric authentication
  Future<void> enableBiometric(bool enabled) async {
    await _storageService.writeBool(StorageConstants.biometricEnabled, enabled);
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    return _storageService.readBoolWithDefault(
        StorageConstants.biometricEnabled, false);
  }

  /// Save remember me preference
  Future<void> setRememberMe(bool remember) async {
    await _storageService.writeBool(StorageConstants.rememberMe, remember);
  }

  /// Check remember me preference
  Future<bool> shouldRememberMe() async {
    return _storageService.readBoolWithDefault(
        StorageConstants.rememberMe, false);
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    await _storageService.removeBatch([
      StorageConstants.authToken,
      StorageConstants.userDataKey,
      StorageConstants.driverDataKey,
      StorageConstants.storeDataKey,
      StorageConstants.userId,
      StorageConstants.userRole,
      StorageConstants.userEmail,
      StorageConstants.userName,
      StorageConstants.userPhone,
      StorageConstants.userAvatar,
      StorageConstants.fcmToken,
      StorageConstants.lastLoginTime,
      StorageConstants.rememberMe,
      StorageConstants.driverStatus,
      StorageConstants.driverVehicleNumber,
      StorageConstants.driverLicenseNumber,
      StorageConstants.driverLatitude,
      StorageConstants.driverLongitude,
      StorageConstants.storeId,
      StorageConstants.storeName,
      StorageConstants.storeStatus,
      StorageConstants.storeAddress,
      StorageConstants.storeDescription,
      StorageConstants.storeImageUrl,
      StorageConstants.storePhone,
      StorageConstants.storeOpenTime,
      StorageConstants.storeCloseTime,
      StorageConstants.storeLatitude,
      StorageConstants.storeLongitude,
      StorageConstants.storeRating,
      StorageConstants.storeTotalProducts,
      'driver_rating',
      'driver_reviews_count',
      'store_review_count',
    ]);
    await _storageService.writeBool(StorageConstants.isLoggedIn, false);
  }

  /// Update user profile locally (setelah API update berhasil)
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? fcmToken,
  }) async {
    final currentUser = await getUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        email: email ?? currentUser.email,
        phone: phone ?? currentUser.phone,
        avatar: avatar ?? currentUser.avatar,
        fcmToken: fcmToken ?? currentUser.fcmToken,
      );
      await saveUser(updatedUser);

      // Update individual fields for quick access
      if (name != null)
        await _storageService.writeString(StorageConstants.userName, name);
      if (email != null)
        await _storageService.writeString(StorageConstants.userEmail, email);
      if (phone != null)
        await _storageService.writeString(StorageConstants.userPhone, phone);
      if (avatar != null)
        await _storageService.writeString(StorageConstants.userAvatar, avatar);
      if (fcmToken != null)
        await _storageService.writeString(StorageConstants.fcmToken, fcmToken);
    }
  }

  /// Save complete login response data (sesuai dengan response backend DelPick)
  Future<void> saveLoginResponse(Map<String, dynamic> loginResponse) async {
    final token = loginResponse['token'] as String?;
    final userData = loginResponse['user'] as Map<String, dynamic>?;
    final driverData = loginResponse['driver'] as Map<String, dynamic>?;
    final storeData = loginResponse['store'] as Map<String, dynamic>?;

    if (token != null) {
      await saveAuthToken(token);
    }

    if (userData != null) {
      final user = UserModel.fromJson(userData);
      await saveUser(user);
    }

    // Save role-specific data
    if (driverData != null) {
      await saveDriverData(driverData);
    }

    if (storeData != null) {
      await saveStoreData(storeData);
    }
  }

  /// Get complete login session data
  Future<Map<String, dynamic>?> getLoginSession() async {
    final token = await getAuthToken();
    final user = await getUser();
    final isLoggedIn = await this.isLoggedIn();

    if (!isLoggedIn || token == null || user == null) {
      return null;
    }

    final session = {
      'token': token,
      'user': user.toJson(),
      'isLoggedIn': isLoggedIn,
      'lastLoginTime': (await getLastLoginTime())?.toIso8601String(),
    };

    // Add role-specific data
    final role = user.role;
    if (role == 'driver') {
      final driverData = await getDriverData();
      if (driverData != null) {
        session['driver'] = driverData;
      }
    } else if (role == 'store') {
      final storeData = await getStoreData();
      if (storeData != null) {
        session['store'] = storeData;
      }
    }

    return session;
  }

  /// Update driver location (untuk real-time tracking)
  Future<void> updateDriverLocation(double latitude, double longitude) async {
    await _storageService.writeDouble(
        StorageConstants.driverLatitude, latitude);
    await _storageService.writeDouble(
        StorageConstants.driverLongitude, longitude);

    // Update in driver data as well
    final driverData = await getDriverData();
    if (driverData != null) {
      driverData['latitude'] = latitude;
      driverData['longitude'] = longitude;
      await _storageService.writeJson(
          StorageConstants.driverDataKey, driverData);
    }
  }

  /// Get driver location
  Future<Map<String, double>?> getDriverLocation() async {
    final lat = _storageService.readDouble(StorageConstants.driverLatitude);
    final lng = _storageService.readDouble(StorageConstants.driverLongitude);

    if (lat != null && lng != null) {
      return {'latitude': lat, 'longitude': lng};
    }
    return null;
  }

  /// Update driver status (active, inactive, busy)
  Future<void> updateDriverStatus(String status) async {
    await _storageService.writeString(StorageConstants.driverStatus, status);

    // Update in driver data as well
    final driverData = await getDriverData();
    if (driverData != null) {
      driverData['status'] = status;
      await _storageService.writeJson(
          StorageConstants.driverDataKey, driverData);
    }
  }

  /// Get driver status
  Future<String?> getDriverStatus() async {
    return _storageService.readString(StorageConstants.driverStatus);
  }

  /// Update store status (active, inactive)
  Future<void> updateStoreStatus(String status) async {
    await _storageService.writeString(StorageConstants.storeStatus, status);

    // Update in store data as well
    final storeData = await getStoreData();
    if (storeData != null) {
      storeData['status'] = status;
      await _storageService.writeJson(StorageConstants.storeDataKey, storeData);
    }
  }

  /// Get store status
  Future<String?> getStoreStatus() async {
    return _storageService.readString(StorageConstants.storeStatus);
  }

  /// Check if current session is valid (not expired)
  Future<bool> isSessionValid() async {
    final isLoggedIn = await this.isLoggedIn();
    final token = await getAuthToken();
    final lastLoginTime = await getLastLoginTime();

    if (!isLoggedIn || token == null || lastLoginTime == null) {
      return false;
    }

    // Check if session is older than 7 days (backend JWT expires in 7 days)
    final now = DateTime.now();
    final difference = now.difference(lastLoginTime);
    if (difference.inDays >= 7) {
      await clearAuthData();
      return false;
    }

    return true;
  }

  /// Refresh session timestamp
  Future<void> refreshSession() async {
    if (await isLoggedIn()) {
      await _storageService.writeDateTime(
        StorageConstants.lastLoginTime,
        DateTime.now(),
      );
    }
  }

  /// Get user's role-specific data based on their role
  Future<Map<String, dynamic>?> getRoleSpecificData() async {
    final user = await getUser();
    if (user == null) return null;

    switch (user.role) {
      case 'driver':
        return await getDriverData();
      case 'store':
        return await getStoreData();
      case 'customer':
      default:
        return null; // Customer doesn't have additional data
    }
  }

  /// Check if user has completed their profile setup
  Future<bool> hasCompletedProfileSetup() async {
    final user = await getUser();
    if (user == null) return false;

    // Basic profile completion check
    if (user.name.isEmpty || user.email.isEmpty) {
      return false;
    }

    // Role-specific completion check
    switch (user.role) {
      case 'driver':
        final driverData = await getDriverData();
        return driverData != null &&
            driverData['license_number'] != null &&
            driverData['vehicle_plate'] != null;

      case 'store':
        final storeData = await getStoreData();
        return storeData != null &&
            storeData['name'] != null &&
            storeData['address'] != null &&
            storeData['phone'] != null &&
            storeData['latitude'] != null &&
            storeData['longitude'] != null;

      case 'customer':
      default:
        return user.phone != null && user.phone!.isNotEmpty;
    }
  }

  /// Save temporary registration data (for multi-step registration)
  Future<void> saveTemporaryRegistrationData(Map<String, dynamic> data) async {
    await _storageService.writeJson('temp_registration_data', data);
  }

  /// Get temporary registration data
  Future<Map<String, dynamic>?> getTemporaryRegistrationData() async {
    return _storageService.readJson('temp_registration_data');
  }

  /// Clear temporary registration data
  Future<void> clearTemporaryRegistrationData() async {
    await _storageService.remove('temp_registration_data');
  }

  /// Save password reset token (if needed for offline functionality)
  Future<void> savePasswordResetToken(String token) async {
    await _storageService.writeString('password_reset_token', token);
    await _storageService.writeDateTime(
      'password_reset_token_expiry',
      DateTime.now().add(const Duration(hours: 1)),
    );
  }

  /// Get password reset token
  Future<String?> getPasswordResetToken() async {
    final token = _storageService.readString('password_reset_token');
    final expiry = _storageService.readDateTime('password_reset_token_expiry');

    if (token != null && expiry != null && DateTime.now().isBefore(expiry)) {
      return token;
    }

    // Clear expired token
    await _storageService
        .removeBatch(['password_reset_token', 'password_reset_token_expiry']);
    return null;
  }

  /// Save email verification status
  Future<void> saveEmailVerificationStatus(bool isVerified) async {
    await _storageService.writeBool('email_verified', isVerified);
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    return _storageService.readBoolWithDefault('email_verified', false);
  }
}
