// lib/data/repositories/auth_repository.dart - FIXED VERSION
import 'package:del_pick/data/providers/auth_provider.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/core/utils/result.dart';

class AuthRepository {
  final AuthProvider _authProvider;

  AuthRepository(this._authProvider);

  Future<Result<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    return await _authProvider.login(email: email, password: password);
  }

  Future<Result<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    return await _authProvider.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
  }

  Future<Result<UserModel>> getProfile() async {
    return await _authProvider.getProfile();
  }

  Future<Result<UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    return await _authProvider.updateProfile(
      name: name,
      email: email,
      phone: phone,
      avatar: avatar,
    );
  }

  Future<Result<void>> forgotPassword(String email) async {
    return await _authProvider.forgotPassword(email);
  }

  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    return await _authProvider.resetPassword(token: token, password: password);
  }

  Future<Result<void>> logout() async {
    return await _authProvider.logout();
  }

  Future<bool> isLoggedIn() async {
    return await _authProvider.isLoggedIn();
  }

  Future<UserModel?> getCurrentUser() async {
    return await _authProvider.getCurrentUser();
  }

  Future<String?> getAuthToken() async {
    return await _authProvider.getAuthToken();
  }
}
