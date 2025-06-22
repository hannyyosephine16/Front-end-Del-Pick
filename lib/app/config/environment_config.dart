// lib/app/config/environment_config.dart - FIXED TO MATCH BACKEND
class EnvironmentConfig {
  // API Configuration (sesuai backend server.js dan routes)
  static const String baseUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String socketUrl = 'https://delpick.horas-code.my.id';
  static const bool enableLogging = true;

  // Development settings
  static const bool enableMockData = false;
  static const bool enableApiLogging = true;
  static const bool enableErrorReporting = false;

  // Environment-specific settings
  static const String environment = 'production';
  static const String apiVersion = 'v1';

  // WebSocket configuration
  static const String socketNamespace = '/';
  static const bool autoConnect = true;
  static const int reconnectAttempts = 5;
  static const int reconnectDelay = 5000; // 5 seconds
}
