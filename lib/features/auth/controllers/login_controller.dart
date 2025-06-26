// lib/features/auth/controllers/login_controller.dart - FIXED
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/core/utils/validators.dart';
import 'package:del_pick/core/utils/helpers.dart';

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
  final RxBool rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedCredentials();
  }

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

  // ✅ Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // ✅ Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // ✅ Load remembered credentials
  void _loadRememberedCredentials() {
    // TODO: Load from storage if remember me was enabled
  }

  // ✅ Login dengan validasi minimal
  Future<void> login() async {
    try {
      clearError();
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // ✅ Minimal validation - hanya cek kosong
      if (email.isEmpty) {
        errorMessage.value = 'Email harus diisi';
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      if (password.isEmpty) {
        errorMessage.value = 'Password harus diisi';
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      // ✅ Call AuthController login method
      final authController = Get.find<AuthController>();
      final success = await authController.login(
        email: email,
        password: password,
      );

      if (success) {
        // ✅ Save credentials if remember me is checked
        if (rememberMe.value) {
          // TODO: Save to storage
        }

        // ✅ Navigation akan ditangani oleh AuthController
        _clearForm();

        // Show success message
        Get.snackbar(
          'Berhasil',
          'Login berhasil!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // ✅ Error handling sudah ditangani oleh AuthController
        errorMessage.value = authController.errorMessage.value;
        if (errorMessage.value.isNotEmpty) {
          _showErrorSnackbar(errorMessage.value);
        }
      }
    } catch (e) {
      print('❌ LoginController error: $e');
      errorMessage.value = _getDisplayErrorMessage(e.toString());
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Convert technical errors to user-friendly messages
  String _getDisplayErrorMessage(String error) {
    final lowercaseError = error.toLowerCase();

    if (lowercaseError.contains('email atau password salah') ||
        lowercaseError.contains('invalid credentials') ||
        lowercaseError.contains('unauthorized')) {
      return 'Email atau password salah';
    } else if (lowercaseError.contains('network') ||
        lowercaseError.contains('connection') ||
        lowercaseError.contains('internet')) {
      return 'Tidak ada koneksi internet';
    } else if (lowercaseError.contains('timeout')) {
      return 'Koneksi timeout. Silakan coba lagi';
    } else if (lowercaseError.contains('server') ||
        lowercaseError.contains('500')) {
      return 'Server bermasalah. Silakan coba lagi nanti';
    } else if (lowercaseError.contains('too many requests') ||
        lowercaseError.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar';
    }

    // Return user-friendly generic message
    return 'Terjadi kesalahan saat login. Silakan coba lagi.';
  }

  // ✅ Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  // ✅ Minimal email validator - hanya cek kosong dan format dasar
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email harus diisi';
    }

    // Basic email format check
    if (!value.contains('@') || !value.contains('.')) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // ✅ Minimal password validator - hanya cek kosong
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password harus diisi';
    }

    // Minimal length check (optional)
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // ✅ Clear form
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    clearError();
    isPasswordVisible.value = false;
  }

  // ✅ Utility methods for UI
  void clearForm() {
    _clearForm();
  }

  void resetForm() {
    _clearForm();
    rememberMe.value = false;
  }

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isFormValid =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty;

  // ✅ Navigation methods
  void goToRegister() {
    clearError();
    Get.toNamed(Routes.REGISTER);
  }

  void goToForgotPassword() {
    clearError();
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  // ✅ Testing methods untuk development
  void testWithRealData() {
    // Gunakan data real dari database admin seed
    emailController.text = 'admin@delpick.com';
    passwordController.text = 'password';
    clearError();
  }

  // ✅ Clear demo methods - tidak ada lagi auto-fill
  void fillDemoCustomer() {
    // Kosongkan form dan biarkan user isi manual
    clearForm();
  }

  void fillDemoDriver() {
    clearForm();
  }

  void fillDemoStore() {
    clearForm();
  }
}
