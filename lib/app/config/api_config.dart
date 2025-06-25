// app/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:5000';
  static const String apiVersion = '/api/v1';

  // HTTP Configuration only
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

  static Map<String, String> getAuthHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  static Map<String, String> get multipartHeaders => {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      };
}
