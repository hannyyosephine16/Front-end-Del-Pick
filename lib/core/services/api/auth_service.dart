// lib/core/services/api/auth_service.dart - NO FIREBASE VERSION
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/services/external/notification_service.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';

class AuthApiService {
  final ApiService _apiService;
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  AuthApiService(this._apiService);

  // ✅ BASIC AUTH ENDPOINTS - SESUAI BACKEND
  Future<Response> login(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.login, data: data);
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.register, data: data);
  }

  Future<Response> getProfile() async {
    return await _apiService.get(ApiEndpoints.profile);
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _apiService.put(ApiEndpoints.profile, data: data);
  }

  // ✅ SIMPLIFIED FCM TOKEN UPDATE - NO FIREBASE DEPENDENCY
  /// Update FCM token in backend (even though we don't use Firebase)
  /// This keeps backend compatibility but we'll send null or empty token
  Future<Response> updateFcmToken(Map<String, dynamic> data) async {
    // Send empty token to maintain backend compatibility
    final requestData = {
      'fcm_token': '', // Empty since we don't use Firebase
      ...data,
    };
    return await _apiService.put(ApiEndpoints.updateFcmToken,
        data: requestData);
  }

  // ✅ NOTIFICATION TOKEN MANAGEMENT - LOCAL ONLY
  /// Get local notification token (for app-level notifications)
  Future<String?> getLocalNotificationToken() async {
    // Generate a local identifier for this device/app installation
    final deviceInfo = await _getDeviceInfo();
    return 'local_${deviceInfo['id']}';
  }

  /// Register for local notifications only
  Future<bool> registerForNotifications() async {
    try {
      // Request local notification permission
      final hasPermission = await _notificationService.requestPermission();

      if (hasPermission) {
        // Initialize notification service
        await _notificationService.initialize();

        // Update backend with empty FCM token (maintains compatibility)
        await updateFcmToken({'fcm_token': ''});

        return true;
      }

      return false;
    } catch (e) {
      print('Failed to register for notifications: $e');
      return false;
    }
  }

  /// Unregister from notifications
  Future<void> unregisterFromNotifications() async {
    try {
      // Clear local notifications
      await _notificationService.clearAll();

      // Remove FCM token from backend
      await updateFcmToken({'fcm_token': null});
    } catch (e) {
      print('Failed to unregister from notifications: $e');
    }
  }

  // ✅ PASSWORD RESET ENDPOINTS
  Future<Response> forgotPassword(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.forgotPassword, data: data);
  }

  Future<Response> resetPassword(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.resetPassword, data: data);
  }

  // ✅ EMAIL VERIFICATION ENDPOINTS
  Future<Response> verifyEmail(String token) async {
    return await _apiService.post('${ApiEndpoints.verifyEmail}/$token');
  }

  Future<Response> resendVerification(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.resendVerification, data: data);
  }

  // ✅ LOGOUT
  Future<Response> logout() async {
    try {
      // Clear local notifications first
      await _notificationService.clearAll();

      // Then call backend logout
      return await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      // Even if backend call fails, we should still logout locally
      rethrow;
    }
  }

  // ✅ HELPER METHODS

  /// Get device info for local identification
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      // Use a simple approach without device_info_plus to avoid dependencies
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId = timestamp.toString().substring(6); // Last 7 digits

      return {
        'id': 'local_device_$randomId',
        'platform': GetPlatform.isAndroid ? 'android' : 'ios',
        'timestamp': timestamp,
      };
    } catch (e) {
      return {
        'id': 'unknown_device',
        'platform': 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }

  /// Check if user has notification permissions
  Future<bool> hasNotificationPermission() async {
    return await _notificationService.areNotificationsEnabled();
  }

  /// Show login success notification
  Future<void> showLoginSuccessNotification(String userName) async {
    await _notificationService.showLocalNotification(
      title: 'Selamat datang!',
      body: 'Halo $userName, Anda berhasil masuk ke DelPick',
      type: 'auth',
    );
  }

  /// Show logout notification
  Future<void> showLogoutNotification() async {
    await _notificationService.showLocalNotification(
      title: 'Sampai jumpa!',
      body: 'Anda telah keluar dari DelPick',
      type: 'auth',
    );
  }

  // ✅ TOKEN VALIDATION
  /// Validate token without Firebase dependency
  Future<bool> validateToken(String token) async {
    try {
      // Simply try to get profile with the token
      final response = await getProfile();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Refresh token if needed (backend DelPick doesn't have refresh tokens)
  Future<String?> refreshTokenIfNeeded(String currentToken) async {
    final isValid = await validateToken(currentToken);
    return isValid ? currentToken : null;
  }

  // ✅ PROFILE IMAGE UPLOAD
  /// Upload profile image as base64 (sesuai backend DelPick)
  Future<Response> uploadProfileImage(String base64Image) async {
    return await updateProfile({
      'avatar': base64Image,
    });
  }

  // ✅ NOTIFICATION PREFERENCES
  /// Update notification preferences (local only since no Firebase)
  Future<void> updateNotificationPreferences({
    bool? orderNotifications,
    bool? deliveryNotifications,
    bool? promotionNotifications,
  }) async {
    // Store preferences locally only
    final prefs = Get.find<GetStorage>();

    if (orderNotifications != null) {
      await prefs.write('order_notifications', orderNotifications);
    }
    if (deliveryNotifications != null) {
      await prefs.write('delivery_notifications', deliveryNotifications);
    }
    if (promotionNotifications != null) {
      await prefs.write('promotion_notifications', promotionNotifications);
    }
  }

  /// Get notification preferences
  Map<String, bool> getNotificationPreferences() {
    final prefs = Get.find<GetStorage>();

    return {
      'orderNotifications': prefs.read('order_notifications') ?? true,
      'deliveryNotifications': prefs.read('delivery_notifications') ?? true,
      'promotionNotifications': prefs.read('promotion_notifications') ?? false,
    };
  }

  // ✅ SESSION MANAGEMENT
  /// Check if current session is valid
  Future<bool> isSessionValid() async {
    try {
      final profile = await getProfile();
      return profile.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Extend session (just validate current session since no refresh tokens)
  Future<bool> extendSession() async {
    return await isSessionValid();
  }
}
