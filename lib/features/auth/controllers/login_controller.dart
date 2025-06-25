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

  // ✅ Login dengan AuthController integration
  Future<void> login() async {
    try {
      // ✅ Validate form
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
      } else {
        // ✅ Error handling sudah ditangani oleh AuthController
        errorMessage.value = authController.errorMessage.value;
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

    if (lowercaseError.contains('invalid') ||
        lowercaseError.contains('salah') ||
        lowercaseError.contains('incorrect') ||
        lowercaseError.contains('email atau password salah')) {
      return 'Email atau password salah';
    } else if (lowercaseError.contains('not found') ||
        lowercaseError.contains('tidak ditemukan')) {
      return 'Akun tidak ditemukan';
    } else if (lowercaseError.contains('network') ||
        lowercaseError.contains('connection') ||
        lowercaseError.contains('internet')) {
      return 'Tidak ada koneksi internet';
    } else if (lowercaseError.contains('timeout')) {
      return 'Koneksi timeout. Silakan coba lagi';
    } else if (lowercaseError.contains('server') ||
        lowercaseError.contains('500')) {
      return 'Server bermasalah. Silakan coba lagi nanti';
    } else if (lowercaseError.contains('validation') ||
        lowercaseError.contains('required')) {
      return 'Periksa input Anda dan coba lagi';
    } else if (lowercaseError.contains('too many requests') ||
        lowercaseError.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar';
    } else if (lowercaseError.contains('unauthorized')) {
      return 'Email atau password salah';
    } else if (lowercaseError.contains('forbidden')) {
      return 'Akses ditolak';
    }

    // Return original error if it's short enough, otherwise generic message
    return error.length > 100 ? 'Terjadi kesalahan saat login' : error;
  }

  // ✅ Show error snackbar
  void _showErrorSnackbar(String message) {
    Helpers.showErrorSnackbar(
      'Login Error',
      message,
      Get.context!,
    );
  }

  // ✅ Email validator using Validators utility
  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }

  // ✅ Password validator using Validators utility
  String? validatePassword(String? value) {
    return Validators.validatePassword(value);
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
      emailController.text.isNotEmpty && passwordController.text.isNotEmpty;

  // ✅ Navigation methods
  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  // ✅ Auto-fill methods for testing/demo
  void fillDemoCustomer() {
    emailController.text = 'customer@delpick.com';
    passwordController.text = 'password';
  }

  void fillDemoDriver() {
    emailController.text = 'driver@delpick.com';
    passwordController.text = 'password';
  }

  void fillDemoStore() {
    emailController.text = 'store@delpick.com';
    passwordController.text = 'password';
  }
}
