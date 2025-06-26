// lib/core/interceptors/logging_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('*** Request ***');
      print('${options.method.toUpperCase()} ${options.uri}');
      if (options.headers.isNotEmpty) {
        print('Headers:');
        options.headers.forEach((key, value) {
          // Don't log sensitive headers
          if (key.toLowerCase() == 'authorization') {
            print('  $key: Bearer ***');
          } else {
            print('  $key: $value');
          }
        });
      }
      if (options.data != null) {
        print('Data: ${options.data}');
      }
      print('');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('*** Response ***');
      print('uri: ${response.requestOptions.uri}');
      print('Response Text:');
      print('${response.data}');
      print('');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('*** DioException ***:');
      print('uri: ${err.requestOptions.uri}');
      print('$err');
      if (err.response != null) {
        print('Response data: ${err.response?.data}');
        print('Response status: ${err.response?.statusCode}');
      }
      print('');
    }
    super.onError(err, handler);
  }
}
