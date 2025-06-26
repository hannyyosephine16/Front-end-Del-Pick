// lib/features/auth/screens/login_screen.dart - FIXED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/login_controller.dart';
import 'package:del_pick/core/widgets/custom_button.dart';
import 'package:del_pick/core/widgets/custom_text_field.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacingHuge),

                // Logo & Title
                const Icon(
                  Icons.delivery_dining,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.spacingXL),

                Text(
                  'DelPick',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingSM),

                Text(
                  'Masuk ke akun Anda',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingHuge),

                // Error Message
                Obx(() {
                  if (controller.hasError) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.spacingLG,
                      ),
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD,
                        ),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: AppDimensions.iconSM,
                          ),
                          const SizedBox(width: AppDimensions.spacingSM),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.clearError,
                            icon: const Icon(
                              Icons.close,
                              size: AppDimensions.iconSM,
                            ),
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Email Field
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: controller.validateEmail,
                  onChanged: (value) => controller.clearError(),
                ),
                const SizedBox(height: AppDimensions.spacingLG),

                // Password Field
                Obx(() => CustomTextField(
                      controller: controller.passwordController,
                      labelText: 'Password',
                      hintText: 'Masukkan password Anda',
                      prefixIcon: Icons.lock_outlined,
                      isPassword: true,
                      obscureText: !controller.isPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      validator: controller.validatePassword,
                      onChanged: (value) => controller.clearError(),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) => controller.login(),
                    )),
                const SizedBox(height: AppDimensions.spacingMD),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Remember Me
                    Obx(() => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: controller.rememberMe.value,
                              onChanged: (value) =>
                                  controller.toggleRememberMe(),
                              activeColor: AppColors.primary,
                            ),
                            Text(
                              'Ingat saya',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        )),

                    // Forgot Password
                    TextButton(
                      onPressed: controller.goToForgotPassword,
                      child: Text(
                        'Lupa Password?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXL),

                // ✅ LOGIN BUTTON - Always accessible
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Masuk',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    )),
                const SizedBox(height: AppDimensions.spacingXL),

                // Demo Buttons (for testing) - Always show for now
                const Divider(),
                const SizedBox(height: AppDimensions.spacingMD),
                Text(
                  'Demo Accounts (untuk testing)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingMD),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.fillDemoCustomer,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Customer',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSM),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.fillDemoDriver,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Driver',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSM),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.fillDemoStore,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Store',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXL),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.goToRegister,
                      child: Text(
                        'Daftar Sekarang',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
