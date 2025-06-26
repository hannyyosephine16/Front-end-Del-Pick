// lib/data/repositories/tracking_repository.dart
import 'package:del_pick/data/providers/tracking_provider.dart';
import 'package:del_pick/data/models/tracking/tracking_info_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';
import '../../core/errors/error_handler.dart';

class TrackingRepository {
  final TrackingProvider _trackingProvider;

  TrackingRepository(this._trackingProvider);

  /// Get tracking data for order - GET /orders/{id}/tracking
  Future<Result<TrackingInfoModel>> getTrackingInfo(int orderId) async {
    try {
      final response = await _trackingProvider.getTrackingData(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final trackingInfo = TrackingInfoModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
        return Result.success(trackingInfo, responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to get tracking info';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  /// Start delivery for order - POST /orders/{id}/tracking/start
  Future<Result<Map<String, dynamic>>> startDelivery(int orderId) async {
    try {
      final response = await _trackingProvider.startDelivery(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData['data'] as Map<String, dynamic>,
            responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message =
            responseData?['message'] as String? ?? 'Failed to start delivery';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  /// Complete delivery for order - POST /orders/{id}/tracking/complete
  Future<Result<Map<String, dynamic>>> completeDelivery(int orderId) async {
    try {
      final response = await _trackingProvider.completeDelivery(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData['data'] as Map<String, dynamic>,
            responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to complete delivery';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  /// Update driver location for order tracking - PUT /orders/{id}/tracking/location
  Future<Result<Map<String, dynamic>>> updateDriverLocation(
    int orderId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _trackingProvider.updateDriverLocation(
        orderId,
        latitude,
        longitude,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData['data'] as Map<String, dynamic>,
            responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to update driver location';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }

  /// Get tracking history for order - GET /orders/{id}/tracking/history
  Future<Result<Map<String, dynamic>>> getTrackingHistory(int orderId) async {
    try {
      final response = await _trackingProvider.getTrackingHistory(orderId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return Result.success(responseData['data'] as Map<String, dynamic>,
            responseData['message'] as String?);
      } else {
        final responseData = response.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String? ??
            'Failed to get tracking history';
        return Result.failure(message);
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      final failure = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()));
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    }
  }
}
