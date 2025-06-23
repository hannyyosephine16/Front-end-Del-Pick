// // lib/core/services/api/base_api_service.dart
// import 'package:dio/dio.dart';
// import 'package:del_pick/core/services/local/storage_service.dart';
// import 'package:del_pick/core/constants/storage_constants.dart';
// import 'package:get/get.dart';
//
// abstract class BaseApiService {
//   late final Dio dio;
//   final StorageService _storageService = Get.find<StorageService>();
//
//   // Override this in child classes
//   String get endpoint;
//
//   BaseApiService() {
//     dio = Dio();
//     _setupInterceptors();
//   }
//
//   void _setupInterceptors() {
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // Add auth header if token exists
//           final token = _storageService.readString(StorageConstants.accessToken);
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//
//           // Add content type
//           options.headers['Content-Type'] = 'application/json';
//
//           // Add base URL if not already present
//           if (!options.path.startsWith('http')) {
//             options.baseUrl = _getBaseUrl();
//           }
//
//           handler.next(options);
//         },
//         onError: (error, handler) async {
//           // Handle 401 errors (unauthorized)
//           if (error.response?.statusCode == 401) {
//             // Token expired, redirect to login
//             _handleUnauthorized();
//           }
//           handler.next(error);
//         },
//       ),
//     );
//   }
//
//   String _getBaseUrl() {
//     // Replace with your actual backend URL
//     return 'http://your-backend-url.com/api/v1';
//     // For local development: 'http://localhost:5000/api/v1'
//     // For production: 'https://your-domain.com/api/v1'
//   }
//
//   void _handleUnauthorized() {
//     // Clear stored auth data
//     _storageService.remove(StorageConstants.accessToken);
//     _storageService.remove(StorageConstants.refreshToken);
//
//     // Redirect to login screen
//     Get.offAllNamed('/login');
//
//     Get.snackbar(
//       'Session Expired',
//       'Please login again',
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }
//
//   // Common HTTP methods
//   Future<Response> get(
//       String path, {
//         Map<String, dynamic>? queryParameters,
//         Options? options,
//       }) async {
//     return dio.get(
//       path,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
//
//   Future<Response> post(
//       String path, {
//         dynamic data,
//         Map<String, dynamic>? queryParameters,
//         Options? options,
//       }) async {
//     return dio.post(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
//
//   Future<Response> put(
//       String path, {
//         dynamic data,
//         Map<String, dynamic>? queryParameters,
//         Options? options,
//       }) async {
//     return dio.put(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
//
//   Future<Response> delete(
//       String path, {
//         dynamic data,
//         Map<String, dynamic>? queryParameters,
//         Options? options,
//       }) async {
//     return dio.delete(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
//
//   Future<Response> patch(
//       String path, {
//         dynamic data,
//         Map<String, dynamic>? queryParameters,
//         Options? options,
//       }) async {
//     return dio.patch(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
// }