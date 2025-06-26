// lib/core/interceptors/error_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('ErrorInterceptor: ${err.type} - ${err.message}');
      print('Response Status: ${err.response?.statusCode}');
      print('Response Data: ${err.response?.data}');
      print('Error Type: ${err.type}');
      print('Error Message: ${err.message ?? "No message"}');
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Validate response structure
    if (response.data != null) {
      try {
        // Ensure response is valid JSON and has expected structure
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          // Log successful response in debug mode
          if (kDebugMode) {
            print(
                '✅ ${response.requestOptions.method} Success: ${response.requestOptions.uri}');
            print('Status: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Response validation error: $e');
        }
        // Don't throw error, let the response pass through
      }
    }

    super.onResponse(response, handler);
  }
}
