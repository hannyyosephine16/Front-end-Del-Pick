// lib/core/interceptors/error_interceptor.dart - FIXED
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/errors/failures.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('ErrorInterceptor: ${err.toString()}');
      debugPrint('Response Status: ${err.response?.statusCode}');
      debugPrint('Response Data: ${err.response?.data}');
      debugPrint('Error Type: ${err.type}');
      debugPrint('Error Message: ${err.message ?? 'No message'}');
    }

    // Handle null response gracefully
    if (err.response == null || err.response?.data == null) {
      _handleNullResponse(err);
      handler.next(err);
      return;
    }

    try {
      // Convert DioException to Failure using ErrorHandler
      final failure = ErrorHandler.handleException(err);

      // Show user-friendly error message
      _showErrorMessage(failure, err);

      // Log error for debugging/analytics
      ErrorHandler.logError(err, StackTrace.current, context: {
        'url': err.requestOptions.uri.toString(),
        'method': err.requestOptions.method,
        'statusCode': err.response?.statusCode,
        'errorType': err.type.toString(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in ErrorInterceptor: $e');
      }
      _handleNullResponse(err);
    }

    handler.next(err);
  }

  /// Handle case when response is null (connection issues)
  void _handleNullResponse(DioException err) {
    String title = 'Koneksi Bermasalah';
    String message = 'Tidak dapat terhubung ke server';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        title = 'Koneksi Timeout';
        message = 'Koneksi ke server timeout. Periksa internet Anda';
        break;
      case DioExceptionType.receiveTimeout:
        title = 'Timeout';
        message = 'Server tidak merespon. Coba lagi nanti';
        break;
      case DioExceptionType.sendTimeout:
        title = 'Timeout';
        message = 'Gagal mengirim data. Periksa koneksi internet';
        break;
      case DioExceptionType.connectionError:
        title = 'Tidak Ada Koneksi';
        message = 'Periksa koneksi internet Anda';
        break;
      case DioExceptionType.badCertificate:
        title = 'Keamanan';
        message = 'Masalah sertifikat keamanan server';
        break;
      case DioExceptionType.cancel:
        // Don't show error for cancelled requests
        return;
      case DioExceptionType.unknown:
      default:
        if (err.message?.contains('SocketException') == true) {
          title = 'Tidak Ada Internet';
          message = 'Periksa koneksi internet Anda';
        } else if (err.message?.contains('HandshakeException') == true) {
          title = 'Keamanan';
          message = 'Masalah keamanan koneksi';
        } else {
          title = 'Error Koneksi';
          message = 'Gagal terhubung ke server. Coba lagi nanti';
        }
        break;
    }

    _showSimpleErrorMessage(title, message);
  }

  /// Show simple error message for connection issues
  void _showSimpleErrorMessage(String title, String message) {
    final colorScheme = getx.Get.theme.colorScheme;

    getx.Get.snackbar(
      title,
      message,
      snackPosition: getx.SnackPosition.TOP,
      backgroundColor: colorScheme.error,
      colorText: colorScheme.onError,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      icon: Icon(
        Icons.wifi_off,
        color: colorScheme.onError,
      ),
    );
  }

  /// Show user-friendly error messages based on failure type
  void _showErrorMessage(Failure failure, DioException originalError) {
    // Don't show error messages for certain conditions
    if (_shouldSkipErrorMessage(failure, originalError)) {
      return;
    }

    final message = ErrorHandler.getErrorMessage(failure);
    final category = ErrorHandler.getErrorCategory(failure);

    // Determine snackbar color based on error category
    final colorScheme = getx.Get.theme.colorScheme;
    var backgroundColor = colorScheme.error;
    var textColor = colorScheme.onError;

    // Use different colors for different error types
    switch (category) {
      case 'network':
        backgroundColor = colorScheme.outline;
        textColor = colorScheme.onSurface;
        break;
      case 'validation':
        backgroundColor = colorScheme.tertiary;
        textColor = colorScheme.onTertiary;
        break;
      case 'business_logic':
        backgroundColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        break;
    }

    // Show error message with appropriate styling
    getx.Get.snackbar(
      _getErrorTitle(failure),
      message,
      snackPosition: getx.SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: _getErrorDuration(failure),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  /// Determine if error message should be skipped
  bool _shouldSkipErrorMessage(Failure failure, DioException originalError) {
    // Skip for certain status codes that are handled elsewhere
    final skipStatusCodes = [401]; // Auth errors handled by AuthInterceptor

    if (originalError.response?.statusCode != null &&
        skipStatusCodes.contains(originalError.response!.statusCode)) {
      return true;
    }

    // Skip for cancelled requests
    if (originalError.type == DioExceptionType.cancel) {
      return true;
    }

    return false;
  }

  /// Get appropriate title for error type
  String _getErrorTitle(Failure failure) {
    if (failure is ConnectionFailure) {
      return 'Koneksi Bermasalah';
    } else if (failure is TimeoutFailure) {
      return 'Waktu Habis';
    } else if (failure is ValidationFailure) {
      return 'Validasi Gagal';
    } else if (failure is ServerFailure) {
      return 'Error Server';
    } else if (failure is BusinessLogicFailure) {
      return 'Perhatian';
    } else if (failure is PermissionFailure) {
      return 'Izin Diperlukan';
    } else {
      return 'Error';
    }
  }

  /// Get appropriate duration for error type
  Duration _getErrorDuration(Failure failure) {
    if (failure is ConnectionFailure || failure is TimeoutFailure) {
      return const Duration(seconds: 5); // Longer for connection issues
    } else if (failure is ValidationFailure) {
      return const Duration(seconds: 4); // Medium for validation
    } else if (failure is BusinessLogicFailure) {
      return const Duration(seconds: 4); // Medium for business logic
    } else {
      return const Duration(seconds: 3); // Default
    }
  }
}
