// lib/core/utils/error_utils.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/core/errors/failures.dart';
import 'package:del_pick/core/errors/error_handler.dart';

/// Utility class untuk menangani error secara konsisten
class ErrorUtils {
  /// Show error message sebagai snackbar
  static void showErrorSnackbar(Failure failure, {Duration? duration}) {
    final message = ErrorHandler.getErrorMessage(failure);
    final category = ErrorHandler.getErrorCategory(failure);

    Color backgroundColor;
    Color textColor;
    IconData icon;

    // Set colors and icon based on error category
    switch (category) {
      case 'network':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.wifi_off;
        break;
      case 'authentication':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.lock_outline;
        break;
      case 'validation':
        backgroundColor = Colors.amber;
        textColor = Colors.black87;
        icon = Icons.warning;
        break;
      case 'business_logic':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        icon = Icons.info_outline;
        break;
      case 'server':
        backgroundColor = Colors.red.shade700;
        textColor = Colors.white;
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = Colors.grey.shade600;
        textColor = Colors.white;
        icon = Icons.help_outline;
    }

    Get.snackbar(
      _getErrorTitle(category),
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration ?? const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(icon, color: textColor),
      shouldIconPulse: false,
      barBlur: 10,
    );
  }

  /// Show error dialog dengan retry option
  static void showErrorDialog(
    Failure failure, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    String? customTitle,
    String? customMessage,
  }) {
    final message = customMessage ?? ErrorHandler.getErrorMessage(failure);
    final title =
        customTitle ?? _getErrorTitle(ErrorHandler.getErrorCategory(failure));
    final isRecoverable = ErrorHandler.isRecoverable(failure);

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              _getErrorIcon(ErrorHandler.getErrorCategory(failure)),
              color: Get.theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (onDismiss != null || !isRecoverable)
            TextButton(
              onPressed: onDismiss ?? () => Get.back(),
              child: const Text('Tutup'),
            ),
          if (isRecoverable && onRetry != null)
            ElevatedButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: const Text('Coba Lagi'),
            ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Show validation errors dalam bentuk list
  static void showValidationErrors(ValidationFailure failure) {
    if (failure.errors == null || failure.errors!.isEmpty) {
      showErrorSnackbar(failure);
      return;
    }

    final errors = failure.errors!;
    final errorList = <String>[];

    errors.forEach((field, messages) {
      errorList.addAll(messages);
    });

    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.amber),
            SizedBox(width: 8),
            Text('Kesalahan Validasi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Silakan perbaiki kesalahan berikut:'),
            const SizedBox(height: 12),
            ...errorList.map((error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(error)),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show connection error dengan retry dan settings option
  static void showConnectionError({VoidCallback? onRetry}) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Tidak Ada Koneksi'),
          ],
        ),
        content: const Text(
          'Periksa koneksi internet Anda dan coba lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: const Text('Coba Lagi'),
            ),
        ],
      ),
    );
  }

  /// Handle error secara otomatis berdasarkan type
  static void handleError(
    Failure failure, {
    VoidCallback? onRetry,
    bool showDialog = false,
    bool logError = true,
  }) {
    // Log error if needed
    if (logError) {
      ErrorHandler.logError(failure, StackTrace.current);
    }

    // Handle authentication errors
    if (ErrorHandler.requiresAuth(failure)) {
      _handleAuthError(failure);
      return;
    }

    // Handle validation errors
    if (failure is ValidationFailure) {
      showValidationErrors(failure);
      return;
    }

    // Handle connection errors
    if (failure is ConnectionFailure) {
      if (showDialog) {
        showConnectionError(onRetry: onRetry);
      } else {
        showErrorSnackbar(failure);
      }
      return;
    }

    // Handle other errors
    if (showDialog && ErrorHandler.isRecoverable(failure)) {
      showErrorDialog(failure, onRetry: onRetry);
    } else {
      showErrorSnackbar(failure);
    }
  }

  /// Handle authentication errors
  static void _handleAuthError(Failure failure) {
    if (failure is TokenExpiredFailure || failure is UnauthorizedFailure) {
      Get.snackbar(
        'Sesi Berakhir',
        'Silakan login kembali untuk melanjutkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.logout, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } else {
      showErrorSnackbar(failure);
    }
  }

  /// Get error title berdasarkan category
  static String _getErrorTitle(String category) {
    switch (category) {
      case 'network':
        return 'Masalah Koneksi';
      case 'authentication':
        return 'Masalah Autentikasi';
      case 'validation':
        return 'Kesalahan Input';
      case 'business_logic':
        return 'Informasi';
      case 'server':
        return 'Kesalahan Server';
      default:
        return 'Kesalahan';
    }
  }

  /// Get error icon berdasarkan category
  static IconData _getErrorIcon(String category) {
    switch (category) {
      case 'network':
        return Icons.wifi_off;
      case 'authentication':
        return Icons.lock_outline;
      case 'validation':
        return Icons.warning;
      case 'business_logic':
        return Icons.info_outline;
      case 'server':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  /// Create error widget untuk UI
  static Widget createErrorWidget(
    Failure failure, {
    VoidCallback? onRetry,
    double? height,
  }) {
    final message = ErrorHandler.getErrorMessage(failure);
    final category = ErrorHandler.getErrorCategory(failure);
    final isRecoverable = ErrorHandler.isRecoverable(failure);

    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getErrorIcon(category),
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _getErrorTitle(category),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (isRecoverable && onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ],
      ),
    );
  }

  /// Show success message
  static void showSuccessSnackbar(String message, {Duration? duration}) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show info message
  static void showInfoSnackbar(String message, {Duration? duration}) {
    Get.snackbar(
      'Informasi',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show warning message
  static void showWarningSnackbar(String message, {Duration? duration}) {
    Get.snackbar(
      'Peringatan',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
