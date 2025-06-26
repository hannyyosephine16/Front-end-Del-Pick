// lib/data/repositories/auth_repository.dart - WITH AVATAR SUPPORT
import 'package:del_pick/core/services/api/auth_service.dart';
import 'package:del_pick/data/models/auth/login_request_model.dart';
import 'package:del_pick/data/models/auth/login_response_model.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/result.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // ✅ LOGIN
  Future<Result<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 AuthRepository.login called');
      }

      final request = LoginRequestModel(
        email: email,
        password: password,
      );

      final response = await _authService.login(request);

      if (kDebugMode) {
        debugPrint('✅ AuthRepository.login success');
        debugPrint('📝 User: ${response.user.name}');
        debugPrint('📝 Role: ${response.user.role}');
        debugPrint('📝 Avatar: ${response.user.avatar ?? 'No avatar'}');
      }

      return Result.success(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthRepository.login error: $e');
      }

      String errorMessage = 'Terjadi kesalahan saat login';
      if (e.toString().contains('Email atau password salah')) {
        errorMessage = 'Email atau password salah';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Periksa koneksi internet Anda';
      } else if (e.toString().contains('server')) {
        errorMessage = 'Terjadi kesalahan pada server';
      }

      return Result.failure(errorMessage);
    }
  }

  // ✅ GET PROFILE WITH AVATAR
  Future<Result<UserModel>> getProfile() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 AuthRepository.getProfile called');
      }

      final userModel = await _authService.getProfile();

      if (kDebugMode) {
        debugPrint('✅ AuthRepository.getProfile success');
        debugPrint('📝 User: ${userModel.name}');
        debugPrint('📝 Avatar: ${userModel.avatar ?? 'No avatar'}');
      }

      return Result.success(userModel);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthRepository.getProfile error: $e');
      }

      return Result.failure('Gagal mengambil profil pengguna');
    }
  }

  /// ✅ UPDATE PROFILE WITH AVATAR SUPPORT
  // Future<Result<UserModel>> updateProfile({
  //   String? name,
  //   String? email,
  //   String? phone,
  //   String? avatar,
  // })
  // async {
  //   try {
  //     if (kDebugMode) {
  //       debugPrint('🔄 AuthRepository.updateProfile called');
  //       debugPrint('📝 Name: $name');
  //       debugPrint('📝 Email: $email');
  //       debugPrint('📝 Phone: $phone');
  //       debugPrint(
  //           '📝 Avatar: ${avatar != null ? 'Base64 data provided' : 'No avatar'}');
  //     }
  //
  //     final updatedUser = await _authService.updateProfile(
  //       name: name,
  //       email: email,
  //       phone: phone,
  //       avatar: avatar,
  //     );
  //
  //     if (kDebugMode) {
  //       debugPrint('✅ AuthRepository.updateProfile success');
  //       debugPrint('📝 Updated user: ${updatedUser.name}');
  //       debugPrint('📝 Updated avatar: ${updatedUser.avatar ?? 'No avatar'}');
  //     }
  //
  //     return Result.success(updatedUser);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ AuthRepository.updateProfile error: $e');
  //     }
  //
  //     String errorMessage = 'Gagal memperbarui profil';
  //     if (e.toString().contains('email') && e.toString().contains('sudah')) {
  //       errorMessage = 'Email sudah digunakan';
  //     } else if (e.toString().contains('avatar') ||
  //         e.toString().contains('image')) {
  //       errorMessage = 'Gagal memperbarui foto profil';
  //     }
  //
  //     return Result.failure(errorMessage);
  //   }
  // }

  /// ✅ UPDATE AVATAR SPECIFICALLY
  // Future<Result<UserModel>> updateAvatar(String avatarBase64) async {
  //   try {
  //     if (kDebugMode) {
  //       debugPrint('🔄 AuthRepository.updateAvatar called');
  //     }
  //
  //     final updatedUser =
  //         await _authService.updateProfile(avatar: avatarBase64);
  //
  //     if (kDebugMode) {
  //       debugPrint('✅ AuthRepository.updateAvatar success');
  //       debugPrint('📝 New avatar: ${updatedUser.avatar ?? 'No avatar'}');
  //     }
  //
  //     return Result.success(updatedUser);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ AuthRepository.updateAvatar error: $e');
  //     }
  //
  //     return Result.failure('Gagal memperbarui foto profil');
  //   }
  // }

  /// ✅ UPDATE FCM TOKEN
  // Future<Result<bool>> updateFcmToken(String fcmToken) async {
  //   try {
  //     if (kDebugMode) {
  //       debugPrint('🔄 AuthRepository.updateFcmToken called');
  //     }
  //
  //     await _authService.updateFcmToken(fcmToken);
  //
  //     if (kDebugMode) {
  //       debugPrint('✅ AuthRepository.updateFcmToken success');
  //     }
  //
  //     return Result.success(true);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ AuthRepository.updateFcmToken error: $e');
  //     }
  //
  //     return Result.failure('Gagal memperbarui FCM token');
  //   }
  // }

  // ✅ LOGOUT
  Future<Result<bool>> logout() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 AuthRepository.logout called');
      }

      await _authService.logout();

      if (kDebugMode) {
        debugPrint('✅ AuthRepository.logout success');
      }

      return Result.success(true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthRepository.logout error: $e');
      }

      // Even if logout fails on server, we consider it success
      // because we'll clear local data anyway
      return Result.success(true);
    }
  }

  // ✅ REGISTER (if needed)
  // Future<Result<UserModel>> register({
  //   required String name,
  //   required String email,
  //   required String phone,
  //   required String password,
  //   required String role,
  // })
  // async {
  //   try {
  //     if (kDebugMode) {
  //       debugPrint('🔄 AuthRepository.register called');
  //       debugPrint('📝 Email: $email');
  //       debugPrint('📝 Role: $role');
  //     }
  //
  //     final response = await _authService.register(
  //       name: name,
  //       email: email,
  //       phone: phone,
  //       password: password,
  //       role: role,
  //     );
  //
  //     if (kDebugMode) {
  //       debugPrint('✅ AuthRepository.register success');
  //     }
  //
  //     return Result.success(response);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ AuthRepository.register error: $e');
  //     }
  //
  //     String errorMessage = 'Gagal mendaftar';
  //     if (e.toString().contains('email') && e.toString().contains('sudah')) {
  //       errorMessage = 'Email sudah terdaftar';
  //     } else if (e.toString().contains('phone') && e.toString().contains('sudah')) {
  //       errorMessage = 'Nomor telepon sudah terdaftar';
  //     }
  //
  //     return Result.failure(errorMessage);
  //   }
  // }

  // ✅ FORGOT PASSWORD
  // Future<Result<bool>> forgotPassword(String email) async {
  //   try {
  //     if (kDebugMode) {
  //       debugPrint('🔄 AuthRepository.forgotPassword called');
  //     }
  //
  //     await _authService.forgotPassword(email);
  //
  //     if (kDebugMode) {
  //       debugPrint('✅ AuthRepository.forgotPassword success');
  //     }
  //
  //     return Result.success(true);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ AuthRepository.forgotPassword error: $e');
  //     }
  //
  //     String errorMessage = 'Gagal mengirim email reset password';
  //     if (e.toString().contains('email') && e.toString().contains('tidak ditemukan')) {
  //       errorMessage = 'Email tidak ditemukan';
  //     }
  //
  //     return Result.failure(errorMessage);
  //   }
  // }

  // ✅ RESET PASSWORD
  // Future<Result<bool>> resetPassword({
  //   required String token,
  //   required String newPassword,
  // }) async {
  //   try {
  //     if (kDebugMode) {
  //       debugPrint('🔄 AuthRepository.resetPassword called');
  //     }
  //
  //     await _authService.resetPassword(token: token, password: newPassword);
  //
  //     if (kDebugMode) {
  //       debugPrint('✅ AuthRepository.resetPassword success');
  //     }
  //
  //     return Result.success(true);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ AuthRepository.resetPassword error: $e');
  //     }
  //
  //     String errorMessage = 'Gagal mereset password';
  //     if (e.toString().contains('token') && e.toString().contains('invalid')) {
  //       errorMessage = 'Token reset tidak valid atau sudah kedaluwarsa';
  //     }
  //
  //     return Result.failure(errorMessage);
  //   }
  // }
}
// // lib/data/repositories/auth_repository.dart - FINAL
// import 'package:flutter/foundation.dart';
// import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
// import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
// import 'package:del_pick/data/models/auth/user_model.dart';
// import 'package:del_pick/data/models/auth/login_response_model.dart';
// import 'package:del_pick/core/utils/result.dart';
// import 'package:del_pick/core/errors/exceptions.dart';
//
// class AuthRepository {
//   final AuthRemoteDataSource _remoteDataSource;
//   final AuthLocalDataSource _localDataSource;
//
//   AuthRepository(this._remoteDataSource, this._localDataSource);
//
//   // ✅ Login dengan error handling yang proper
//   Future<Result<LoginResponseModel>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       if (kDebugMode) {
//         debugPrint('🔄 AuthRepository.login: $email');
//       }
//
//       // Call remote data source
//       final response = await _remoteDataSource.login(
//         email: email,
//         password: password,
//       );
//
//       if (kDebugMode) {
//         debugPrint('✅ Remote login response received');
//         debugPrint('📝 Response keys: ${response.keys.toList()}');
//       }
//
//       // Create LoginResponseModel
//       final loginResponse = LoginResponseModel.fromBackendResponse(response);
//
//       if (kDebugMode) {
//         debugPrint('✅ LoginResponseModel created successfully');
//         debugPrint('📝 User: ${loginResponse.user.name}');
//         debugPrint('📝 Role: ${loginResponse.user.role}');
//       }
//
//       // Save to local storage
//       await _localDataSource.saveAuthToken(loginResponse.token);
//       await _localDataSource.saveUser(loginResponse.user);
//
//       // Save role-specific data if available
//       if (loginResponse.hasDriver && loginResponse.driver != null) {
//         await _localDataSource.saveDriverData(loginResponse.driver!.toJson());
//         if (kDebugMode) {
//           debugPrint('✅ Driver data saved');
//         }
//       }
//
//       if (loginResponse.hasStore && loginResponse.store != null) {
//         await _localDataSource.saveStoreData(loginResponse.store!.toJson());
//         if (kDebugMode) {
//           debugPrint('✅ Store data saved');
//         }
//       }
//
//       return Result.success(loginResponse);
//     } on AppException catch (e) {
//       if (kDebugMode) {
//         debugPrint('❌ AppException in login: ${e.toString()}');
//       }
//       return Result.failure(e.message);
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         debugPrint('❌ Unexpected error in login: ${e.toString()}');
//         debugPrint('📝 StackTrace: $stackTrace');
//       }
//       return Result.failure('Login failed: ${e.toString()}');
//     }
//   }
//
//   // ✅ Register
//   Future<Result<UserModel>> register({
//     required String name,
//     required String email,
//     required String phone,
//     required String password,
//     required String role,
//   }) async {
//     try {
//       if (kDebugMode) {
//         debugPrint('🔄 AuthRepository.register: $email, role: $role');
//       }
//
//       final response = await _remoteDataSource.register(
//         name: name,
//         email: email,
//         phone: phone,
//         password: password,
//         role: role,
//       );
//
//       final user = UserModel.fromJson(response);
//
//       if (kDebugMode) {
//         debugPrint('✅ Registration successful: ${user.name}');
//       }
//
//       return Result.success(user);
//     } on AppException catch (e) {
//       return Result.failure(e.message);
//     } catch (e) {
//       return Result.failure('Registration failed: ${e.toString()}');
//     }
//   }
//
//   // ✅ Get profile
//   Future<Result<UserModel>> getProfile() async {
//     try {
//       final response = await _remoteDataSource.getProfile();
//       final user = UserModel.fromJson(response);
//
//       // Update local storage
//       await _localDataSource.saveUser(user);
//
//       return Result.success(user);
//     } on AppException catch (e) {
//       return Result.failure(e.message);
//     } catch (e) {
//       return Result.failure('Get profile failed: ${e.toString()}');
//     }
//   }
//
//   // ✅ Update profile
//   Future<Result<UserModel>> updateProfile({
//     String? name,
//     String? email,
//     String? phone,
//     String? avatar,
//   }) async {
//     try {
//       final response = await _remoteDataSource.updateProfile(
//         name: name,
//         email: email,
//         phone: phone,
//         avatar: avatar,
//       );
//
//       final user = UserModel.fromJson(response);
//
//       // Update local storage
//       await _localDataSource.updateUserProfile(
//         name: name,
//         email: email,
//         phone: phone,
//         avatar: avatar,
//       );
//
//       return Result.success(user);
//     } on AppException catch (e) {
//       return Result.failure(e.message);
//     } catch (e) {
//       return Result.failure('Update profile failed: ${e.toString()}');
//     }
//   }
//
//   // ✅ Update FCM token
//   Future<Result<void>> updateFcmToken(String fcmToken) async {
//     try {
//       await _remoteDataSource.updateFcmToken(fcmToken);
//       await _localDataSource.updateUserProfile(fcmToken: fcmToken);
//       return Result.success(null);
//     } on AppException catch (e) {
//       return Result.failure(e.message);
//     } catch (e) {
//       return Result.failure('Update FCM token failed: ${e.toString()}');
//     }
//   }
//
//   // ✅ Forgot password
//   Future<Result<void>> forgotPassword(String email) async {
//     try {
//       await _remoteDataSource.forgotPassword(email);
//       return Result.success(null);
//     } on AppException catch (e) {
//       return Result.failure(e.message);
//     } catch (e) {
//       return Result.failure('Forgot password failed: ${e.toString()}');
//     }
//   }
//
//   // ✅ Reset password
//   Future<Result<void>> resetPassword({
//     required String token,
//     required String password,
//   }) async {
//     try {
//       await _remoteDataSource.resetPassword(token: token, password: password);
//       return Result.success(null);
//     } on AppException catch (e) {
//       return Result.failure(e.message);
//     } catch (e) {
//       return Result.failure('Reset password failed: ${e.toString()}');
//     }
//   }
//
//   // ✅ Logout
//   Future<Result<void>> logout() async {
//     try {
//       await _remoteDataSource.logout();
//       await _localDataSource.clearAuthData();
//       return Result.success(null);
//     } on AppException catch (e) {
//       await _localDataSource.clearAuthData(); // Clear local data anyway
//       return Result.failure(e.message);
//     } catch (e) {
//       await _localDataSource.clearAuthData(); // Clear local data anyway
//       return Result.failure('Logout failed: ${e.toString()}');
//     }
//   }
//
//   // ✅ Helper methods
//   Future<bool> isLoggedIn() async {
//     return await _localDataSource.hasValidToken();
//   }
//
//   Future<UserModel?> getCurrentUser() async {
//     return await _localDataSource.getUser();
//   }
//
//   Future<String?> getAuthToken() async {
//     return await _localDataSource.getAuthToken();
//   }
//
//   Future<void> clearAuthData() async {
//     await _localDataSource.clearAuthData();
//   }
// }
