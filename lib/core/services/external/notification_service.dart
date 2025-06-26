// lib/core/services/external/notification_service.dart - CLEAN (No Firebase)
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
// ✅ Required for scheduled notifications
import 'package:timezone/timezone.dart' as TZ;
import 'package:timezone/data/latest.dart' as TZ;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';

class NotificationService extends GetxService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  final RxInt _unreadCount = 0.obs;
  final RxList<Map<String, dynamic>> _notifications =
      <Map<String, dynamic>>[].obs;

  // Getters
  int get unreadCount => _unreadCount.value;
  List<Map<String, dynamic>> get notifications => _notifications.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
  }

  // ✅ Initialize without Firebase - Local notifications only
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

      // Load stored notifications
      await _loadStoredNotifications();

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

  // ✅ Show local notification with storage
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String? type,
    Map<String, dynamic>? data,
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
        playSound: true,
        enableVibration: true,
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

      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      // Store notification locally
      await _storeNotification({
        'id': notificationId,
        'title': title,
        'body': body,
        'type': type ?? 'general',
        'data': data ?? {},
        'payload': payload,
        'isRead': false,
        'timestamp': DateTime.now().toIso8601String(),
      });

      debugPrint('📨 Local notification sent: $title');
    } catch (e) {
      debugPrint('❌ Failed to show notification: $e');
    }
  }

  // ✅ Show order notification
  Future<void> showOrderNotification({
    required String orderId,
    required String title,
    required String body,
    required String status,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      type: 'order',
      data: {
        'orderId': orderId,
        'status': status,
      },
      payload: 'order:$orderId',
    );
  }

  // ✅ Show delivery notification
  Future<void> showDeliveryNotification({
    required String orderId,
    required String title,
    required String body,
    String? driverName,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      type: 'delivery',
      data: {
        'orderId': orderId,
        'driverName': driverName,
      },
      payload: 'delivery:$orderId',
    );
  }

  // ✅ Show driver request notification
  Future<void> showDriverRequestNotification({
    required String requestId,
    required String title,
    required String body,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      type: 'driver_request',
      data: {
        'requestId': requestId,
      },
      payload: 'driver_request:$requestId',
    );
  }

  // ✅ Store notification locally
  Future<void> _storeNotification(Map<String, dynamic> notification) async {
    _notifications.insert(0, notification);
    _unreadCount.value++;

    // Keep only last 100 notifications
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }

    await _saveNotificationsToStorage();
  }

  // ✅ Load stored notifications
  Future<void> _loadStoredNotifications() async {
    try {
      final box = GetStorage();
      final stored = box.read<List>('stored_notifications');
      if (stored != null) {
        _notifications.value = stored.cast<Map<String, dynamic>>();
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('❌ Failed to load stored notifications: $e');
    }
  }

  // ✅ Save notifications to storage
  Future<void> _saveNotificationsToStorage() async {
    try {
      final box = GetStorage();
      await box.write('stored_notifications', _notifications.value);
    } catch (e) {
      debugPrint('❌ Failed to save notifications: $e');
    }
  }

  // ✅ Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _updateUnreadCount();
      await _saveNotificationsToStorage();
    }
  }

  // ✅ Mark all as read
  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _unreadCount.value = 0;
    await _saveNotificationsToStorage();
  }

  // ✅ Delete notification
  Future<void> deleteNotification(int notificationId) async {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    _updateUnreadCount();
    await _saveNotificationsToStorage();
  }

  // ✅ Clear all notifications
  Future<void> clearAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      _notifications.clear();
      _unreadCount.value = 0;
      await _saveNotificationsToStorage();
      debugPrint('📨 All notifications cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear notifications: $e');
    }
  }

  // ✅ Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');

    if (response.payload != null) {
      _handleNotificationPayload(response.payload!);
    }
  }

  // ✅ Handle notification payload routing
  void _handleNotificationPayload(String payload) {
    final parts = payload.split(':');
    if (parts.length >= 2) {
      final type = parts[0];
      final id = parts[1];

      switch (type) {
        case 'order':
          Get.toNamed('/order-detail/$id');
          break;
        case 'delivery':
          Get.toNamed('/order-tracking/$id');
          break;
        case 'driver_request':
          Get.toNamed('/driver-requests/$id');
          break;
        default:
          debugPrint('Unknown notification type: $type');
      }
    }
  }

  // ✅ Update unread count
  void _updateUnreadCount() {
    final unread = _notifications.where((n) => n['isRead'] == false).length;
    _unreadCount.value = unread;
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

  // // ✅ Schedule notification for later
  // Future<void> scheduleNotification({
  //   required String title,
  //   required String body,
  //   required DateTime scheduledDate,
  //   String? payload,
  //   String? type,
  // })
  // async {
  //   if (!_isInitialized) await initialize();
  //
  //   try {
  //     const androidDetails = AndroidNotificationDetails(
  //       'delpick_scheduled',
  //       'DelPick Scheduled',
  //       channelDescription: 'Scheduled notifications for DelPick',
  //       importance: Importance.high,
  //       priority: Priority.high,
  //     );
  //
  //     const iosDetails = DarwinNotificationDetails();
  //
  //     const notificationDetails = NotificationDetails(
  //       android: androidDetails,
  //       iOS: iosDetails,
  //     );
  //
  //     await _flutterLocalNotificationsPlugin.zonedSchedule(
  //       DateTime.now().millisecondsSinceEpoch.remainder(100000),
  //       title,
  //       body,
  //       DateTime.from(scheduledDate, TZ.local),
  //       notificationDetails,
  //       payload: payload,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       androidScheduleMode: null,
  //     );
  //
  //     debugPrint('📅 Notification scheduled for $scheduledDate');
  //   } catch (e) {
  //     debugPrint('❌ Failed to schedule notification: $e');
  //   }
  // }

  // ✅ Get notification history
  List<Map<String, dynamic>> getNotificationHistory({
    String? type,
    bool? isRead,
    int? limit,
  }) {
    var filtered = _notifications.value;

    if (type != null) {
      filtered = filtered.where((n) => n['type'] == type).toList();
    }

    if (isRead != null) {
      filtered = filtered.where((n) => n['isRead'] == isRead).toList();
    }

    if (limit != null) {
      filtered = filtered.take(limit).toList();
    }

    return filtered;
  }

  // ✅ Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  @override
  void onClose() {
    _unreadCount.close();
    _notifications.close();
    super.onClose();
  }
}
