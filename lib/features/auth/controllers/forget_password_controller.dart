// lib/features/auth/controllers/forget_password_controller.dart - FIXED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/core/utils/validators.dart';
import 'package:del_pick/core/utils/helpers.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class ForgetPasswordController extends GetxController {
  final AuthRepository _authRepository;

  ForgetPasswordController(this._authRepository);

  // ✅ Form controllers
  final emailController = TextEditingController();
  final tokenController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();

  // ✅ Observable states
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool emailSent = false.obs;
  final RxInt resendCountdown = 0.obs;

  @override
  void onClose() {
    emailController.dispose();
    tokenController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // ✅ Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // ✅ Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // ✅ Send forgot password email
  Future<void> forgotPassword() async {
    try {
      // ✅ Validate form
      if (!emailFormKey.currentState!.validate()) {
        return;
      }

      clearError();
      isLoading.value = true;

      final email = emailController.text.trim();

      // ✅ Call AuthController method
      final authController = Get.find<AuthController>();
      final success = await authController.forgotPassword(email);

      if (success) {
        emailSent.value = true;
        _startResendCountdown();

        Helpers.showSuccessSnackbar(
          'Berhasil',
          'Email reset password telah dikirim ke $email',
          Get.context!,
        );
      } else {
        errorMessage.value = authController.errorMessage.value;
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      print('❌ ForgotPassword error: $e');
      errorMessage.value = _getDisplayErrorMessage(e.toString());
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Reset password with token
  Future<void> resetPassword() async {
    try {
      // ✅ Validate form
      if (!resetFormKey.currentState!.validate()) {
        return;
      }

      clearError();
      isLoading.value = true;

      final token = tokenController.text.trim();
      final newPassword = newPasswordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      // ✅ Additional validation
      if (newPassword != confirmPassword) {
        errorMessage.value = 'Konfirmasi password tidak cocok';
        _showErrorSnackbar(errorMessage.value);
        return;
      }

      // ✅ Call AuthController method
      final authController = Get.find<AuthController>();
      final success = await authController.resetPassword(
        token: token,
        password: newPassword,
      );

      if (success) {
        // ✅ Success akan navigate ke login dari AuthController
        _clearForms();

        Helpers.showSuccessSnackbar(
          'Berhasil',
          'Password berhasil direset. Silakan login dengan password baru',
          Get.context!,
        );
      } else {
        errorMessage.value = authController.errorMessage.value;
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      print('❌ ResetPassword error: $e');
      errorMessage.value = _getDisplayErrorMessage(e.toString());
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Resend forgot password email
  Future<void> resendEmail() async {
    if (resendCountdown.value > 0) {
      Helpers.showWarningSnackbar(
        'Info',
        'Tunggu ${resendCountdown.value} detik sebelum mengirim ulang',
        Get.context!,
      );
      return;
    }

    await forgotPassword();
  }

  // ✅ Start countdown for resend button
  void _startResendCountdown() {
    resendCountdown.value = 60; // 60 seconds countdown

    // Start countdown timer
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
        return true;
      }
      return false;
    });
  }

  // ✅ Convert technical errors to user-friendly messages
  String _getDisplayErrorMessage(String error) {
    final lowercaseError = error.toLowerCase();

    if (lowercaseError.contains('not found') ||
        lowercaseError.contains('tidak ditemukan')) {
      return 'Email tidak terdaftar';
    } else if (lowercaseError.contains('invalid token') ||
        lowercaseError.contains('token tidak valid')) {
      return 'Kode reset tidak valid atau sudah expired';
    } else if (lowercaseError.contains('expired') ||
        lowercaseError.contains('kedaluwarsa')) {
      return 'Kode reset sudah expired. Silakan minta yang baru';
    } else if (lowercaseError.contains('network') ||
        lowercaseError.contains('connection') ||
        lowercaseError.contains('internet')) {
      return 'Tidak ada koneksi internet';
    } else if (lowercaseError.contains('timeout')) {
      return 'Koneksi timeout. Silakan coba lagi';
    } else if (lowercaseError.contains('server') ||
        lowercaseError.contains('500')) {
      return 'Server bermasalah. Silakan coba lagi nanti';
    } else if (lowercaseError.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar';
    }

    return error.length > 100 ? 'Terjadi kesalahan' : error;
  }

  // ✅ Show error snackbar
  void _showErrorSnackbar(String message) {
    Helpers.showErrorSnackbar(
      'Reset Password Error',
      message,
      Get.context!,
    );
  }

  // ✅ Clear all forms
  void _clearForms() {
    emailController.clear();
    tokenController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    clearError();
    emailSent.value = false;
    resendCountdown.value = 0;
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  // ===============================================
  // VALIDATION METHODS
  // ===============================================

  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }

  String? validateToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode reset harus diisi';
    }
    if (value.trim().length < 6) {
      return 'Kode reset minimal 6 karakter';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    return Validators.validatePassword(value);
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (value != newPasswordController.text) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }

  // ===============================================
  // GETTERS
  // ===============================================

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get canResend => resendCountdown.value == 0;
  String get resendText =>
      canResend ? 'Kirim Ulang' : 'Kirim Ulang (${resendCountdown.value}s)';

  bool get isEmailFormValid => emailController.text.trim().isNotEmpty;

  bool get isResetFormValid =>
      tokenController.text.trim().isNotEmpty &&
      newPasswordController.text.trim().isNotEmpty &&
      confirmPasswordController.text.trim().isNotEmpty;

  // ===============================================
  // UTILITY METHODS
  // ===============================================

  void clearForms() {
    _clearForms();
  }

  void resetToEmailStep() {
    tokenController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    emailSent.value = false;
    clearError();
  }

  // ✅ Navigation methods
  void goToLogin() {
    Get.offAllNamed(Routes.LOGIN);
  }

  void goToRegister() {
    Get.offAllNamed(Routes.REGISTER);
  }

  // ✅ Auto-fill for demo/testing
  void fillDemoEmail() {
    emailController.text = 'demo@delpick.com';
  }

  void fillDemoToken() {
    tokenController.text = 'DEMO123';
    newPasswordController.text = 'newpassword123';
    confirmPasswordController.text = 'newpassword123';
  }
}
