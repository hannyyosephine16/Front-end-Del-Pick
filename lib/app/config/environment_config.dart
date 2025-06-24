class EnvironmentConfig {
  // Backend URLs - PRODUCTION READY
  static const String productionUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String developmentUrl =
      'http://localhost:5000/api/v1'; // Untuk development lokal
  static const String stagingUrl =
      'https://staging.delpick.horas-code.my.id/api/v1'; // Jika ada staging

  // Socket URLs untuk real-time tracking
  static const String productionSocketUrl = 'https://delpick.horas-code.my.id';
  static const String developmentSocketUrl = 'http://localhost:5000';
  static const String stagingSocketUrl =
      'https://staging.delpick.horas-code.my.id';

  // Environment detection
  static const String environment =
      String.fromEnvironment('ENV', defaultValue: 'production');

  // Current URLs based on environment
  static String get currentBaseUrl {
    switch (environment) {
      case 'development':
        return developmentUrl;
      case 'staging':
        return stagingUrl;
      case 'production':
      default:
        return productionUrl; // Default ke production karena backend sudah live
    }
  }

  static String get currentSocketUrl {
    switch (environment) {
      case 'development':
        return developmentSocketUrl;
      case 'staging':
        return stagingSocketUrl;
      case 'production':
      default:
        return productionSocketUrl; // Default ke production
    }
  }

  // API Configuration sesuai backend
  static const String apiVersion = 'v1';
  static const bool enableLogging = true;
  static const bool enableApiLogging = true;
  static const bool enableErrorReporting = false;

  // Feature flags per environment
  static bool get enableMockData => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  // WebSocket configuration (untuk real-time tracking)
  static const String socketNamespace = '/';
  static const bool autoConnect = true;
  static const int reconnectAttempts = 5;
  static const int reconnectDelay = 5000;
}
