// 4. lib/core/services/external/notification_service.dart (NEW FILE)
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../../core/constants/storage_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(_saveFCMToken);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<bool> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageConstants.fcmToken, token);
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await _showLocalNotification(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      message.data,
    );
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling background message: ${message.messageId}');
}

// // lib/core/services/external/notification_service.dart - Fixed for compatibility
//
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';  // Temporarily commented
// import 'package:get/get.dart' as getx;
// import 'package:del_pick/core/services/local/storage_service.dart';
// import 'package:del_pick/core/constants/storage_constants.dart';
//
// class NotificationService extends getx.GetxService {
//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//   // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;  // Temporarily commented
//   final StorageService _storageService = getx.Get.find<StorageService>();
//
//   String? _fcmToken;
//   String? get fcmToken => _fcmToken;
//
//   @override
//   Future<void> onInit() async {
//     super.onInit();
//     await _initializeLocalNotifications();
//     // await _initializeFirebaseMessaging();  // Temporarily commented
//   }
//
//   Future<void> _initializeLocalNotifications() async {
//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );
//   }
//
//   // Temporarily commented Firebase methods
//   /*
//   Future<void> _initializeFirebaseMessaging() async {
//     // Request permission for iOS
//     if (Platform.isIOS) {
//       await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );
//     }
//
//     // Get FCM token
//     _fcmToken = await _firebaseMessaging.getToken();
//
//     // Listen for token refresh
//     _firebaseMessaging.onTokenRefresh.listen((token) {
//       _fcmToken = token;
//     });
//
//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
//
//     // Handle background messages
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
//   }
//   */
//
//   Future<bool> requestPermission() async {
//     if (Platform.isAndroid) {
//       final androidPlugin =
//           _localNotifications.resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();
//
//       if (androidPlugin != null) {
//         final bool? granted =
//             await androidPlugin.requestNotificationsPermission();
//         return granted ?? false;
//       }
//       return true;
//     } else if (Platform.isIOS) {
//       final iosPlugin =
//           _localNotifications.resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>();
//       final granted = await iosPlugin?.requestPermissions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//       return granted ?? false;
//     }
//     return true;
//   }
//
//   Future<void> showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//     String? channelId,
//     String? channelName,
//     Priority priority = Priority.defaultPriority,
//     Importance importance = Importance.defaultImportance,
//   }) async {
//     final androidDetails = AndroidNotificationDetails(
//       channelId ?? 'default_channel',
//       channelName ?? 'Default Notifications',
//       importance: importance,
//       priority: priority,
//       showWhen: true,
//     );
//
//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     final notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _localNotifications.show(
//       id,
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//   }
//
//   Future<void> showOrderNotification({
//     required String orderId,
//     required String title,
//     required String body,
//   }) async {
//     await showLocalNotification(
//       id: orderId.hashCode,
//       title: title,
//       body: body,
//       payload: 'order:$orderId',
//       channelId: 'order_channel',
//       channelName: 'Order Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//   }
//
//   Future<void> showDeliveryNotification({
//     required String orderId,
//     required String title,
//     required String body,
//   }) async {
//     await showLocalNotification(
//       id: 'delivery_$orderId'.hashCode,
//       title: title,
//       body: body,
//       payload: 'delivery:$orderId',
//       channelId: 'delivery_channel',
//       channelName: 'Delivery Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//   }
//
//   void _onNotificationTapped(NotificationResponse response) {
//     final payload = response.payload;
//     if (payload != null) {
//       _handleNotificationPayload(payload);
//     }
//   }
//
//   void _handleNotificationPayload(String payload) {
//     if (payload.startsWith('order:')) {
//       final orderId = payload.split(':')[1];
//       getx.Get.toNamed('/order_detail', arguments: {'orderId': orderId});
//     } else if (payload.startsWith('delivery:')) {
//       final orderId = payload.split(':')[1];
//       getx.Get.toNamed('/order_tracking', arguments: {'orderId': orderId});
//     }
//   }
//
//   Future<void> cancelNotification(int id) async {
//     await _localNotifications.cancel(id);
//   }
//
//   Future<void> cancelAllNotifications() async {
//     await _localNotifications.cancelAll();
//   }
//
//   // Settings management
//   bool get notificationsEnabled {
//     return _storageService.readBoolWithDefault(
//       StorageConstants.notificationsEnabled,
//       true,
//     );
//   }
//
//   Future<void> setNotificationsEnabled(bool enabled) async {
//     await _storageService.writeBool(
//       StorageConstants.notificationsEnabled,
//       enabled,
//     );
//   }
// }
