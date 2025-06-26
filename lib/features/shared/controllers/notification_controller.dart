// lib/features/shared/controllers/notification_controller.dart (FIXED - No Firebase)
import 'package:get/get.dart';
// import 'package:del_pick/data/models/notification/notification_model.dart';

class NotificationController extends GetxController {
  final RxInt _unreadCount = 0.obs;
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxBool _isLoading = false.obs;

  // Getters
  int get unreadCount => _unreadCount.value;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  // Load notifications from API
  Future<void> _loadNotifications() async {
    try {
      _isLoading.value = true;

      // TODO: Load notifications from API
      // final notifications = await _notificationRepository.getNotifications();
      // _notifications.assignAll(notifications);
      // _updateUnreadCount();

      print('Loading notifications from API...');
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Update unread count
  void updateUnreadCount(int count) {
    _unreadCount.value = count;
  }

  // Clear all notifications
  void clearNotifications() {
    _notifications.clear();
    _unreadCount.value = 0;
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // TODO: Update notification status in API
      // await _notificationRepository.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
      }

      print('Marked notification as read: $notificationId');
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // TODO: Update all notifications status in API
      // await _notificationRepository.markAllAsRead();

      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      _unreadCount.value = 0;

      print('Marked all notifications as read');
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // TODO: Delete notification from API
      // await _notificationRepository.deleteNotification(notificationId);

      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();

      print('Deleted notification: $notificationId');
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Add new notification (for testing or local notifications)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
  }

  // Update unread count based on current notifications
  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  // Handle notification tap
  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    markAsRead(notification.id);

    // Navigate based on notification type
    _navigateBasedOnNotificationType(notification);
  }

  // Navigate based on notification type
  void _navigateBasedOnNotificationType(NotificationModel notification) {
    try {
      switch (notification.type) {
        case NotificationType.order:
          if (notification.data['order_id'] != null) {
            Get.toNamed('/order-detail/${notification.data['order_id']}');
          }
          break;
        case NotificationType.delivery:
          if (notification.data['delivery_id'] != null) {
            Get.toNamed('/delivery-detail/${notification.data['delivery_id']}');
          }
          break;
        case NotificationType.promotion:
          if (notification.data['promotion_id'] != null) {
            Get.toNamed('/promotion/${notification.data['promotion_id']}');
          }
          break;
        case NotificationType.system:
          // Handle system notifications
          break;
        default:
          print('Unknown notification type: ${notification.type}');
      }
    } catch (e) {
      print('Error navigating from notification: $e');
    }
  }
}

// Notification Model
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.system,
      ),
      data: json['data'] ?? {},
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Notification Types
enum NotificationType {
  order,
  delivery,
  promotion,
  system,
}
