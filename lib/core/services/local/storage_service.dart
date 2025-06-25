import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart' as getx;
import '../../../core/constants/storage_constants.dart';

/// ✅ StorageService yang diperluas untuk mendukung semua kebutuhan backend DelPick - COMPLETE
class StorageService extends getx.GetxService {
  late GetStorage _box;

  @override
  Future<void> onInit() async {
    super.onInit();
    await GetStorage.init();
    _box = GetStorage();
  }

  // ======================== BASIC STORAGE OPERATIONS ========================

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

  /// ✅ Remove multiple keys in batch
  Future<void> removeBatch(List<String> keys) async {
    for (final key in keys) {
      await _box.remove(key);
    }
  }

  Future<void> clearAll() async {
    await _box.erase();
  }

  // ======================== TYPE-SPECIFIC METHODS ========================

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

  // ======================== DATE/TIME METHODS ========================

  /// ✅ Write DateTime as ISO string
  Future<void> writeDateTime(String key, DateTime dateTime) async {
    await _box.write(key, dateTime.toIso8601String());
  }

  /// ✅ Read DateTime from ISO string
  DateTime? readDateTime(String key) {
    final String? dateString = _box.read<String>(key);
    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ======================== JSON OPERATIONS ========================

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

  // ======================== AUTH METHODS - Backend DelPick Compatible ========================

  /// Save complete login session (sesuai response backend DelPick)
  Future<void> saveLoginSession(
    String token,
    Map<String, dynamic> user,
    String role, {
    Map<String, dynamic>? driverData,
    Map<String, dynamic>? storeData,
  }) async {
    // Save auth token
    await writeString(StorageConstants.authToken, token);
    await writeBool(StorageConstants.isLoggedIn, true);
    await writeDateTime(StorageConstants.lastLoginTime, DateTime.now());

    // Save complete user data
    await writeJson(StorageConstants.userDataKey, user);
    await writeString(StorageConstants.userRole, role);

    // Save individual user fields for quick access
    await writeInt(StorageConstants.userId, user['id'] ?? 0);
    await writeString(StorageConstants.userName, user['name'] ?? '');
    await writeString(StorageConstants.userEmail, user['email'] ?? '');
    await writeString(StorageConstants.userPhone, user['phone'] ?? '');
    await writeString(StorageConstants.userAvatar, user['avatar'] ?? '');
    if (user['fcm_token'] != null) {
      await writeString(StorageConstants.fcmToken, user['fcm_token']);
    }

    // Save role-specific data
    if (driverData != null) {
      await writeJson(StorageConstants.driverDataKey, driverData);
      // Extract driver specific fields
      await writeString(StorageConstants.driverLicenseNumber,
          driverData['license_number'] ?? '');
      await writeString(StorageConstants.driverVehicleNumber,
          driverData['vehicle_plate'] ?? '');
      await writeString(
          StorageConstants.driverStatus, driverData['status'] ?? 'inactive');
      if (driverData['latitude'] != null) {
        await writeDouble(StorageConstants.driverLatitude,
            (driverData['latitude'] as num).toDouble());
      }
      if (driverData['longitude'] != null) {
        await writeDouble(StorageConstants.driverLongitude,
            (driverData['longitude'] as num).toDouble());
      }
      if (driverData['rating'] != null) {
        await writeDouble(
            'driver_rating', (driverData['rating'] as num).toDouble());
      }
      if (driverData['reviews_count'] != null) {
        await writeInt('driver_reviews_count', driverData['reviews_count']);
      }
    }

    if (storeData != null) {
      await writeJson(StorageConstants.storeDataKey, storeData);
      // Extract store specific fields
      await writeInt(StorageConstants.storeId, storeData['id'] ?? 0);
      await writeString(StorageConstants.storeName, storeData['name'] ?? '');
      await writeString(
          StorageConstants.storeStatus, storeData['status'] ?? 'inactive');
      await writeString(
          StorageConstants.storeAddress, storeData['address'] ?? '');
      await writeString(
          StorageConstants.storeDescription, storeData['description'] ?? '');
      await writeString(
          StorageConstants.storeImageUrl, storeData['image_url'] ?? '');
      await writeString(StorageConstants.storePhone, storeData['phone'] ?? '');
      await writeString(
          StorageConstants.storeOpenTime, storeData['open_time'] ?? '');
      await writeString(
          StorageConstants.storeCloseTime, storeData['close_time'] ?? '');
      if (storeData['latitude'] != null) {
        await writeDouble(StorageConstants.storeLatitude,
            (storeData['latitude'] as num).toDouble());
      }
      if (storeData['longitude'] != null) {
        await writeDouble(StorageConstants.storeLongitude,
            (storeData['longitude'] as num).toDouble());
      }
      if (storeData['rating'] != null) {
        await writeDouble(StorageConstants.storeRating,
            (storeData['rating'] as num).toDouble());
      }
      if (storeData['total_products'] != null) {
        await writeInt(
            StorageConstants.storeTotalProducts, storeData['total_products']);
      }
      if (storeData['review_count'] != null) {
        await writeInt('store_review_count', storeData['review_count']);
      }
    }
  }

  /// Clear complete login session
  Future<void> clearLoginSession() async {
    final keysToRemove = [
      // Auth data
      StorageConstants.authToken,
      StorageConstants.refreshToken,
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

      // Driver specific
      StorageConstants.driverStatus,
      StorageConstants.driverVehicleNumber,
      StorageConstants.driverLicenseNumber,
      StorageConstants.driverLatitude,
      StorageConstants.driverLongitude,
      'driver_rating',
      'driver_reviews_count',

      // Store specific
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
      'store_review_count',

      // UI state
      'last_active_tab',

      // Temporary data
      'temp_registration_data',
      'password_reset_token',
      'password_reset_token_expiry',
      'email_verified',
    ];

    await removeBatch(keysToRemove);
    await writeBool(StorageConstants.isLoggedIn, false);
  }

  // ======================== USER DATA GETTERS ========================

  String? getCurrentUserToken() {
    return readString(StorageConstants.authToken);
  }

  Map<String, dynamic>? getCurrentUser() {
    return readJson(StorageConstants.userDataKey);
  }

  String? getCurrentUserRole() {
    return readString(StorageConstants.userRole);
  }

  int? getCurrentUserId() {
    return readInt(StorageConstants.userId);
  }

  bool isUserLoggedIn() {
    return readBoolWithDefault(StorageConstants.isLoggedIn, false);
  }

  Map<String, dynamic>? getDriverData() {
    return readJson(StorageConstants.driverDataKey);
  }

  Map<String, dynamic>? getStoreData() {
    return readJson(StorageConstants.storeDataKey);
  }

  // ======================== ONBOARDING METHODS ========================

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

  // ======================== FCM TOKEN METHODS ========================

  Future<void> saveFCMToken(String token) async {
    await writeString(StorageConstants.fcmToken, token);
  }

  String? getFCMToken() {
    return readString(StorageConstants.fcmToken);
  }

  // ======================== THEME METHODS ========================

  Future<void> setDarkMode(bool isDark) async {
    await writeBool(StorageConstants.isDarkMode, isDark);
  }

  bool isDarkMode() {
    return readBoolWithDefault(StorageConstants.isDarkMode, false);
  }

  // ======================== LOCATION METHODS ========================

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

  // ======================== CART METHODS - Backend DelPick Compatible ========================

  Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    await writeJsonList(StorageConstants.cartItems, items);
    await writeDateTime(StorageConstants.cartUpdatedAt, DateTime.now());
  }

  List<Map<String, dynamic>> getCartItems() {
    return readJsonList(StorageConstants.cartItems) ?? [];
  }

  Future<void> saveCartStore(int storeId, String storeName) async {
    await writeInt(StorageConstants.cartStoreId, storeId);
    await writeString(StorageConstants.cartStoreName, storeName);
  }

  Future<void> clearCart() async {
    await removeBatch([
      StorageConstants.cartItems,
      StorageConstants.cartStoreId,
      StorageConstants.cartStoreName,
      StorageConstants.cartTotal,
      StorageConstants.cartUpdatedAt,
      StorageConstants.tempOrderData,
      StorageConstants.draftOrderData,
      'cart_delivery_fee',
      'cart_destination_latitude',
      'cart_destination_longitude',
      'cart_distance_km',
      'cart_min_order_amount',
      'cart_delivery_radius',
      'cart_preparation_time',
    ]);
  }

  // ======================== NOTIFICATION PREFERENCES ========================

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

  // ======================== DRIVER SPECIFIC METHODS ========================

  Future<void> updateDriverSettings({
    String? status,
    String? vehicleNumber,
    String? licenseNumber,
    int? locationUpdateInterval,
    bool? acceptOrdersAutomatically,
    String? workingHoursStart,
    String? workingHoursEnd,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewsCount,
  }) async {
    if (status != null) {
      await writeString(StorageConstants.driverStatus, status);
    }
    if (vehicleNumber != null) {
      await writeString(StorageConstants.driverVehicleNumber, vehicleNumber);
    }
    if (licenseNumber != null) {
      await writeString(StorageConstants.driverLicenseNumber, licenseNumber);
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
    if (latitude != null) {
      await writeDouble(StorageConstants.driverLatitude, latitude);
    }
    if (longitude != null) {
      await writeDouble(StorageConstants.driverLongitude, longitude);
    }
    if (rating != null) {
      await writeDouble('driver_rating', rating);
    }
    if (reviewsCount != null) {
      await writeInt('driver_reviews_count', reviewsCount);
    }

    // Update driver data as well
    final driverData = getDriverData();
    if (driverData != null) {
      final updatedData = Map<String, dynamic>.from(driverData);
      if (status != null) updatedData['status'] = status;
      if (vehicleNumber != null) updatedData['vehicle_plate'] = vehicleNumber;
      if (licenseNumber != null) updatedData['license_number'] = licenseNumber;
      if (latitude != null) updatedData['latitude'] = latitude;
      if (longitude != null) updatedData['longitude'] = longitude;
      if (rating != null) updatedData['rating'] = rating;
      if (reviewsCount != null) updatedData['reviews_count'] = reviewsCount;

      await writeJson(StorageConstants.driverDataKey, updatedData);
    }
  }

  Map<String, dynamic> getDriverSettings() {
    return {
      'status': readString(StorageConstants.driverStatus) ?? 'inactive',
      'vehicleNumber': readString(StorageConstants.driverVehicleNumber) ?? '',
      'licenseNumber': readString(StorageConstants.driverLicenseNumber) ?? '',
      'locationUpdateInterval':
          readIntWithDefault(StorageConstants.driverLocationUpdateInterval, 30),
      'acceptOrdersAutomatically': readBoolWithDefault(
          StorageConstants.acceptOrdersAutomatically, false),
      'workingHoursStart':
          readString(StorageConstants.workingHoursStart) ?? '08:00',
      'workingHoursEnd':
          readString(StorageConstants.workingHoursEnd) ?? '20:00',
      'latitude': readDouble(StorageConstants.driverLatitude),
      'longitude': readDouble(StorageConstants.driverLongitude),
      'rating': readDoubleWithDefault('driver_rating', 5.0),
      'reviewsCount': readIntWithDefault('driver_reviews_count', 0),
    };
  }

  // ======================== STORE SPECIFIC METHODS ========================

  Future<void> updateStoreSettings({
    String? name,
    String? status,
    String? address,
    String? description,
    String? imageUrl,
    String? phone,
    String? openTime,
    String? closeTime,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalProducts,
    int? reviewCount,
    bool? autoAcceptOrders,
    int? preparationTime,
  }) async {
    if (name != null) {
      await writeString(StorageConstants.storeName, name);
    }
    if (status != null) {
      await writeString(StorageConstants.storeStatus, status);
    }
    if (address != null) {
      await writeString(StorageConstants.storeAddress, address);
    }
    if (description != null) {
      await writeString(StorageConstants.storeDescription, description);
    }
    if (imageUrl != null) {
      await writeString(StorageConstants.storeImageUrl, imageUrl);
    }
    if (phone != null) {
      await writeString(StorageConstants.storePhone, phone);
    }
    if (openTime != null) {
      await writeString(StorageConstants.storeOpenTime, openTime);
    }
    if (closeTime != null) {
      await writeString(StorageConstants.storeCloseTime, closeTime);
    }
    if (latitude != null) {
      await writeDouble(StorageConstants.storeLatitude, latitude);
    }
    if (longitude != null) {
      await writeDouble(StorageConstants.storeLongitude, longitude);
    }
    if (rating != null) {
      await writeDouble(StorageConstants.storeRating, rating);
    }
    if (totalProducts != null) {
      await writeInt(StorageConstants.storeTotalProducts, totalProducts);
    }
    if (reviewCount != null) {
      await writeInt('store_review_count', reviewCount);
    }
    if (autoAcceptOrders != null) {
      await writeBool(StorageConstants.autoAcceptOrders, autoAcceptOrders);
    }
    if (preparationTime != null) {
      await writeInt(StorageConstants.preparationTime, preparationTime);
    }

    // Update store data as well
    final storeData = getStoreData();
    if (storeData != null) {
      final updatedData = Map<String, dynamic>.from(storeData);
      if (name != null) updatedData['name'] = name;
      if (status != null) updatedData['status'] = status;
      if (address != null) updatedData['address'] = address;
      if (description != null) updatedData['description'] = description;
      if (imageUrl != null) updatedData['image_url'] = imageUrl;
      if (phone != null) updatedData['phone'] = phone;
      if (openTime != null) updatedData['open_time'] = openTime;
      if (closeTime != null) updatedData['close_time'] = closeTime;
      if (latitude != null) updatedData['latitude'] = latitude;
      if (longitude != null) updatedData['longitude'] = longitude;
      if (rating != null) updatedData['rating'] = rating;
      if (totalProducts != null) updatedData['total_products'] = totalProducts;
      if (reviewCount != null) updatedData['review_count'] = reviewCount;

      await writeJson(StorageConstants.storeDataKey, updatedData);
    }
  }

  Map<String, dynamic> getStoreSettings() {
    return {
      'id': readInt(StorageConstants.storeId) ?? 0,
      'name': readString(StorageConstants.storeName) ?? '',
      'status': readString(StorageConstants.storeStatus) ?? 'inactive',
      'address': readString(StorageConstants.storeAddress) ?? '',
      'description': readString(StorageConstants.storeDescription) ?? '',
      'imageUrl': readString(StorageConstants.storeImageUrl) ?? '',
      'phone': readString(StorageConstants.storePhone) ?? '',
      'openTime': readString(StorageConstants.storeOpenTime) ?? '',
      'closeTime': readString(StorageConstants.storeCloseTime) ?? '',
      'latitude': readDouble(StorageConstants.storeLatitude),
      'longitude': readDouble(StorageConstants.storeLongitude),
      'rating': readDoubleWithDefault(StorageConstants.storeRating, 0.0),
      'totalProducts':
          readIntWithDefault(StorageConstants.storeTotalProducts, 0),
      'reviewCount': readIntWithDefault('store_review_count', 0),
      'autoAcceptOrders':
          readBoolWithDefault(StorageConstants.autoAcceptOrders, false),
      'preparationTime':
          readIntWithDefault(StorageConstants.preparationTime, 15),
    };
  }

  // ======================== ORDER TRACKING METHODS ========================

  /// Save current active order for tracking
  Future<void> saveActiveOrder(Map<String, dynamic> orderData) async {
    await writeJson('active_order', orderData);
    await writeDateTime('active_order_updated_at', DateTime.now());
  }

  /// Get current active order
  Map<String, dynamic>? getActiveOrder() {
    return readJson('active_order');
  }

  /// Clear active order
  Future<void> clearActiveOrder() async {
    await removeBatch(['active_order', 'active_order_updated_at']);
  }

  /// Save order history locally (for offline access)
  Future<void> saveOrderToHistory(Map<String, dynamic> orderData) async {
    final history = getOrderHistory();
    history.insert(0, orderData); // Add to beginning

    // Keep only last 50 orders
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await writeJsonList('order_history', history);
  }

  /// Get order history
  List<Map<String, dynamic>> getOrderHistory() {
    return readJsonList('order_history') ?? [];
  }

  /// Update order status in history
  Future<void> updateOrderInHistory(int orderId, String status) async {
    final history = getOrderHistory();
    final index = history.indexWhere((order) => order['id'] == orderId);

    if (index >= 0) {
      history[index]['order_status'] = status;
      history[index]['updated_at'] = DateTime.now().toIso8601String();
      await writeJsonList('order_history', history);
    }
  }

  // ======================== DRIVER REQUEST METHODS ========================

  /// Save pending driver requests
  Future<void> savePendingDriverRequests(
      List<Map<String, dynamic>> requests) async {
    await writeJsonList('pending_driver_requests', requests);
    await writeDateTime('driver_requests_updated_at', DateTime.now());
  }

  /// Get pending driver requests
  List<Map<String, dynamic>> getPendingDriverRequests() {
    return readJsonList('pending_driver_requests') ?? [];
  }

  /// Add new driver request
  Future<void> addDriverRequest(Map<String, dynamic> request) async {
    final requests = getPendingDriverRequests();
    requests.insert(0, request);
    await savePendingDriverRequests(requests);
  }

  /// Remove driver request
  Future<void> removeDriverRequest(int requestId) async {
    final requests = getPendingDriverRequests();
    requests.removeWhere((request) => request['id'] == requestId);
    await savePendingDriverRequests(requests);
  }

  /// Update driver request status
  Future<void> updateDriverRequestStatus(int requestId, String status) async {
    final requests = getPendingDriverRequests();
    final index = requests.indexWhere((request) => request['id'] == requestId);

    if (index >= 0) {
      requests[index]['status'] = status;
      requests[index]['updated_at'] = DateTime.now().toIso8601String();
      await savePendingDriverRequests(requests);
    }
  }

  // ======================== PERFORMANCE & ANALYTICS METHODS ========================

  /// Save app performance metrics
  Future<void> savePerformanceMetrics(Map<String, dynamic> metrics) async {
    await writeJson('performance_metrics', {
      ...metrics,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get performance metrics
  Map<String, dynamic>? getPerformanceMetrics() {
    return readJson('performance_metrics');
  }

  /// Save user analytics data
  Future<void> saveUserAnalytics(Map<String, dynamic> analytics) async {
    final currentAnalytics = readJson('user_analytics') ?? {};
    final updatedAnalytics = {
      ...currentAnalytics,
      ...analytics,
      'last_updated': DateTime.now().toIso8601String(),
    };
    await writeJson('user_analytics', updatedAnalytics);
  }

  /// Get user analytics data
  Map<String, dynamic> getUserAnalytics() {
    return readJson('user_analytics') ?? {};
  }

  // ======================== CRASH RECOVERY METHODS ========================

  /// Save app state for crash recovery
  Future<void> saveAppState(Map<String, dynamic> state) async {
    await writeJson('app_state_backup', {
      ...state,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get saved app state
  Map<String, dynamic>? getSavedAppState() {
    return readJson('app_state_backup');
  }

  /// Clear app state backup
  Future<void> clearAppStateBackup() async {
    await remove('app_state_backup');
  }

  // ======================== CACHE MANAGEMENT METHODS ========================

  /// Save cached data with expiry
  Future<void> setCachedData(String key, Map<String, dynamic> data,
      {Duration? expiry}) async {
    final cacheData = {
      'data': data,
      'cached_at': DateTime.now().toIso8601String(),
      'expires_at':
          expiry != null ? DateTime.now().add(expiry).toIso8601String() : null,
    };
    await writeJson('cache_$key', cacheData);
  }

  /// Get cached data (returns null if expired)
  Map<String, dynamic>? getCachedData(String key) {
    final cacheData = readJson('cache_$key');
    if (cacheData == null) return null;

    final expiresAt = cacheData['expires_at'] as String?;
    if (expiresAt != null) {
      final expiry = DateTime.parse(expiresAt);
      if (DateTime.now().isAfter(expiry)) {
        remove('cache_$key'); // Remove expired cache
        return null;
      }
    }

    return cacheData['data'] as Map<String, dynamic>?;
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final allKeys =
        _box.getKeys().where((key) => key.toString().startsWith('cache_'));

    for (final key in allKeys) {
      final cacheData = readJson(key.toString());
      if (cacheData != null) {
        final expiresAt = cacheData['expires_at'] as String?;
        if (expiresAt != null) {
          final expiry = DateTime.parse(expiresAt);
          if (DateTime.now().isAfter(expiry)) {
            await remove(key.toString());
          }
        }
      }
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    final allKeys =
        _box.getKeys().where((key) => key.toString().startsWith('cache_'));
    await removeBatch(allKeys.map((k) => k.toString()).toList());
  }

  // ======================== BACKUP & RESTORE METHODS ========================

  /// Create complete app data backup
  Future<Map<String, dynamic>> createBackup() async {
    return {
      'user_data': getCurrentUser(),
      'driver_data': getDriverData(),
      'store_data': getStoreData(),
      'cart_items': getCartItems(),
      'order_history': getOrderHistory(),
      'notification_preferences': getNotificationPreferences(),
      'driver_settings':
          getCurrentUserRole() == 'driver' ? getDriverSettings() : null,
      'store_settings':
          getCurrentUserRole() == 'store' ? getStoreSettings() : null,
      'last_known_location': getLastKnownLocation(),
      'user_analytics': getUserAnalytics(),
      'backup_created_at': DateTime.now().toIso8601String(),
      'app_version': '1.0.0', // Should come from package info
    };
  }

  /// Restore from backup
  Future<void> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      // Restore user data
      final userData = backup['user_data'] as Map<String, dynamic>?;
      if (userData != null) {
        await writeJson(StorageConstants.userDataKey, userData);
        await writeString(StorageConstants.userRole, userData['role'] ?? '');
        await writeInt(StorageConstants.userId, userData['id'] ?? 0);
        await writeString(StorageConstants.userName, userData['name'] ?? '');
        await writeString(StorageConstants.userEmail, userData['email'] ?? '');
      }

      // Restore role-specific data
      final driverData = backup['driver_data'] as Map<String, dynamic>?;
      if (driverData != null) {
        await writeJson(StorageConstants.driverDataKey, driverData);
      }

      final storeData = backup['store_data'] as Map<String, dynamic>?;
      if (storeData != null) {
        await writeJson(StorageConstants.storeDataKey, storeData);
      }

      // Restore cart
      final cartItems = backup['cart_items'] as List<dynamic>?;
      if (cartItems != null) {
        await writeJsonList(
            StorageConstants.cartItems, cartItems.cast<Map<String, dynamic>>());
      }

      // Restore order history
      final orderHistory = backup['order_history'] as List<dynamic>?;
      if (orderHistory != null) {
        await writeJsonList(
            'order_history', orderHistory.cast<Map<String, dynamic>>());
      }

      // Restore preferences
      final notificationPrefs =
          backup['notification_preferences'] as Map<String, dynamic>?;
      if (notificationPrefs != null) {
        await updateNotificationPreferences(
          orderNotifications: notificationPrefs['orderNotifications'],
          deliveryNotifications: notificationPrefs['deliveryNotifications'],
          promotionNotifications: notificationPrefs['promotionNotifications'],
          soundEnabled: notificationPrefs['soundEnabled'],
          vibrationEnabled: notificationPrefs['vibrationEnabled'],
        );
      }

      // Restore location
      final location = backup['last_known_location'] as Map<String, dynamic>?;
      if (location != null) {
        await saveLastKnownLocation(
          location['latitude']?.toDouble() ?? 0.0,
          location['longitude']?.toDouble() ?? 0.0,
        );
      }

      // Restore analytics
      final analytics = backup['user_analytics'] as Map<String, dynamic>?;
      if (analytics != null) {
        await writeJson('user_analytics', analytics);
      }
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  // ======================== UTILITY METHODS ========================

  /// Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    final allKeys = _box.getKeys();
    int totalSize = 0;

    for (final key in allKeys) {
      final value = _box.read(key);
      if (value is String) {
        totalSize += value.length;
      } else {
        totalSize += value.toString().length;
      }
    }

    return {
      'total_keys': allKeys.length,
      'estimated_size_bytes': totalSize,
      'estimated_size_kb': (totalSize / 1024).round(),
      'last_checked': DateTime.now().toIso8601String(),
    };
  }

  /// Clean up old data
  Future<void> cleanupOldData() async {
    await clearExpiredCache();

    // Clean old order history (keep only 50)
    final history = getOrderHistory();
    if (history.length > 50) {
      final trimmedHistory = history.take(50).toList();
      await writeJsonList('order_history', trimmedHistory);
    }

    // Clean old performance metrics (older than 30 days)
    final metrics = getPerformanceMetrics();
    if (metrics != null) {
      final timestamp = metrics['timestamp'] as String?;
      if (timestamp != null) {
        final metricsDate = DateTime.parse(timestamp);
        if (DateTime.now().difference(metricsDate).inDays > 30) {
          await remove('performance_metrics');
        }
      }
    }
  }

  /// Initialize storage with default values
  Future<void> initializeDefaults() async {
    // Set default notification preferences if not set
    if (!hasData(StorageConstants.orderNotifications)) {
      await updateNotificationPreferences(
        orderNotifications: true,
        deliveryNotifications: true,
        promotionNotifications: false,
        soundEnabled: true,
        vibrationEnabled: true,
      );
    }

    // Set default theme if not set
    if (!hasData(StorageConstants.isDarkMode)) {
      await setDarkMode(false);
    }

    // Initialize analytics
    if (!hasData('user_analytics')) {
      await saveUserAnalytics({
        'app_opened_count': 0,
        'last_app_version': '1.0.0',
        'installation_date': DateTime.now().toIso8601String(),
      });
    }
  }
}
