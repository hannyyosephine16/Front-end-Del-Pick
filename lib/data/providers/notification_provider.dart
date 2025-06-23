// // lib/data/providers/notification_provider.dart
// import 'package:dio/dio.dart';
//
// class NotificationProvider {
//   final ApiClient _apiClient;
//
//   NotificationProvider(this._apiClient);
//
//   Future<Response> getNotifications() async {
//     return await _apiClient.get('/users/notifications');
//   }
//
//   Future<Response> markNotificationAsRead(int notificationId) async {
//     return await _apiClient.patch('/users/notifications/$notificationId/read');
//   }
//
//   Future<Response> deleteNotification(int notificationId) async {
//     return await _apiClient.delete('/users/notifications/$notificationId');
//   }
//
//   Future<Response> updateFcmToken(String fcmToken) async {
//     return await _apiClient.put('/users/fcm-token', data: {
//       'fcm_token': fcmToken,
//     });
//   }
// }
