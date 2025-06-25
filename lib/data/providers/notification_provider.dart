// lib/data/providers/notification_provider.dart
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:get/get.dart' as getx;

class NotificationProvider {
  final ApiService _apiService = getx.Get.find<ApiService>();

  Future<Response> getNotifications() async {
    return await _apiService.get(ApiEndpoints.notifications);
  }

  Future<Response> markNotificationAsRead(int notificationId) async {
    return await _apiService
        .patch(ApiEndpoints.markNotificationAsRead(notificationId));
  }

  Future<Response> deleteNotification(int notificationId) async {
    return await _apiService
        .delete(ApiEndpoints.deleteNotification(notificationId));
  }

  Future<Response> updateFcmToken(String fcmToken) async {
    return await _apiService.put(
      ApiEndpoints.updateFcmToken,
      data: {'fcm_token': fcmToken},
    );
  }
}
