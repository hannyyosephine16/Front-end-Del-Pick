// lib/core/middleware/dio_connectivity_middleware.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/utils/helpers.dart';

/// Middleware untuk Dio HTTP client yang mengecek koneksi internet
class DioConnectivityMiddleware {
  static final ConnectivityService _connectivityService =
      getx.Get.find<ConnectivityService>();

  /// Get Dio interceptor untuk connectivity checking
  static InterceptorsWrapper getConnectivityInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Check internet connection before making request
        if (!_connectivityService.isConnected) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'No internet connection available',
              type: DioExceptionType.connectionError,
              message: 'Please check your internet connection and try again',
            ),
          );
          _showConnectionError();
          return;
        }

        // Add connection type to headers for debugging
        options.headers['X-Connection-Type'] =
            _connectivityService.primaryConnectionTypeString;

        handler.next(options);
      },
      onResponse: (response, handler) {
        // Handle successful response - could track connection quality here
        handler.next(response);
      },
      onError: (error, handler) {
        // Handle different types of connection errors
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
            _showTimeoutError();
            break;
          case DioExceptionType.connectionError:
            _showConnectionError();
            break;
          case DioExceptionType.receiveTimeout:
            _showReceiveTimeoutError();
            break;
          case DioExceptionType.sendTimeout:
            _showSendTimeoutError();
            break;
          default:
            // Let other errors pass through
            break;
        }

        handler.next(error);
      },
    );
  }

  /// Show connection error message
  static void _showConnectionError() {
    if (getx.Get.context != null) {
      Helpers.showErrorSnackbar(
        'No Internet Connection',
        'Please check your internet connection and try again',
        getx.Get.context!,
      );
    }
  }

  /// Show timeout error message
  static void _showTimeoutError() {
    if (getx.Get.context != null) {
      Helpers.showErrorSnackbar(
        'Connection Timeout',
        'The request took too long to complete. Please try again.',
        getx.Get.context!,
      );
    }
  }

  /// Show receive timeout error
  static void _showReceiveTimeoutError() {
    if (getx.Get.context != null) {
      Helpers.showErrorSnackbar(
        'Receive Timeout',
        'Server is taking too long to respond. Please try again.',
        getx.Get.context!,
      );
    }
  }

  /// Show send timeout error
  static void _showSendTimeoutError() {
    if (getx.Get.context != null) {
      Helpers.showErrorSnackbar(
        'Send Timeout',
        'Failed to send data. Please check your connection.',
        getx.Get.context!,
      );
    }
  }

  /// Check if device has internet connection
  static bool hasConnection() {
    return _connectivityService.isConnected;
  }

  /// Get connection type string
  static String getConnectionType() {
    return _connectivityService.primaryConnectionTypeString;
  }

  /// Get all connection types
  static List<String> getAllConnectionTypes() {
    return _connectivityService.connectionTypeStrings;
  }

  /// Show offline message when connection is lost
  static void showOfflineMessage() {
    if (getx.Get.context != null) {
      Helpers.showWarningSnackbar(
        'You\'re Offline',
        'Some features may not be available without internet connection',
        getx.Get.context!,
      );
    }
  }

  /// Show online message when connection is restored
  static void showOnlineMessage() {
    if (getx.Get.context != null) {
      Helpers.showSuccessSnackbar(
        'Back Online',
        'Internet connection restored (${_connectivityService.primaryConnectionTypeString})',
        getx.Get.context!,
      );
    }
  }

  /// Force check connectivity
  static Future<bool> forceCheckConnectivity() async {
    await _connectivityService.forceCheckConnectivity();
    return _connectivityService.isConnected;
  }

  /// Create a retry interceptor for failed requests due to connectivity
  static InterceptorsWrapper getRetryInterceptor({
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error) &&
            error.requestOptions.extra['retryCount'] == null) {
          // Initialize retry count
          error.requestOptions.extra['retryCount'] = 0;
        }

        final retryCount = error.requestOptions.extra['retryCount'] ?? 0;

        if (_shouldRetry(error) && retryCount < maxRetries) {
          // Increment retry count
          error.requestOptions.extra['retryCount'] = retryCount + 1;

          // Wait before retry
          await Future.delayed(retryDelay);

          // Check if connection is restored
          if (_connectivityService.isConnected) {
            try {
              // Retry the request
              final dio = Dio();
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // If retry fails, continue with original error
            }
          }
        }

        handler.next(error);
      },
    );
  }

  /// Determine if error should trigger a retry
  static bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }
}
