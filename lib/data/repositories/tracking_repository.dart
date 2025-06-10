// lib/data/repositories/tracking_repository.dart
import 'package:del_pick/data/providers/tracking_provider.dart';
import 'package:del_pick/data/models/tracking/tracking_info_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/data/providers/tracking_provider.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';

import '../../core/errors/error_handler.dart';

class TrackingRepository {
  final TrackingProvider _trackingProvider;

  TrackingRepository(this._trackingProvider);
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
  // Future<Result<Map<String, dynamic>>> getTrackingInfo(int orderId) async {
  //   try {
  //     final response = await _trackingProvider.getTrackingInfo(orderId);
  //
  //     if (response.statusCode == 200) {
  //       return Result.success(response.data['data']);
  //     } else {
  //       return Result.failure(
  //         response.data['message'] ?? 'Failed to get tracking data',
  //       );
  //     }
  //   } catch (e) {
  //     return Result.failure(e.toString());
  //   }
  // }

  // Future<Result<void>> startDelivery(int orderId) async {
  //   try {
  //     final response = await _trackingProvider.startDelivery(orderId);
  //
  //     if (response.statusCode == 200) {
  //       return Result.success(null);
  //     } else {
  //       return Result.failure(
  //         response.data['message'] ?? 'Failed to start delivery',
  //       );
  //     }
  //   } catch (e) {
  //     return Result.failure(e.toString());
  //   }
  // }

  // Future<Result<void>> completeDelivery(int orderId) async {
  //   try {
  //     final response = await _trackingProvider.completeDelivery(orderId);
  //
  //     if (response.statusCode == 200) {
  //       return Result.success(null);
  //     } else {
  //       return Result.failure(
  //         response.data['message'] ?? 'Failed to complete delivery',
  //       );
  //     }
  //   } catch (e) {
  //     return Result.failure(e.toString());
  //   }
  // }

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
}

// class TrackingRepository {
//   final TrackingProvider _trackingProvider;
//
//   TrackingRepository(this._trackingProvider);
//
//   Future<Result<TrackingInfoModel>> getTrackingInfo(int orderId) async {
//     try {
//       final response = await _trackingProvider.getTrackingInfo(orderId);
//
//       if (response.statusCode == 200) {
//         final trackingInfo = TrackingInfoModel.fromJson(response.data['data']);
//         return Result.success(trackingInfo);
//       } else {
//         return Result.failure(
//           response.data['message'] ?? 'Failed to get tracking info',
//         );
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//

// }
