// 2. lib/core/services/local/storage_service.dart (UPDATED untuk menambah method helper)
import 'dart:convert';
import 'package:del_pick/app/config/storage_config.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart' as getx;
import '../../../core/constants/storage_constants.dart';

class StorageService extends getx.GetxService {
  late GetStorage _box;

  @override
  Future<void> onInit() async {
    super.onInit();
    await GetStorage.init();
    _box = GetStorage();
  }

  // Basic storage operations
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  T readWithDefault<T>(String key, T defaultValue) {
    return _box.read<T>(key) ?? defaultValue;
  }

  bool hasData(String key) {
    return _box.hasData(key);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  Future<void> clearAll() async {
    await _box.erase();
  }

  // Convenience methods
  Future<void> writeString(String key, String value) async {
    await _box.write(key, value);
  }

  String? readString(String key) {
    return _box.read<String>(key);
  }

  Future<void> writeBool(String key, bool value) async {
    await _box.write(key, value);
  }

  bool? readBool(String key) {
    return _box.read<bool>(key);
  }

  bool readBoolWithDefault(String key, bool defaultValue) {
    return _box.read<bool>(key) ?? defaultValue;
  }

  Future<void> writeInt(String key, int value) async {
    await _box.write(key, value);
  }

  int? readInt(String key) {
    return _box.read<int>(key);
  }

  int readIntWithDefault(String key, int defaultValue) {
    return _box.read<int>(key) ?? defaultValue;
  }

  Future<void> writeDouble(String key, double value) async {
    await _box.write(key, value);
  }

  double? readDouble(String key) {
    return _box.read<double>(key);
  }

  double readDoubleWithDefault(String key, double defaultValue) {
    return _box.read<double>(key) ?? defaultValue;
  }

  // JSON operations
  Future<void> writeJson(String key, Map<String, dynamic> json) async {
    await _box.write(key, jsonEncode(json));
  }

  Map<String, dynamic>? readJson(String key) {
    final String? jsonString = _box.read<String>(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> writeJsonList(
      String key, List<Map<String, dynamic>> jsonList) async {
    await _box.write(key, jsonEncode(jsonList));
  }

  List<Map<String, dynamic>>? readJsonList(String key) {
    final String? jsonString = _box.read<String>(key);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Auth specific methods
  Future<void> saveLoginSession(
      String token, Map<String, dynamic> user, String role) async {
    await writeString(StorageConstants.authToken, token);
    await writeJson(StorageConstants.userId.toString(), user);
    await writeString(StorageConstants.userRole, role);
    await writeBool(StorageConstants.isLoggedIn, true);
    await writeString(
        StorageConstants.lastLoginTime, DateTime.now().toIso8601String());

    // Save individual user data for easy access
    await writeInt(StorageConstants.userId, user['id'] ?? 0);
    await writeString(StorageConstants.userName, user['name'] ?? '');
    await writeString(StorageConstants.userEmail, user['email'] ?? '');
    await writeString(StorageConstants.userPhone, user['phone'] ?? '');
    await writeString(StorageConstants.userAvatar, user['avatar'] ?? '');
  }

  Future<void> clearLoginSession() async {
    final keysToRemove = [
      StorageConstants.authToken,
      StorageConstants.refreshToken,
      StorageConstants.userId,
      StorageConstants.userRole,
      StorageConstants.userEmail,
      StorageConstants.userName,
      StorageConstants.userPhone,
      StorageConstants.userAvatar,
      StorageConstants.isLoggedIn,
      StorageConstants.lastLoginTime,
      // Clear role-specific data
      StorageConstants.driverStatus,
      StorageConstants.storeStatus,
      StorageKeys.lastActiveTab,
    ];

    for (final key in keysToRemove) {
      await remove(key);
    }
  }

  // Onboarding methods
  Future<void> markOnboardingAsSeen() async {
    await writeBool(StorageConstants.hasSeenOnboarding, true);
    await writeBool(StorageConstants.isFirstTime, false);
  }

  bool hasSeenOnboarding() {
    return readBoolWithDefault(StorageConstants.hasSeenOnboarding, false);
  }

  bool isFirstTime() {
    return readBoolWithDefault(StorageConstants.isFirstTime, true);
  }

  // User data getters
  String? getCurrentUserToken() {
    return readString(StorageConstants.authToken);
  }

  Map<String, dynamic>? getCurrentUser() {
    final userId = readInt(StorageConstants.userId);
    if (userId != null) {
      return {
        'id': userId,
        'name': readString(StorageConstants.userName) ?? '',
        'email': readString(StorageConstants.userEmail) ?? '',
        'phone': readString(StorageConstants.userPhone) ?? '',
        'role': readString(StorageConstants.userRole) ?? '',
        'avatar': readString(StorageConstants.userAvatar) ?? '',
      };
    }
    return null;
  }

  String? getCurrentUserRole() {
    return readString(StorageConstants.userRole);
  }

  bool isUserLoggedIn() {
    return readBoolWithDefault(StorageConstants.isLoggedIn, false);
  }

  // FCM Token methods
  Future<void> saveFCMToken(String token) async {
    await writeString(StorageConstants.fcmToken, token);
  }

  String? getFCMToken() {
    return readString(StorageConstants.fcmToken);
  }

  // Theme methods
  Future<void> setDarkMode(bool isDark) async {
    await writeBool(StorageConstants.isDarkMode, isDark);
  }

  bool isDarkMode() {
    return readBoolWithDefault(StorageConstants.isDarkMode, false);
  }

  // Location methods
  Future<void> saveLastKnownLocation(double latitude, double longitude) async {
    await writeDouble(StorageConstants.lastKnownLatitude, latitude);
    await writeDouble(StorageConstants.lastKnownLongitude, longitude);
  }

  Map<String, double>? getLastKnownLocation() {
    final lat = readDouble(StorageConstants.lastKnownLatitude);
    final lng = readDouble(StorageConstants.lastKnownLongitude);

    if (lat != null && lng != null) {
      return {'latitude': lat, 'longitude': lng};
    }
    return null;
  }

  // Cart methods
  Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    await writeJsonList(StorageConstants.cartItems, items);
    await writeString(
        StorageConstants.cartUpdatedAt, DateTime.now().toIso8601String());
  }

  List<Map<String, dynamic>> getCartItems() {
    return readJsonList(StorageConstants.cartItems) ?? [];
  }

  Future<void> saveCartStore(int storeId, String storeName) async {
    await writeInt(StorageConstants.cartStoreId, storeId);
    await writeString(StorageConstants.cartStoreName, storeName);
  }

  Future<void> clearCart() async {
    await remove(StorageConstants.cartItems);
    await remove(StorageConstants.cartStoreId);
    await remove(StorageConstants.cartStoreName);
    await remove(StorageConstants.cartTotal);
    await remove(StorageConstants.cartUpdatedAt);
  }

  // Preferences methods
  Future<void> updateNotificationPreferences({
    bool? orderNotifications,
    bool? deliveryNotifications,
    bool? promotionNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    if (orderNotifications != null) {
      await writeBool(StorageConstants.orderNotifications, orderNotifications);
    }
    if (deliveryNotifications != null) {
      await writeBool(
          StorageConstants.deliveryNotifications, deliveryNotifications);
    }
    if (promotionNotifications != null) {
      await writeBool(
          StorageConstants.promotionNotifications, promotionNotifications);
    }
    if (soundEnabled != null) {
      await writeBool(StorageConstants.soundEnabled, soundEnabled);
    }
    if (vibrationEnabled != null) {
      await writeBool(StorageConstants.vibrationEnabled, vibrationEnabled);
    }
  }

  Map<String, bool> getNotificationPreferences() {
    return {
      'orderNotifications':
          readBoolWithDefault(StorageConstants.orderNotifications, true),
      'deliveryNotifications':
          readBoolWithDefault(StorageConstants.deliveryNotifications, true),
      'promotionNotifications':
          readBoolWithDefault(StorageConstants.promotionNotifications, false),
      'soundEnabled': readBoolWithDefault(StorageConstants.soundEnabled, true),
      'vibrationEnabled':
          readBoolWithDefault(StorageConstants.vibrationEnabled, true),
    };
  }

  // Driver specific methods
  Future<void> updateDriverSettings({
    String? status,
    String? vehicleNumber,
    int? locationUpdateInterval,
    bool? acceptOrdersAutomatically,
    String? workingHoursStart,
    String? workingHoursEnd,
  }) async {
    if (status != null) {
      await writeString(StorageConstants.driverStatus, status);
    }
    if (vehicleNumber != null) {
      await writeString(StorageConstants.driverVehicleNumber, vehicleNumber);
    }
    if (locationUpdateInterval != null) {
      await writeInt(StorageConstants.driverLocationUpdateInterval,
          locationUpdateInterval);
    }
    if (acceptOrdersAutomatically != null) {
      await writeBool(StorageConstants.acceptOrdersAutomatically,
          acceptOrdersAutomatically);
    }
    if (workingHoursStart != null) {
      await writeString(StorageConstants.workingHoursStart, workingHoursStart);
    }
    if (workingHoursEnd != null) {
      await writeString(StorageConstants.workingHoursEnd, workingHoursEnd);
    }
  }

  // Store specific methods
  Future<void> updateStoreSettings({
    String? name,
    String? status,
    String? openTime,
    String? closeTime,
    bool? autoAcceptOrders,
    int? preparationTime,
  }) async {
    if (name != null) {
      await writeString(StorageConstants.storeName, name);
    }
    if (status != null) {
      await writeString(StorageConstants.storeStatus, status);
    }
    if (openTime != null) {
      await writeString(StorageConstants.storeOpenTime, openTime);
    }
    if (closeTime != null) {
      await writeString(StorageConstants.storeCloseTime, closeTime);
    }
    if (autoAcceptOrders != null) {
      await writeBool(StorageConstants.autoAcceptOrders, autoAcceptOrders);
    }
    if (preparationTime != null) {
      await writeInt(StorageConstants.preparationTime, preparationTime);
    }
  }
}
