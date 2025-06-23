// lib/data/repositories/notification_repository.dart - FIXED
import 'package:del_pick/data/providers/notification_provider.dart';
import 'package:del_pick/data/models/notification_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';
import '../../core/errors/error_handler.dart';

class NotificationRepository {
  final NotificationProvider _notificationProvider;

  NotificationRepository(this._notificationProvider);

  Future<Result<List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _notificationProvider.getNotifications();

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final notifications = (responseData['data'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        return Result.success(notifications);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to fetch notifications',
        );
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> markNotificationAsRead(int notificationId) async {
    try {
      final response =
          await _notificationProvider.markNotificationAsRead(notificationId);

      if (response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to mark notification as read',
        );
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> deleteNotification(int notificationId) async {
    try {
      final response =
          await _notificationProvider.deleteNotification(notificationId);

      if (response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to delete notification',
        );
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> updateFcmToken(String fcmToken) async {
    try {
      final response = await _notificationProvider.updateFcmToken(fcmToken);

      if (response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to update FCM token',
        );
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
