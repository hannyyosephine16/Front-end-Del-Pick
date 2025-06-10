// lib/core/utils/custom_snackbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class CustomSnackbar {
  static void showSuccess({
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: AppColors.textOnPrimary,
      icon: const Icon(
        Icons.check_circle,
        color: AppColors.textOnPrimary,
      ),
      shouldIconPulse: false,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      borderRadius: AppDimensions.radiusLG,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      onTap: onTap != null ? (_) => onTap() : null,
      boxShadows: [
        BoxShadow(
          color: AppColors.success.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.error,
      colorText: AppColors.textOnPrimary,
      icon: const Icon(
        Icons.error,
        color: AppColors.textOnPrimary,
      ),
      shouldIconPulse: false,
      duration: duration ?? const Duration(seconds: 4),
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      borderRadius: AppDimensions.radiusLG,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      onTap: onTap != null ? (_) => onTap() : null,
      boxShadows: [
        BoxShadow(
          color: AppColors.error.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.warning,
      colorText: AppColors.textOnWarning,
      icon: Icon(
        Icons.warning,
        color: AppColors.textOnWarning,
      ),
      shouldIconPulse: false,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      borderRadius: AppDimensions.radiusLG,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      onTap: onTap != null ? (_) => onTap() : null,
      boxShadows: [
        BoxShadow(
          color: AppColors.warning.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info,
      colorText: AppColors.textOnPrimary,
      icon: const Icon(
        Icons.info,
        color: AppColors.textOnPrimary,
      ),
      shouldIconPulse: false,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      borderRadius: AppDimensions.radiusLG,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      onTap: onTap != null ? (_) => onTap() : null,
      boxShadows: [
        BoxShadow(
          color: AppColors.info.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showCustom({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    Duration? duration,
    VoidCallback? onTap,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(icon, color: textColor),
      shouldIconPulse: false,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      borderRadius: AppDimensions.radiusLG,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      onTap: onTap != null ? (_) => onTap() : null,
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Show loading snackbar that can be dismissed programmatically
  static void showLoading({
    required String title,
    String? message,
  }) {
    Get.snackbar(
      title,
      message ?? 'Please wait...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: AppColors.textOnPrimary,
      showProgressIndicator: true,
      progressIndicatorBackgroundColor:
          AppColors.textOnPrimary.withOpacity(0.3),
      progressIndicatorValueColor:
          AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
      duration: const Duration(seconds: 30), // Long duration
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      borderRadius: AppDimensions.radiusLG,
      isDismissible: false,
      animationDuration: const Duration(milliseconds: 600),
      boxShadows: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Dismiss any current snackbar
  static void dismiss() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  /// Show action snackbar with custom action button
  static void showAction({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: textColor ?? AppColors.textOnPrimary,
      icon: icon != null
          ? Icon(icon, color: textColor ?? AppColors.textOnPrimary)
          : null,
      shouldIconPulse: false,
      duration: duration ?? const Duration(seconds: 5),
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      borderRadius: AppDimensions.radiusLG,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          onActionPressed();
        },
        child: Text(
          actionLabel,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor ?? AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: (backgroundColor ?? AppColors.primary).withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
