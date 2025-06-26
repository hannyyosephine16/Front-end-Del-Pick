// lib/core/services/external/notification_service.dart (Clean - No Firebase)
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ✅ Initialize without Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications only
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized (local only)');
    } catch (e) {
      debugPrint('❌ NotificationService initialization failed: $e');
    }
  }

  // ✅ Request permission without Firebase
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      debugPrint('📱 Notification permission: ${status.name}');
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Permission request failed: $e');
      return false;
    }
  }

  // ✅ Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'delpick_channel',
        'DelPick Notifications',
        channelDescription: 'Notifications for DelPick app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('📨 Local notification sent: $title');
    } catch (e) {
      debugPrint('❌ Failed to show notification: $e');
    }
  }

  // ✅ Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
    // Handle notification tap logic here
  }

  // ✅ Cancel all notifications
  Future<void> cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('📨 All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Failed to cancel notifications: $e');
    }
  }

  // ✅ Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      debugPrint('❌ Failed to get pending notifications: $e');
      return [];
    }
  }
}
