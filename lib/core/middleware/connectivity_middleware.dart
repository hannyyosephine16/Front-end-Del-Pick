// lib/core/middleware/connectivity_middleware.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/utils/helpers.dart';

/// Connectivity Middleware sesuai backend timeout & error handling
class DioConnectivityMiddleware {
  static final ConnectivityService _connectivityService =
      getx.Get.find<ConnectivityService>();

  /// Dio interceptor untuk connectivity checking - SESUAI BACKEND TIMEOUTS
  static InterceptorsWrapper getConnectivityInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Check internet connection before request
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

        // Add connection info to headers untuk backend debugging
        options.headers['X-Connection-Type'] =
            _connectivityService.primaryConnectionTypeString;
        options.headers['X-App-Version'] = '1.0.0';
        options.headers['X-Platform'] = 'mobile';

        // Set timeouts sesuai backend configuration (30 seconds)
        options.connectTimeout = const Duration(seconds: 30);
        options.receiveTimeout = const Duration(seconds: 30);
        options.sendTimeout = const Duration(seconds: 30);

        handler.next(options);
      },
      onResponse: (response, handler) {
        // Track successful responses
        handler.next(response);
      },
      onError: (error, handler) {
        // Handle errors sesuai backend error types
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
            _showTimeoutError(
                'Connection timeout. Server took too long to respond.');
            break;
          case DioExceptionType.connectionError:
            _showConnectionError();
            break;
          case DioExceptionType.receiveTimeout:
            _showTimeoutError(
                'Receive timeout. Server response took too long.');
            break;
          case DioExceptionType.sendTimeout:
            _showTimeoutError('Send timeout. Failed to send data to server.');
            break;
          case DioExceptionType.badResponse:
            _handleBadResponse(error);
            break;
          default:
            break;
        }

        handler.next(error);
      },
    );
  }

  /// Handle bad response sesuai backend error responses
  static void _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message'] ?? 'Server error occurred';

    switch (statusCode) {
      case 400:
        _showError('Bad Request', message);
        break;
      case 404:
        _showError('Not Found', 'The requested resource was not found');
        break;
      case 500:
        _showError('Server Error', 'Internal server error occurred');
        break;
      case 502:
        _showError('Bad Gateway', 'Server is temporarily unavailable');
        break;
      case 503:
        _showError('Service Unavailable', 'Server is under maintenance');
        break;
      default:
        _showError('Error', message);
    }
  }

  /// Show connection error
  static void _showConnectionError() {
    if (getx.Get.context != null) {
      Helpers.showErrorSnackbar(
        'No Internet Connection',
        'Please check your internet connection and try again',
        getx.Get.context!,
      );
    }
  }

  /// Show timeout error with specific message
  static void _showTimeoutError(String message) {
    if (getx.Get.context != null) {
      Helpers.showErrorSnackbar(
        'Connection Timeout',
        message,
        getx.Get.context!,
      );
    }
  }

  /// Show general error
  static void _showError(String title, String message) {
    if (getx.Get.context != null) {
      Helpers.showErrorSnackbar(title, message, getx.Get.context!);
    }
  }

  /// Connection status helpers
  static bool hasConnection() => _connectivityService.isConnected;
  static String getConnectionType() =>
      _connectivityService.primaryConnectionTypeString;

  /// Show offline/online messages
  static void showOfflineMessage() {
    if (getx.Get.context != null) {
      Helpers.showWarningSnackbar(
        'You\'re Offline',
        'Some features may not be available without internet connection',
        getx.Get.context!,
      );
    }
  }

  static void showOnlineMessage() {
    if (getx.Get.context != null) {
      Helpers.showSuccessSnackbar(
        'Back Online',
        'Internet connection restored (${_connectivityService.primaryConnectionTypeString})',
        getx.Get.context!,
      );
    }
  }

  /// Retry interceptor sesuai backend retry logic
  static InterceptorsWrapper getRetryInterceptor({
    int maxRetries = 3, // Sesuai backend maxRetryAttempts
    Duration retryDelay = const Duration(seconds: 2),
  }) {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error) &&
            error.requestOptions.extra['retryCount'] == null) {
          error.requestOptions.extra['retryCount'] = 0;
        }

        final retryCount = error.requestOptions.extra['retryCount'] ?? 0;

        if (_shouldRetry(error) && retryCount < maxRetries) {
          error.requestOptions.extra['retryCount'] = retryCount + 1;

          // Exponential backoff delay
          final delay = Duration(
            milliseconds:
                (retryDelay.inMilliseconds * (retryCount + 1)).toInt(),
          );
          await Future.delayed(delay);

          // Check if connection is restored
          if (_connectivityService.isConnected) {
            try {
              final dio = Dio();
              _setupBasicDio(dio);
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // Continue with original error if retry fails
            }
          }
        }

        handler.next(error);
      },
    );
  }

  /// Setup basic Dio configuration
  static void _setupBasicDio(Dio dio) {
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
  }

  /// Determine if error should trigger retry
  static bool _shouldRetry(DioException error) {
    // Retry for connection issues only
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.type == DioExceptionType.badResponse &&
            [502, 503, 504].contains(error.response?.statusCode));
  }

  /// Force connectivity check
  static Future<bool> forceCheckConnectivity() async {
    await _connectivityService.forceCheckConnectivity();
    return _connectivityService.isConnected;
  }

  /// Create configured Dio instance
  static Dio createConfiguredDio({
    String? baseUrl,
    Map<String, String>? headers,
  }) {
    final dio = Dio();

    // Base configuration sesuai backend
    dio.options.baseUrl = baseUrl ?? 'https://delpick.horas-code.my.id/api/v1';
    dio.options.headers.addAll(headers ?? {});

    // Add interceptors
    dio.interceptors.add(getConnectivityInterceptor());
    dio.interceptors.add(getRetryInterceptor());

    return dio;
  }

  /// Check if request should be cached (for offline functionality)
  static bool shouldCache(RequestOptions options) {
    // Cache GET requests for essential data
    return options.method.toUpperCase() == 'GET' &&
        (options.path.contains('/stores') ||
            options.path.contains('/menu') ||
            options.path.contains('/profile'));
  }

  /// Handle offline requests
  static Future<Response?> handleOfflineRequest(RequestOptions options) async {
    // Implement offline cache logic here if needed
    // For now, return null to indicate no cached response
    return null;
  }
}
