// lib/features/auth/controllers/login_controller.dart - FIXED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository;

  LoginController(this._authRepository);

  // ✅ Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ✅ Observable states
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ✅ Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // ✅ Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // ✅ Login with comprehensive error handling
  Future<void> login() async {
    try {
      // ✅ Validate form first
      if (!formKey.currentState!.validate()) {
        return;
      }

      clearError();
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // ✅ Basic validation
      if (email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Email dan password harus diisi';
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      // ✅ Call repository
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        // ✅ Success - update auth controller
        final authController = Get.find<AuthController>();
        await authController.checkAuthStatus();

        // ✅ Navigate akan dilakukan di AuthController
        Get.snackbar(
          'Berhasil',
          result.message ?? 'Login berhasil!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 2),
        );
      } else {
        // ✅ Handle specific error messages
        final error = result.error ?? 'Login gagal';
        errorMessage.value = _getDisplayErrorMessage(error);
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      print('❌ Login error: $e');

      // ✅ Handle different types of errors
      String displayError = 'Terjadi kesalahan. Silakan coba lagi.';

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        displayError = 'Tidak ada koneksi internet. Periksa koneksi Anda.';
      } else if (e.toString().contains('timeout')) {
        displayError = 'Koneksi timeout. Silakan coba lagi.';
      } else if (e.toString().contains('server')) {
        displayError = 'Server sedang bermasalah. Silakan coba lagi nanti.';
      }

      errorMessage.value = displayError;
      _showErrorSnackbar(displayError);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Convert technical errors to user-friendly messages
  String _getDisplayErrorMessage(String error) {
    final lowercaseError = error.toLowerCase();

    if (lowercaseError.contains('invalid') ||
        lowercaseError.contains('salah') ||
        lowercaseError.contains('incorrect')) {
      return 'Email atau password salah';
    } else if (lowercaseError.contains('not found') ||
        lowercaseError.contains('tidak ditemukan')) {
      return 'Akun tidak ditemukan';
    } else if (lowercaseError.contains('network') ||
        lowercaseError.contains('connection')) {
      return 'Tidak ada koneksi internet';
    } else if (lowercaseError.contains('timeout')) {
      return 'Koneksi timeout. Silakan coba lagi';
    } else if (lowercaseError.contains('server') ||
        lowercaseError.contains('500')) {
      return 'Server bermasalah. Silakan coba lagi nanti';
    } else if (lowercaseError.contains('validation') ||
        lowercaseError.contains('required')) {
      return 'Periksa input Anda dan coba lagi';
    } else if (lowercaseError.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar';
    }

    return error.length > 100 ? 'Terjadi kesalahan saat login' : error;
  }

  // ✅ Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(
        Icons.error_outline,
        color: Get.theme.colorScheme.onError,
      ),
    );
  }

  // ✅ Email validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }

    final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // ✅ Password validator
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // ✅ Utility methods for UI
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    clearError();
  }

  bool get hasError => errorMessage.value.isNotEmpty;
}
