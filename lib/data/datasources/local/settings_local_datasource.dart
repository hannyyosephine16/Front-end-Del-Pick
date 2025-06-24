import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';

class SettingsLocalDataSource {
  final StorageService _storageService;

  SettingsLocalDataSource(this._storageService);

  // Theme settings
  Future<void> saveThemeMode(String themeMode) async {
    await _storageService.writeString(StorageConstants.theme, themeMode);
  }

  String getThemeMode() {
    return _storageService.readString(StorageConstants.theme) ?? 'system';
  }

  Future<void> saveDarkMode(bool isDarkMode) async {
    await _storageService.writeBool(StorageConstants.isDarkMode, isDarkMode);
  }

  bool getDarkMode() {
    return _storageService.readBoolWithDefault(
        StorageConstants.isDarkMode, false);
  }

  // Language settings
  Future<void> saveLanguage(String language) async {
    await _storageService.writeString(StorageConstants.language, language);
  }

  String getLanguage() {
    return _storageService.readString(StorageConstants.language) ?? 'en';
  }

  // Notification settings
  Future<void> saveNotificationSettings({
    bool? notificationsEnabled,
    bool? orderNotifications,
    bool? promotionNotifications,
    bool? deliveryNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    if (notificationsEnabled != null) {
      await _storageService.writeBool(
          StorageConstants.notificationsEnabled, notificationsEnabled);
    }
    if (orderNotifications != null) {
      await _storageService.writeBool(
          StorageConstants.orderNotifications, orderNotifications);
    }
    if (promotionNotifications != null) {
      await _storageService.writeBool(
          StorageConstants.promotionNotifications, promotionNotifications);
    }
    if (deliveryNotifications != null) {
      await _storageService.writeBool(
          StorageConstants.deliveryNotifications, deliveryNotifications);
    }
    if (soundEnabled != null) {
      await _storageService.writeBool(
          StorageConstants.soundEnabled, soundEnabled);
    }
    if (vibrationEnabled != null) {
      await _storageService.writeBool(
          StorageConstants.vibrationEnabled, vibrationEnabled);
    }
  }

  Map<String, bool> getNotificationSettings() {
    return {
      'notificationsEnabled': _storageService.readBoolWithDefault(
          StorageConstants.notificationsEnabled, true),
      'orderNotifications': _storageService.readBoolWithDefault(
          StorageConstants.orderNotifications, true),
      'promotionNotifications': _storageService.readBoolWithDefault(
          StorageConstants.promotionNotifications, true),
      'deliveryNotifications': _storageService.readBoolWithDefault(
          StorageConstants.deliveryNotifications, true),
      'soundEnabled': _storageService.readBoolWithDefault(
          StorageConstants.soundEnabled, true),
      'vibrationEnabled': _storageService.readBoolWithDefault(
          StorageConstants.vibrationEnabled, true),
    };
  }

  // Location settings
  Future<void> saveLocationPermission(bool granted) async {
    await _storageService.writeBool(
        StorageConstants.locationPermissionGranted, granted);
  }

  bool getLocationPermission() {
    return _storageService.readBoolWithDefault(
        StorageConstants.locationPermissionGranted, false);
  }

  Future<void> saveLastKnownLocation(double latitude, double longitude) async {
    await _storageService.writeDouble(
        StorageConstants.lastKnownLatitude, latitude);
    await _storageService.writeDouble(
        StorageConstants.lastKnownLongitude, longitude);
  }

  Map<String, double>? getLastKnownLocation() {
    final latitude =
        _storageService.readDouble(StorageConstants.lastKnownLatitude);
    final longitude =
        _storageService.readDouble(StorageConstants.lastKnownLongitude);

    if (latitude != null && longitude != null) {
      return {'latitude': latitude, 'longitude': longitude};
    }
    return null;
  }

  // App settings
  Future<void> saveIsFirstTime(bool isFirstTime) async {
    await _storageService.writeBool(StorageConstants.isFirstTime, isFirstTime);
  }

  bool getIsFirstTime() {
    return _storageService.readBoolWithDefault(
        StorageConstants.isFirstTime, true);
  }

  Future<void> saveHasSeenOnboarding(bool hasSeen) async {
    await _storageService.writeBool(
        StorageConstants.hasSeenOnboarding, hasSeen);
  }

  bool getHasSeenOnboarding() {
    return _storageService.readBoolWithDefault(
        StorageConstants.hasSeenOnboarding, false);
  }
}
