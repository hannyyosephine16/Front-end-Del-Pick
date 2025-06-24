import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/data/models/auth/user_model.dart';

class AuthLocalDataSource {
  final StorageService _storageService;

  AuthLocalDataSource(this._storageService);

  Future<void> saveAuthToken(String token) async {
    await _storageService.writeString(StorageConstants.authToken, token);
    await _storageService.writeBool(StorageConstants.isLoggedIn, true);
    await _storageService.writeDateTime(
      StorageConstants.lastLoginTime,
      DateTime.now(),
    );
  }

  Future<String?> getAuthToken() async {
    return _storageService.readString(StorageConstants.authToken);
  }

  Future<void> saveUser(UserModel user) async {
    await _storageService.writeJson(StorageConstants.userId, user.toJson());
    await _storageService.writeString(StorageConstants.userRole, user.role);
    await _storageService.writeString(StorageConstants.userEmail, user.email);
    await _storageService.writeString(StorageConstants.userName, user.name);

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

  Future<UserModel?> getUser() async {
    final userData = _storageService.readJson(StorageConstants.userId);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _storageService.writeString(
        StorageConstants.refreshToken, refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return _storageService.readString(StorageConstants.refreshToken);
  }

  Future<bool> hasValidToken() async {
    final token = await getAuthToken();
    final isLoggedIn = await this.isLoggedIn();
    return token != null && token.isNotEmpty && isLoggedIn;
  }

  Future<void> enableBiometric(bool enabled) async {
    await _storageService.writeBool(StorageConstants.biometricEnabled, enabled);
  }

  Future<bool> isLoggedIn() async {
    return _storageService.readBoolWithDefault(
        StorageConstants.isLoggedIn, false);
  }

  Future<DateTime?> getLastLoginTime() async {
    return _storageService.readDateTime(StorageConstants.lastLoginTime);
  }

  Future<void> clearAuthData() async {
    await _storageService.removeBatch([
      StorageConstants.authToken,
      StorageConstants.refreshToken,
      StorageConstants.userId,
      StorageConstants.userRole,
      StorageConstants.userEmail,
      StorageConstants.userName,
      StorageConstants.userPhone,
      StorageConstants.userAvatar,
      StorageConstants.fcmToken,
      StorageConstants.lastLoginTime,
    ]);
    await _storageService.writeBool(StorageConstants.isLoggedIn, false);
  }

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
    }
  }
}
