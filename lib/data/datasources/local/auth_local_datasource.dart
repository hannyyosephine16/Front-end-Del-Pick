import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/data/models/auth/user_model.dart';

/// ✅ AuthLocalDataSource yang sesuai dengan backend DelPick
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
  }

  /// Get driver data
  Future<Map<String, dynamic>?> getDriverData() async {
    return _storageService.readJson(StorageConstants.driverDataKey);
  }

  /// Save store data (untuk role store)
  Future<void> saveStoreData(Map<String, dynamic> storeData) async {
    await _storageService.writeJson(StorageConstants.storeDataKey, storeData);
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

  /// Get complete auth data for API headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  /// Check if token is expired (basic check)
  Future<bool> isTokenExpired() async {
    final lastLogin = await getLastLoginTime();
    if (lastLogin == null) return true;

    // Token expires after 7 days (sesuai backend: expiresIn: '7d')
    final expiredTime = lastLogin.add(const Duration(days: 7));
    return DateTime.now().isAfter(expiredTime);
  }

  /// Save temporary data for offline usage
  Future<void> saveOfflineData(String key, dynamic data) async {
    await _storageService.writeJson('offline_$key', data);
  }

  /// Get temporary offline data
  Future<dynamic> getOfflineData(String key) async {
    return _storageService.readJson('offline_$key');
  }

  /// Clear temporary offline data
  Future<void> clearOfflineData(String key) async {
    await _storageService.remove('offline_$key');
  }

  /// Get user session info
  Future<Map<String, dynamic>> getSessionInfo() async {
    final user = await getUser();
    final lastLogin = await getLastLoginTime();
    final isExpired = await isTokenExpired();

    return {
      'isLoggedIn': await isLoggedIn(),
      'hasValidToken': await hasValidToken(),
      'isTokenExpired': isExpired,
      'userId': user?.id,
      'userRole': user?.role,
      'userName': user?.name,
      'userEmail': user?.email,
      'lastLogin': lastLogin?.toIso8601String(),
      'biometricEnabled': await isBiometricEnabled(),
      'rememberMe': await shouldRememberMe(),
    };
  }
}
