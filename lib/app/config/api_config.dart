// app/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:5000';
  static const String apiVersion = '/api/v1';

  // HTTP Configuration only
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}