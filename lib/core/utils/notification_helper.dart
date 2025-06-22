// lib/core/utils/notification_helper.dart - FIXED FOR BACKEND INTEGRATION
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class NotificationHelper {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize notification system
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      _isInitialized = true;
      debugPrint('NotificationHelper: Initialized successfully');
    } catch (e) {
      debugPrint('NotificationHelper: Initialization failed - $e');
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Initialize Firebase messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    await _requestPermission();

    // Get FCM token
    final token = await getFCMToken();
    if (token != null) {
      await _saveFCMToken(token);
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveFCMToken);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle app opened from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  /// Request notification permission
  static Future<bool> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to storage and send to backend
  static Future<void> _saveFCMToken(String token) async {
    try {
      final storageService = Get.find<StorageService>();
      await storageService.writeString(StorageConstants.fcmToken, token);

      // TODO: Send token to backend via API
      // await authRepository.updateFCMToken(token);

      debugPrint('FCM Token saved: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: ${message.messageId}');

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle background/terminated app messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');

    // Navigate based on notification type
    _navigateFromNotification(message);
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'delpick_channel',
      'DelPick Notifications',
      channelDescription: 'General notifications for DelPick app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Parse payload and navigate
    // Implementation depends on your notification data structure
  }

  /// Navigate based on notification data
  static void _navigateFromNotification(RemoteMessage message) {
    final data = message.data;

    if (data.isEmpty) return;

    // Navigate based on notification type (sesuai backend notification types)
    switch (data['type']) {
      case 'order_update':
        final orderId = data['order_id'];
        if (orderId != null) {
          Get.toNamed(Routes.CUSTOMER_ORDER_DETAIL, arguments: orderId);
        }
        break;

      case 'driver_request':
        Get.toNamed(Routes.DRIVER_REQUESTS);
        break;

      case 'delivery_update':
        final orderId = data['order_id'];
        if (orderId != null) {
          Get.toNamed(Routes.ORDER_TRACKING, arguments: orderId);
        }
        break;

      case 'promotion':
        // Navigate to promotions/offers screen
        break;

      default:
        // Navigate to notifications list
        Get.toNamed(Routes.NOTIFICATIONS);
    }
  }

  /// Show custom notification types
  static Future<void> showOrderNotification({
    required String title,
    required String body,
    required String orderId,
    String type = 'order_update',
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_channel',
      'Order Notifications',
      channelDescription: 'Notifications about order status updates',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.blue,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      orderId.hashCode,
      title,
      body,
      platformDetails,
      payload: '{"type": "$type", "order_id": "$orderId"}',
    );
  }

  /// Show driver request notification
  static Future<void> showDriverRequestNotification({
    required String title,
    required String body,
    required String requestId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'driver_channel',
      'Driver Notifications',
      channelDescription: 'Notifications for driver requests and updates',
      importance: Importance.max,
      priority: Priority.max,
      color: Colors.green,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      requestId.hashCode,
      title,
      body,
      platformDetails,
      payload: '{"type": "driver_request", "request_id": "$requestId"}',
    );
  }

  /// Cancel notification by ID
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Subscribe to topic (untuk broadcast notifications)
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Subscribe to role-based topics (sesuai backend user roles)
  static Future<void> subscribeToRoleTopics(String userRole) async {
    switch (userRole) {
      case 'customer':
        await subscribeToTopic('customers');
        await subscribeToTopic('promotions');
        break;
      case 'driver':
        await subscribeToTopic('drivers');
        break;
      case 'store':
        await subscribeToTopic('stores');
        break;
    }
  }

  /// Unsubscribe from all role-based topics
  static Future<void> unsubscribeFromAllRoleTopics() async {
    final topics = ['customers', 'drivers', 'stores', 'promotions'];
    for (final topic in topics) {
      await unsubscribeFromTopic(topic);
    }
  }

  /// Clear all stored notification data
  static Future<void> clearNotificationData() async {
    try {
      final storageService = Get.find<StorageService>();
      await storageService.remove(StorageConstants.fcmToken);
      await cancelAllNotifications();
      await unsubscribeFromAllRoleTopics();
    } catch (e) {
      debugPrint('Error clearing notification data: $e');
    }
  }
}
