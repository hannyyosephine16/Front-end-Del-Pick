// lib/core/services/api/auth_service.dart
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/models/auth/login_request_model.dart';
import '../../../data/models/auth/login_response_model.dart';
import '../../../data/models/auth/register_request_model.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/models/auth/profile_update_model.dart';
import '../../constants/api_endpoints.dart';
import 'base_api_service.dart';

class AuthService extends ApiService {
  static AuthService get to => Get.find();

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.data != null && response.data['data'] != null) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel> register(RegisterRequestModel request) async {
    try {
      final response = await post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      if (response.data != null && response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await get(ApiEndpoints.profile);

      if (response.data != null && response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel> updateProfile(ProfileUpdateModel request) async {
    try {
      final response = await put(
        ApiEndpoints.profile,
        data: request.toJson(),
      );

      if (response.data != null && response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Invalid response format');
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
      print('Logout error: $e');
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await put(
        ApiEndpoints.updateFcmToken,
        data: {'fcm_token': fcmToken},
      );
    } catch (e) {
      print('FCM token update error: $e');
    }
  }

  Exception _handleAuthError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return Exception('Email atau password salah');
      } else if (error.response?.statusCode == 400) {
        return Exception(
            error.response?.data?['message'] ?? 'Data tidak valid');
      } else if (error.response?.statusCode == 500) {
        return Exception('Terjadi kesalahan pada server');
      }
      return Exception(
          error.response?.data?['message'] ?? 'Terjadi kesalahan jaringan');
    }
    return Exception('Terjadi kesalahan tidak dikenal');
  }
}
