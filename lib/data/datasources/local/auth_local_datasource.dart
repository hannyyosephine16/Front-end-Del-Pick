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
    await _storageService.writeString(
        StorageConstants.userId, user.id.toString());
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
  }

  Future<UserModel?> getUser() async {
    final userId = _storageService.readString(StorageConstants.userId);
    final userRole = _storageService.readString(StorageConstants.userRole);
    final userEmail = _storageService.readString(StorageConstants.userEmail);
    final userName = _storageService.readString(StorageConstants.userName);

    if (userId != null &&
        userRole != null &&
        userEmail != null &&
        userName != null) {
      return UserModel(
        id: int.parse(userId),
        name: userName,
        email: userEmail,
        role: userRole,
        phone: _storageService.readString(StorageConstants.userPhone),
        avatar: _storageService.readString(StorageConstants.userAvatar),
      );
    }
    return null;
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _storageService.writeString(
      StorageConstants.refreshToken,
      refreshToken,
    );
  }

  Future<String?> getRefreshToken() async {
    return _storageService.readString(StorageConstants.refreshToken);
  }

  // Add token validation
  Future<bool> hasValidToken() async {
    final token = await getAuthToken();
    final isLoggedIn = await this.isLoggedIn();

    return token != null && token.isNotEmpty && isLoggedIn;
  }

// Add biometric auth
  Future<void> enableBiometric(bool enabled) async {
    await _storageService.writeBool(StorageConstants.biometricEnabled, enabled);
  }

// Add secure token storage
  Future<void> saveAuthTokenSecure(String token) async {
    // Use flutter_secure_storage for production
    await _storageService.writeString(StorageConstants.authToken, token);
  }

  Future<bool> isLoggedIn() async {
    return _storageService.readBoolWithDefault(
      StorageConstants.isLoggedIn,
      false,
    );
  }

  Future<DateTime?> getLastLoginTime() async {
    return _storageService.readDateTime(StorageConstants.lastLoginTime);
  }

  Future<void> clearAuthData() async {
    await _storageService.remove(StorageConstants.authToken);
    await _storageService.remove(StorageConstants.refreshToken);
    await _storageService.remove(StorageConstants.userId);
    await _storageService.remove(StorageConstants.userRole);
    await _storageService.remove(StorageConstants.userEmail);
    await _storageService.remove(StorageConstants.userName);
    await _storageService.remove(StorageConstants.userPhone);
    await _storageService.remove(StorageConstants.userAvatar);
    await _storageService.writeBool(StorageConstants.isLoggedIn, false);
    await _storageService.remove(StorageConstants.lastLoginTime);
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    final currentUser = await getUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        email: email ?? currentUser.email,
        phone: phone ?? currentUser.phone,
        avatar: avatar ?? currentUser.avatar,
      );
      await saveUser(updatedUser);
    }
  }
}
