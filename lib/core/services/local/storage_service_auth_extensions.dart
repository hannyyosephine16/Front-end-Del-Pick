// lib/core/services/local/storage_service_auth_extensions.dart
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';

/// Extension untuk StorageService khusus authentication
extension StorageServiceAuthExtensions on StorageService {
  // ✅ Save complete login session
  Future<void> saveLoginSession(
    String token,
    Map<String, dynamic> userData,
    String role, {
    Map<String, dynamic>? driverData,
    Map<String, dynamic>? storeData,
  }) async {
    try {
      // Save token
      await writeString(StorageConstants.authToken, token);

      // Save user data
      await writeJson(StorageConstants.userDataKey, userData);
      await writeString(StorageConstants.userRole, role);
      await writeString(StorageConstants.userEmail, userData['email'] ?? '');
      await writeString(StorageConstants.userName, userData['name'] ?? '');
      await writeInt(StorageConstants.userId, userData['id'] ?? 0);

      // Save optional fields
      if (userData['phone'] != null) {
        await writeString(StorageConstants.userPhone, userData['phone']);
      }
      if (userData['avatar'] != null) {
        await writeString(StorageConstants.userAvatar, userData['avatar']);
      }
      if (userData['fcm_token'] != null) {
        await writeString(StorageConstants.fcmToken, userData['fcm_token']);
      }

      // Save role-specific data
      if (driverData != null) {
        await writeJson(StorageConstants.driverDataKey, driverData);
        if (driverData['license_number'] != null) {
          await writeString(StorageConstants.driverLicenseNumber,
              driverData['license_number']);
        }
        if (driverData['vehicle_plate'] != null) {
          await writeString(StorageConstants.driverVehicleNumber,
              driverData['vehicle_plate']);
        }
        if (driverData['status'] != null) {
          await writeString(
              StorageConstants.driverStatus, driverData['status']);
        }
      }

      if (storeData != null) {
        await writeJson(StorageConstants.storeDataKey, storeData);
        if (storeData['id'] != null) {
          await writeInt(StorageConstants.storeId, storeData['id']);
        }
        if (storeData['name'] != null) {
          await writeString(StorageConstants.storeName, storeData['name']);
        }
        if (storeData['status'] != null) {
          await writeString(StorageConstants.storeStatus, storeData['status']);
        }
      }

      // Mark as logged in
      await writeBool(StorageConstants.isLoggedIn, true);
      await writeDateTime(StorageConstants.lastLoginTime, DateTime.now());

      print('✅ Login session saved to storage successfully');
    } catch (e) {
      print('❌ Failed to save login session: $e');
      rethrow;
    }
  }

  // ✅ Clear complete login session
  Future<void> clearLoginSession() async {
    try {
      await removeBatch([
        StorageConstants.authToken,
        StorageConstants.userDataKey,
        StorageConstants.userRole,
        StorageConstants.userEmail,
        StorageConstants.userName,
        StorageConstants.userId,
        StorageConstants.userPhone,
        StorageConstants.userAvatar,
        StorageConstants.fcmToken,
        StorageConstants.driverDataKey,
        StorageConstants.driverLicenseNumber,
        StorageConstants.driverVehicleNumber,
        StorageConstants.driverStatus,
        StorageConstants.driverLatitude,
        StorageConstants.driverLongitude,
        StorageConstants.storeDataKey,
        StorageConstants.storeId,
        StorageConstants.storeName,
        StorageConstants.storeStatus,
        StorageConstants.storeAddress,
        StorageConstants.storeLatitude,
        StorageConstants.storeLongitude,
        StorageConstants.lastLoginTime,
      ]);

      await writeBool(StorageConstants.isLoggedIn, false);
      print('✅ Login session cleared from storage');
    } catch (e) {
      print('❌ Failed to clear login session: $e');
      rethrow;
    }
  }

  // ✅ Check if user is logged in
  bool isUserLoggedIn() {
    return readBoolWithDefault(StorageConstants.isLoggedIn, false);
  }

  // ✅ Get current user token
  String? getCurrentUserToken() {
    return readString(StorageConstants.authToken);
  }

  // ✅ Get current user data
  Map<String, dynamic>? getCurrentUser() {
    return readJson(StorageConstants.userDataKey);
  }

  // ✅ Get current user role
  String? getCurrentUserRole() {
    return readString(StorageConstants.userRole);
  }

  // ✅ Get driver data
  Map<String, dynamic>? getDriverData() {
    return readJson(StorageConstants.driverDataKey);
  }

  // ✅ Get store data
  Map<String, dynamic>? getStoreData() {
    return readJson(StorageConstants.storeDataKey);
  }

  // ✅ Check if session is valid (token exists and not expired)
  bool hasValidSession() {
    final isLoggedIn = isUserLoggedIn();
    final token = getCurrentUserToken();
    final lastLoginTime = readDateTime(StorageConstants.lastLoginTime);

    if (!isLoggedIn || token == null || token.isEmpty) {
      return false;
    }

    // Check if session is older than 7 days (backend JWT expires in 7 days)
    if (lastLoginTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lastLoginTime);
      if (difference.inDays >= 7) {
        return false;
      }
    }

    return true;
  }

  // ✅ Update user profile in storage
  Future<void> updateUserProfileInStorage({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    final currentUser = getCurrentUser();
    if (currentUser != null) {
      if (name != null) {
        currentUser['name'] = name;
        await writeString(StorageConstants.userName, name);
      }
      if (email != null) {
        currentUser['email'] = email;
        await writeString(StorageConstants.userEmail, email);
      }
      if (phone != null) {
        currentUser['phone'] = phone;
        await writeString(StorageConstants.userPhone, phone);
      }
      if (avatar != null) {
        currentUser['avatar'] = avatar;
        await writeString(StorageConstants.userAvatar, avatar);
      }

      await writeJson(StorageConstants.userDataKey, currentUser);
    }
  }

  // ✅ Update driver location in storage
  Future<void> updateDriverLocationInStorage(
      double latitude, double longitude) async {
    await writeDouble(StorageConstants.driverLatitude, latitude);
    await writeDouble(StorageConstants.driverLongitude, longitude);

    final driverData = getDriverData();
    if (driverData != null) {
      driverData['latitude'] = latitude;
      driverData['longitude'] = longitude;
      await writeJson(StorageConstants.driverDataKey, driverData);
    }
  }

  // ✅ Update driver status in storage
  Future<void> updateDriverStatusInStorage(String status) async {
    await writeString(StorageConstants.driverStatus, status);

    final driverData = getDriverData();
    if (driverData != null) {
      driverData['status'] = status;
      await writeJson(StorageConstants.driverDataKey, driverData);
    }
  }

  // ✅ Get session info for debugging
  Map<String, dynamic> getSessionDebugInfo() {
    return {
      'isLoggedIn': isUserLoggedIn(),
      'hasToken': getCurrentUserToken() != null,
      'tokenLength': getCurrentUserToken()?.length ?? 0,
      'role': getCurrentUserRole(),
      'userName': readString(StorageConstants.userName),
      'hasValidSession': hasValidSession(),
      'lastLoginTime':
          readDateTime(StorageConstants.lastLoginTime)?.toIso8601String(),
    };
  }
}
