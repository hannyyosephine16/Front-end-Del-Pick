// // lib/features/auth/screens/forgot_password_screen.dart - FIXED
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/features/auth/controllers/forget_password_controller.dart';
// import 'package:del_pick/core/widgets/custom_button.dart';
// import 'package:del_pick/app/themes/app_colors.dart';
// import 'package:del_pick/app/themes/app_text_styles.dart';
// import 'package:del_pick/app/themes/app_dimensions.dart';
//
// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});
//
//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   // ✅ Use the controller from Get.find (should be bound in binding)
//   ForgetPasswordController get controller =>
//       Get.find<ForgetPasswordController>();
//
//   Future<void> _handleForgotPassword() async {
//     // Validate form using controller's form key
//     if (controller.emailFormKey.currentState!.validate()) {
//       // Call forgotPassword method (no parameters, no return value)
//       await controller.forgotPassword();
//
//       // Check if email was sent successfully
//       if (controller.emailSent.value) {
//         _showSuccessDialog();
//       }
//     }
//   }
//
//   void _showSuccessDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Email Sent'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.email_outlined,
//               size: 64,
//               color: AppColors.success,
//             ),
//             const SizedBox(height: AppDimensions.spacingLG),
//             Text(
//               'We have sent a password reset code to ${controller.emailController.text.trim()}',
//               textAlign: TextAlign.center,
//               style: AppTextStyles.bodyMedium,
//             ),
//             const SizedBox(height: AppDimensions.spacingMD),
//             Text(
//               'Please check your email and enter the code below.',
//               textAlign: TextAlign.center,
//               style: AppTextStyles.bodySmall.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back(); // Close dialog
//               // emailSent will show the reset form automatically
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//       barrierDismissible: false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: AppColors.textPrimary,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(AppDimensions.paddingXL),
//           child: Obx(() {
//             // Show different UI based on email sent status
//             if (controller.emailSent.value) {
//               return _buildResetPasswordForm();
//             } else {
//               return _buildForgotPasswordForm();
//             }
//           }),
//         ),
//       ),
//     );
//   }
//
//   // ✅ Email form (step 1)
//   Widget _buildForgotPasswordForm() {
//     return Form(
//       key: controller.emailFormKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Icon
//           const Icon(
//             Icons.lock_reset,
//             size: 80,
//             color: AppColors.primary,
//           ),
//           const SizedBox(height: AppDimensions.spacingXL),
//
//           // Title
//           Text(
//             'Forgot Password?',
//             style: AppTextStyles.h3,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: AppDimensions.spacingSM),
//           Text(
//             'Enter your email address and we\'ll send you a reset code.',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: AppDimensions.spacingHuge),
//
//           // Email Field
//           TextFormField(
//             controller: controller.emailController,
//             keyboardType: TextInputType.emailAddress,
//             decoration: const InputDecoration(
//               labelText: 'Email Address',
//               prefixIcon: Icon(Icons.email_outlined),
//               hintText: 'Enter your email',
//             ),
//             validator: controller.validateEmail,
//             onChanged: (_) => controller.clearError(), // Clear error on change
//           ),
//           const SizedBox(height: AppDimensions.spacingXL),
//
//           // Error message
//           Obx(() {
//             if (controller.hasError) {
//               return Container(
//                 padding: const EdgeInsets.all(AppDimensions.paddingMD),
//                 margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
//                 decoration: BoxDecoration(
//                   color: AppColors.error.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//                   border: Border.all(color: AppColors.error.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       color: AppColors.error,
//                       size: 20,
//                     ),
//                     const SizedBox(width: AppDimensions.spacingSM),
//                     Expanded(
//                       child: Text(
//                         controller.errorMessage.value,
//                         style: AppTextStyles.bodySmall.copyWith(
//                           color: AppColors.error,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//
//           // Send Reset Link Button
//           Obx(
//             () => CustomButton.primary(
//               text: 'Send Reset Code',
//               onPressed: _handleForgotPassword,
//               isLoading: controller.isLoading.value, // ✅ Fix: access .value
//               isExpanded: true,
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingLG),
//
//           // Back to Login
//           CustomButton.text(
//             text: 'Back to Login',
//             onPressed: controller.goToLogin,
//             isExpanded: true,
//           ),
//
//           const SizedBox(height: AppDimensions.spacingXXL),
//
//           // Help Text
//           Container(
//             padding: const EdgeInsets.all(AppDimensions.paddingLG),
//             decoration: BoxDecoration(
//               color: AppColors.info.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//               border: Border.all(color: AppColors.info.withOpacity(0.3)),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.info_outline,
//                   color: AppColors.info,
//                   size: 20,
//                 ),
//                 const SizedBox(height: AppDimensions.spacingSM),
//                 Text(
//                   'Didn\'t receive the code?',
//                   style: AppTextStyles.labelMedium.copyWith(
//                     color: AppColors.info,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: AppDimensions.spacingXS),
//                 Text(
//                   'Check your spam folder or try again with a different email address.',
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: AppColors.info,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ Reset password form (step 2)
//   Widget _buildResetPasswordForm() {
//     return Form(
//       key: controller.resetFormKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Icon
//           const Icon(
//             Icons.lock_reset,
//             size: 80,
//             color: AppColors.success,
//           ),
//           const SizedBox(height: AppDimensions.spacingXL),
//
//           // Title
//           Text(
//             'Reset Password',
//             style: AppTextStyles.h3,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: AppDimensions.spacingSM),
//           Text(
//             'Enter the reset code and your new password.',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: AppDimensions.spacingHuge),
//
//           // Token Field
//           TextFormField(
//             controller: controller.tokenController,
//             keyboardType: TextInputType.text,
//             decoration: const InputDecoration(
//               labelText: 'Reset Code',
//               prefixIcon: Icon(Icons.vpn_key),
//               hintText: 'Enter the code sent to your email',
//             ),
//             validator: controller.validateToken,
//             onChanged: (_) => controller.clearError(),
//           ),
//           const SizedBox(height: AppDimensions.spacingLG),
//
//           // New Password Field
//           Obx(
//             () => TextFormField(
//               controller: controller.newPasswordController,
//               obscureText: !controller.isPasswordVisible.value,
//               decoration: InputDecoration(
//                 labelText: 'New Password',
//                 prefixIcon: const Icon(Icons.lock_outline),
//                 hintText: 'Enter your new password',
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     controller.isPasswordVisible.value
//                         ? Icons.visibility_off
//                         : Icons.visibility,
//                   ),
//                   onPressed: controller.togglePasswordVisibility,
//                 ),
//               ),
//               validator: controller.validateNewPassword,
//               onChanged: (_) => controller.clearError(),
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingLG),
//
//           // Confirm Password Field
//           Obx(
//             () => TextFormField(
//               controller: controller.confirmPasswordController,
//               obscureText: !controller.isConfirmPasswordVisible.value,
//               decoration: InputDecoration(
//                 labelText: 'Confirm Password',
//                 prefixIcon: const Icon(Icons.lock_outline),
//                 hintText: 'Confirm your new password',
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     controller.isConfirmPasswordVisible.value
//                         ? Icons.visibility_off
//                         : Icons.visibility,
//                   ),
//                   onPressed: controller.toggleConfirmPasswordVisibility,
//                 ),
//               ),
//               validator: controller.validateConfirmPassword,
//               onChanged: (_) => controller.clearError(),
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingXL),
//
//           // Error message
//           Obx(() {
//             if (controller.hasError) {
//               return Container(
//                 padding: const EdgeInsets.all(AppDimensions.paddingMD),
//                 margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
//                 decoration: BoxDecoration(
//                   color: AppColors.error.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//                   border: Border.all(color: AppColors.error.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       color: AppColors.error,
//                       size: 20,
//                     ),
//                     const SizedBox(width: AppDimensions.spacingSM),
//                     Expanded(
//                       child: Text(
//                         controller.errorMessage.value,
//                         style: AppTextStyles.bodySmall.copyWith(
//                           color: AppColors.error,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//
//           // Reset Password Button
//           Obx(
//             () => CustomButton.primary(
//               text: 'Reset Password',
//               onPressed: controller.resetPassword,
//               isLoading: controller.isLoading.value,
//               isExpanded: true,
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingLG),
//
//           // Resend Code Button
//           Obx(
//             () => CustomButton.outlined(
//               text: controller.resendText,
//               onPressed: controller.canResend ? controller.resendEmail : null,
//               isExpanded: true,
//               isEnabled: controller.canResend,
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingMD),
//
//           // Back to Email Step
//           CustomButton.text(
//             text: 'Back to Email',
//             onPressed: controller.resetToEmailStep,
//             isExpanded: true,
//           ),
//         ],
//       ),
//     );
//   }
// }
