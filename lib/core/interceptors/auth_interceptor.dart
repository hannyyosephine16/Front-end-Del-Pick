// lib/core/interceptors/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  AuthInterceptor(this._storageService);

  // Cache token untuk menghindari storage reads berulang
  String? _cachedToken;
  DateTime? _lastTokenCheck;
  static const Duration _tokenCacheTimeout = Duration(minutes: 1);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get cached token or fetch from storage
    final token = _getCachedToken();

    if (token?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Set common headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful responses
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Check if response contains a new token (from login/register)
      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final dynamic responseData = data['data'];
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('token')) {
          final String newToken = responseData['token'];
          _updateToken(newToken);

          // Also update user data if present
          if (responseData.containsKey('user')) {
            _updateUserData(responseData['user']);
          }
        }
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle authentication errors sesuai dengan backend response
    if (err.response?.statusCode == 401) {
      _handleUnauthorized(err);
    } else if (err.response?.statusCode == 403) {
      _handleForbidden(err);
    }
    handler.next(err);
  }

  // Get cached token with timeout
  String? _getCachedToken() {
    final now = DateTime.now();

    // Refresh cache if expired
    if (_lastTokenCheck == null ||
        now.difference(_lastTokenCheck!).compareTo(_tokenCacheTimeout) > 0) {
      _cachedToken = _storageService.readString(StorageConstants.authToken);
      _lastTokenCheck = now;
    }

    return _cachedToken;
  }

  // Update token in storage and cache
  void _updateToken(String token) {
    _cachedToken = token;
    _storageService.writeString(StorageConstants.authToken, token);
    _storageService.writeBool(StorageConstants.isLoggedIn, true);
  }

  // Update user data from response
  void _updateUserData(Map<String, dynamic> userData) {
    if (userData.containsKey('id')) {
      _storageService.writeString(
          StorageConstants.userId, userData['id'].toString());
    }
    if (userData.containsKey('role')) {
      _storageService.writeString(StorageConstants.userRole, userData['role']);
    }
    if (userData.containsKey('email')) {
      _storageService.writeString(
          StorageConstants.userEmail, userData['email']);
    }
    if (userData.containsKey('name')) {
      _storageService.writeString(StorageConstants.userName, userData['name']);
    }
    if (userData.containsKey('phone')) {
      _storageService.writeString(
          StorageConstants.userPhone, userData['phone']);
    }
    if (userData.containsKey('avatar')) {
      _storageService.writeString(
          StorageConstants.userAvatar, userData['avatar']);
    }
  }

  void _handleUnauthorized(DioException err) {
    // Check if it's a token expiration error
    final data = err.response?.data;
    bool isTokenExpired = false;

    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().toLowerCase() ?? '';
      final code = data['code']?.toString().toLowerCase() ?? '';

      // Check for common token expiration indicators from backend
      isTokenExpired = message.contains('token') &&
              (message.contains('expired') ||
                  message.contains('invalid') ||
                  message.contains('unauthorized')) ||
          code == 'unauthorized' ||
          code == 'token_expired';
    }

    if (isTokenExpired) {
      // Clear stored authentication data
      _clearAuthData();

      // Check if we're not already on auth screens
      final String currentRoute = getx.Get.currentRoute;
      if (!_isAuthRoute(currentRoute)) {
        // Navigate to login screen with appropriate message
        getx.Get.offAllNamed(Routes.LOGIN);

        getx.Get.snackbar(
          'Sesi Berakhir',
          'Silakan login kembali untuk melanjutkan',
          snackPosition: getx.SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: getx.Get.theme.colorScheme.error,
          colorText: getx.Get.theme.colorScheme.onError,
        );
      }
    }
  }

  void _handleForbidden(DioException err) {
    // Handle forbidden access
    final data = err.response?.data;
    String message = 'Anda tidak memiliki izin untuk melakukan tindakan ini';

    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'];
    }

    getx.Get.snackbar(
      'Akses Ditolak',
      message,
      snackPosition: getx.SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: getx.Get.theme.colorScheme.error,
      colorText: getx.Get.theme.colorScheme.onError,
    );
  }

  void _clearAuthData() {
    // Clear cache
    _cachedToken = null;
    _lastTokenCheck = null;

    // Clear all authentication related data
    final keysToRemove = [
      StorageConstants.authToken,
      StorageConstants.refreshToken,
      StorageConstants.userId,
      StorageConstants.userRole,
      StorageConstants.userEmail,
      StorageConstants.userName,
      StorageConstants.userPhone,
      StorageConstants.userAvatar,
      StorageConstants.lastLoginTime,
    ];

    for (final key in keysToRemove) {
      _storageService.remove(key);
    }

    _storageService.writeBool(StorageConstants.isLoggedIn, false);
  }

  // Check if current route is an auth route
  bool _isAuthRoute(String route) {
    const authRoutes = [
      Routes.LOGIN,
      Routes.REGISTER,
      Routes.SPLASH,
      Routes.ONBOARDING,
    ];
    return authRoutes.contains(route);
  }

  // Clear cache (call this on manual logout)
  void clearCache() {
    _cachedToken = null;
    _lastTokenCheck = null;
  }
}
