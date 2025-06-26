// lib/core/services/api/auth_service.dart - SIMPLIFIED FOR DIRECT LOGIN
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/models/auth/login_request_model.dart';
import '../../../data/models/auth/login_response_model.dart';
import '../../../data/models/auth/user_model.dart';
import '../../constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ApiService {
  static AuthService get to => Get.find();

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 AuthService.login called');
        debugPrint('📤 Request: ${request.toJson()}');
      }

      final response = await post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (kDebugMode) {
        debugPrint('✅ Raw response received');
        debugPrint('📥 Status: ${response.statusCode}');
        debugPrint('📥 Data keys: ${response.data?.keys?.toList()}');
      }

      // ✅ DIRECT PARSING - handle the exact backend response format
      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        if (kDebugMode) {
          debugPrint('📝 Response data structure:');
          debugPrint('  - message: ${responseData['message']}');
          debugPrint('  - data: ${responseData['data']?.runtimeType}');
          if (responseData['data'] != null) {
            final data = responseData['data'] as Map<String, dynamic>;
            debugPrint(
                '  - token: ${data['token']?.toString().substring(0, 20)}...');
            debugPrint('  - user: ${data['user']?.runtimeType}');
            debugPrint('  - driver: ${data['driver']?.runtimeType}');
            debugPrint('  - store: ${data['store']?.runtimeType}');
          }
        }

        // ✅ Extract data section from backend response
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          return LoginResponseModel.fromJson(data);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Response is null');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException in login:');
        debugPrint('  - Type: ${e.type}');
        debugPrint('  - Message: ${e.message}');
        debugPrint('  - Response: ${e.response?.data}');
      }
      throw _handleAuthError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ General exception in login: $e');
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await get(ApiEndpoints.profile);

      if (response.data != null && response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Invalid profile response format');
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> logout() async {
    try {
      await post(ApiEndpoints.logout);
    } catch (e) {
      // Even if logout fails on server, we'll clear local data
      if (kDebugMode) {
        debugPrint('Logout error: $e');
      }
    }
  }

  Exception _handleAuthError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      if (statusCode == 401) {
        return Exception('Email atau password salah');
      } else if (statusCode == 400) {
        String message = 'Data tidak valid';
        if (responseData is Map<String, dynamic> &&
            responseData['message'] != null) {
          message = responseData['message'];
        }
        return Exception(message);
      } else if (statusCode == 500) {
        return Exception('Terjadi kesalahan pada server');
      }

      // Extract message from response if available
      String message = 'Terjadi kesalahan jaringan';
      if (responseData is Map<String, dynamic> &&
          responseData['message'] != null) {
        message = responseData['message'];
      }
      return Exception(message);
    }
    return Exception('Terjadi kesalahan tidak dikenal: $error');
  }
}

// // lib/core/services/api/auth_service.dart
// import 'package:del_pick/core/services/api/api_service.dart';
// import 'package:dio/dio.dart';
// import 'package:get/get.dart';
// import '../../../data/models/auth/login_request_model.dart';
// import '../../../data/models/auth/login_response_model.dart';
// import '../../../data/models/auth/register_request_model.dart';
// import '../../../data/models/auth/user_model.dart';
// import '../../../data/models/auth/profile_update_model.dart';
// import '../../constants/api_endpoints.dart';
// import 'base_api_service.dart';
//
// class AuthService extends ApiService {
//   static AuthService get to => Get.find();
//
//   Future<LoginResponseModel> login(LoginRequestModel request) async {
//     try {
//       final response = await post(
//         ApiEndpoints.login,
//         data: request.toJson(),
//       );
//
//       if (response.data != null && response.data['data'] != null) {
//         return LoginResponseModel.fromJson(response.data);
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   Future<UserModel> register(RegisterRequestModel request) async {
//     try {
//       final response = await post(
//         ApiEndpoints.register,
//         data: request.toJson(),
//       );
//
//       if (response.data != null && response.data['data'] != null) {
//         return UserModel.fromJson(response.data['data']);
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   Future<UserModel> getProfile() async {
//     try {
//       final response = await get(ApiEndpoints.profile);
//
//       if (response.data != null && response.data['data'] != null) {
//         return UserModel.fromJson(response.data['data']);
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   Future<UserModel> updateProfile(ProfileUpdateModel request) async {
//     try {
//       final response = await put(
//         ApiEndpoints.profile,
//         data: request.toJson(),
//       );
//
//       if (response.data != null && response.data['data'] != null) {
//         return UserModel.fromJson(response.data['data']);
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   Future<void> logout() async {
//     try {
//       await post(ApiEndpoints.logout);
//     } catch (e) {
//       // Even if logout fails on server, we'll clear local data
//       print('Logout error: $e');
//     }
//   }
//
//   Future<void> updateFcmToken(String fcmToken) async {
//     try {
//       await put(
//         ApiEndpoints.updateFcmToken,
//         data: {'fcm_token': fcmToken},
//       );
//     } catch (e) {
//       print('FCM token update error: $e');
//     }
//   }
//
//   Exception _handleAuthError(dynamic error) {
//     if (error is DioException) {
//       if (error.response?.statusCode == 401) {
//         return Exception('Email atau password salah');
//       } else if (error.response?.statusCode == 400) {
//         return Exception(
//             error.response?.data?['message'] ?? 'Data tidak valid');
//       } else if (error.response?.statusCode == 500) {
//         return Exception('Terjadi kesalahan pada server');
//       }
//       return Exception(
//           error.response?.data?['message'] ?? 'Terjadi kesalahan jaringan');
//     }
//     return Exception('Terjadi kesalahan tidak dikenal');
//   }
// }
