// lib/core/interceptors/error_interceptor.dart
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
      debugPrint('Response Data: ${err.response?.data}');
    }

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

    handler.next(err);
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

    // Skip if already showing similar error
    if (_isCurrentlyShowingSimilarError(failure)) {
      return true;
    }

    return false;
  }

  /// Check if similar error is already being shown
  bool _isCurrentlyShowingSimilarError(Failure failure) {
    // This is a simple check - you might want to implement more sophisticated logic
    // to prevent showing duplicate error messages
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

  /// Extract detailed error information from backend response
  Map<String, dynamic> _extractErrorDetails(DioException err) {
    final response = err.response;
    final data = response?.data;

    final details = <String, dynamic>{
      'statusCode': response?.statusCode,
      'message': 'An error occurred',
      'code': null,
      'errors': null,
    };

    if (data is Map<String, dynamic>) {
      // Extract message (backend format: { message: "...", code: "...", errors: {...} })
      if (data.containsKey('message')) {
        details['message'] = data['message'].toString();
      }

      // Extract error code
      if (data.containsKey('code')) {
        details['code'] = data['code'].toString();
      }

      // Extract validation errors
      if (data.containsKey('errors')) {
        details['errors'] = data['errors'];
      }
    } else if (data is String) {
      details['message'] = data;
    }

    return details;
  }

  /// Handle specific business logic errors that need special treatment
  void _handleBusinessLogicError(Map<String, dynamic> errorDetails) {
    final message = errorDetails['message'] as String;
    final code = errorDetails['code'] as String?;

    // Handle specific error codes from backend
    switch (code) {
      case 'ORDER_NOT_FOUND':
        _showOrderNotFoundDialog();
        break;
      case 'DRIVER_NOT_AVAILABLE':
        _showDriverNotAvailableDialog();
        break;
      case 'STORE_CLOSED':
        _showStoreClosedDialog(message);
        break;
      case 'ITEM_OUT_OF_STOCK':
        _showItemOutOfStockDialog(message);
        break;
      // Add more specific error handlers as needed
    }
  }

  /// Show order not found dialog
  void _showOrderNotFoundDialog() {
    getx.Get.dialog(
      AlertDialog(
        title: const Text('Pesanan Tidak Ditemukan'),
        content: const Text(
            'Pesanan yang Anda cari tidak ditemukan. Mungkin sudah dihapus atau dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => getx.Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show driver not available dialog
  void _showDriverNotAvailableDialog() {
    getx.Get.dialog(
      AlertDialog(
        title: const Text('Driver Tidak Tersedia'),
        content: const Text(
            'Maaf, saat ini tidak ada driver yang tersedia di area Anda. Silakan coba lagi nanti.'),
        actions: [
          TextButton(
            onPressed: () => getx.Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show store closed dialog
  void _showStoreClosedDialog(String message) {
    getx.Get.dialog(
      AlertDialog(
        title: const Text('Toko Tutup'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => getx.Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show item out of stock dialog
  void _showItemOutOfStockDialog(String message) {
    getx.Get.dialog(
      AlertDialog(
        title: const Text('Stok Habis'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => getx.Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
