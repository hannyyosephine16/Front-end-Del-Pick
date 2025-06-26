// // lib/features/auth/controllers/register_controller.dart - FIXED
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/data/repositories/auth_repository.dart';
// import 'package:del_pick/features/auth/controllers/auth_controller.dart';
// import 'package:del_pick/core/constants/app_constants.dart';
// import 'package:del_pick/core/utils/validators.dart';
// import 'package:del_pick/core/utils/helpers.dart';
// import 'package:del_pick/app/routes/app_routes.dart';
//
// class RegisterController extends GetxController {
//   final AuthRepository _authRepository;
//
//   RegisterController(this._authRepository);
//
//   // ✅ Form controllers
//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   // ✅ Observable states
//   final RxBool isLoading = false.obs;
//   final RxBool isPasswordVisible = false.obs;
//   final RxBool isConfirmPasswordVisible = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxString selectedRole = AppConstants.roleCustomer.obs;
//   final RxBool agreeToTerms = false.obs;
//
//   @override
//   void onClose() {
//     nameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.onClose();
//   }
//
//   // ✅ Toggle password visibility
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }
//
//   void toggleConfirmPasswordVisibility() {
//     isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
//   }
//
//   // ✅ Set selected role
//   void setRole(String role) {
//     if (AppConstants.validRoles.contains(role)) {
//       selectedRole.value = role;
//     }
//   }
//
//   // ✅ Toggle terms agreement
//   void toggleAgreeToTerms() {
//     agreeToTerms.value = !agreeToTerms.value;
//   }
//
//   // ✅ Clear error message
//   void clearError() {
//     errorMessage.value = '';
//   }
//
//   // ✅ Register method dengan AuthController integration
//   Future<void> register() async {
//     try {
//       // ✅ Validate form
//       if (!formKey.currentState!.validate()) {
//         return;
//       }
//
//       // ✅ Check terms agreement
//       if (!agreeToTerms.value) {
//         errorMessage.value = 'Anda harus menyetujui syarat dan ketentuan';
//         _showErrorSnackbar(errorMessage.value);
//         return;
//       }
//
//       clearError();
//       isLoading.value = true;
//
//       final name = nameController.text.trim();
//       final email = emailController.text.trim();
//       final phone = phoneController.text.trim();
//       final password = passwordController.text.trim();
//       final confirmPassword = confirmPasswordController.text.trim();
//
//       // ✅ Additional validation
//       if (password != confirmPassword) {
//         errorMessage.value = 'Konfirmasi password tidak cocok';
//         _showErrorSnackbar(errorMessage.value);
//         return;
//       }
//
//       // ✅ Call AuthController register method
//       final authController = Get.find<AuthController>();
//       final success = await authController.register(
//         name: name,
//         email: email,
//         password: password,
//         phone: phone,
//         role: selectedRole.value,
//       );
//
//       if (success) {
//         // ✅ Registration berhasil, akan navigate ke login dari AuthController
//         _clearForm();
//       } else {
//         // ✅ Error handling sudah ditangani oleh AuthController
//         errorMessage.value = authController.errorMessage.value;
//       }
//     } catch (e) {
//       print('❌ RegisterController error: $e');
//       errorMessage.value = _getDisplayErrorMessage(e.toString());
//       _showErrorSnackbar(errorMessage.value);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // ✅ Convert technical errors to user-friendly messages
//   String _getDisplayErrorMessage(String error) {
//     final lowercaseError = error.toLowerCase();
//
//     if (lowercaseError.contains('email') && lowercaseError.contains('sudah')) {
//       return 'Email sudah digunakan';
//     } else if (lowercaseError.contains('phone') &&
//         lowercaseError.contains('sudah')) {
//       return 'Nomor telefon sudah digunakan';
//     } else if (lowercaseError.contains('already exists') ||
//         lowercaseError.contains('conflict')) {
//       return 'Data sudah terdaftar. Gunakan email atau nomor lain';
//     } else if (lowercaseError.contains('validation') ||
//         lowercaseError.contains('invalid')) {
//       return 'Periksa kembali data yang dimasukkan';
//     } else if (lowercaseError.contains('network') ||
//         lowercaseError.contains('connection') ||
//         lowercaseError.contains('internet')) {
//       return 'Tidak ada koneksi internet';
//     } else if (lowercaseError.contains('timeout')) {
//       return 'Koneksi timeout. Silakan coba lagi';
//     } else if (lowercaseError.contains('server') ||
//         lowercaseError.contains('500')) {
//       return 'Server bermasalah. Silakan coba lagi nanti';
//     } else if (lowercaseError.contains('weak password')) {
//       return 'Password terlalu lemah';
//     } else if (lowercaseError.contains('email') &&
//         lowercaseError.contains('format')) {
//       return 'Format email tidak valid';
//     } else if (lowercaseError.contains('phone') &&
//         lowercaseError.contains('format')) {
//       return 'Format nomor telefon tidak valid';
//     }
//
//     // Return original error if it's short enough, otherwise generic message
//     return error.length > 100 ? 'Terjadi kesalahan saat registrasi' : error;
//   }
//
//   // ✅ Show error snackbar
//   void _showErrorSnackbar(String message) {
//     Helpers.showErrorSnackbar(
//       'Registration Error',
//       message,
//       Get.context!,
//     );
//   }
//
//   // ✅ Validation methods using Validators utility
//   String? validateName(String? value) {
//     return Validators.validateName(value);
//   }
//
//   String? validateEmail(String? value) {
//     return Validators.validateEmail(value);
//   }
//
//   String? validatePhone(String? value) {
//     return Validators.validatePhone(value);
//   }
//
//   String? validatePassword(String? value) {
//     return Validators.validatePassword(value);
//   }
//
//   String? validateConfirmPassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Konfirmasi password harus diisi';
//     }
//     if (value != passwordController.text) {
//       return 'Konfirmasi password tidak cocok';
//     }
//     return null;
//   }
//
//   // ✅ Clear form
//   void _clearForm() {
//     nameController.clear();
//     emailController.clear();
//     phoneController.clear();
//     passwordController.clear();
//     confirmPasswordController.clear();
//     clearError();
//     isPasswordVisible.value = false;
//     isConfirmPasswordVisible.value = false;
//     agreeToTerms.value = false;
//     selectedRole.value = AppConstants.roleCustomer;
//   }
//
//   // ✅ Utility methods for UI
//   void clearForm() {
//     _clearForm();
//   }
//
//   void resetForm() {
//     _clearForm();
//   }
//
//   bool get hasError => errorMessage.value.isNotEmpty;
//
//   bool get isFormValid =>
//       nameController.text.isNotEmpty &&
//       emailController.text.isNotEmpty &&
//       phoneController.text.isNotEmpty &&
//       passwordController.text.isNotEmpty &&
//       confirmPasswordController.text.isNotEmpty &&
//       agreeToTerms.value;
//
//   // ✅ Role selection helpers
//   List<Map<String, String>> get availableRoles => [
//         {
//           'value': AppConstants.roleCustomer,
//           'label': 'Customer',
//           'description': 'Pesan makanan dari berbagai toko',
//           'icon': '🛒',
//         },
//         {
//           'value': AppConstants.roleDriver,
//           'label': 'Driver',
//           'description': 'Antar pesanan dan dapatkan penghasilan',
//           'icon': '🚗',
//         },
//         {
//           'value': AppConstants.roleStore,
//           'label': 'Store Owner',
//           'description': 'Jual makanan dan kelola toko online',
//           'icon': '🏪',
//         },
//       ];
//
//   Map<String, String>? get selectedRoleInfo {
//     return availableRoles.firstWhereOrNull(
//       (role) => role['value'] == selectedRole.value,
//     );
//   }
//
//   // ✅ Navigation methods
//   void goToLogin() {
//     Get.offNamed(Routes.LOGIN);
//   }
//
//   void goToTermsAndConditions() {
//     Get.toNamed(Routes.TERMS_OF_SERVICE);
//   }
//
//   void goToPrivacyPolicy() {
//     Get.toNamed(Routes.PRIVACY_POLICY);
//   }
//
//   // ✅ Auto-fill for demo/testing
//   void fillDemoData(String role) {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//
//     switch (role) {
//       case AppConstants.roleCustomer:
//         nameController.text = 'Demo Customer';
//         emailController.text = 'customer$timestamp@demo.com';
//         phoneController.text = '08123456789';
//         passwordController.text = 'password123';
//         confirmPasswordController.text = 'password123';
//         selectedRole.value = AppConstants.roleCustomer;
//         break;
//
//       case AppConstants.roleDriver:
//         nameController.text = 'Demo Driver';
//         emailController.text = 'driver$timestamp@demo.com';
//         phoneController.text = '08129876543';
//         passwordController.text = 'password123';
//         confirmPasswordController.text = 'password123';
//         selectedRole.value = AppConstants.roleDriver;
//         break;
//
//       case AppConstants.roleStore:
//         nameController.text = 'Demo Store';
//         emailController.text = 'store$timestamp@demo.com';
//         phoneController.text = '08124567890';
//         passwordController.text = 'password123';
//         confirmPasswordController.text = 'password123';
//         selectedRole.value = AppConstants.roleStore;
//         break;
//     }
//
//     agreeToTerms.value = true;
//   }
// }
