// lib/core/utils/custom_snackbar.dart - UNIFIED & IMPROVED VERSION
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class CustomSnackbar {
  // Debounce timer untuk mencegah spam snackbar
  static Timer? _debounceTimer;

  // ✅ SUCCESS SNACKBAR
  static void showSuccess({
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onTap,
    BuildContext? context, // Support untuk native Flutter
  }) {
    _debounceAndShow(() {
      if (context != null) {
        // Native Flutter Snackbar
        _showNativeSnackbar(
          context: context,
          message: message,
          backgroundColor: AppColors.success,
          icon: Icons.check_circle,
          duration: duration,
        );
      } else {
        // GetX Snackbar
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success,
          colorText: AppColors.textOnPrimary,
          icon: const Icon(Icons.check_circle, color: AppColors.textOnPrimary),
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
    });
  }

  // ✅ ERROR SNACKBAR
  static void showError({
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    _debounceAndShow(() {
      if (context != null) {
        _showNativeSnackbar(
          context: context,
          message: message,
          backgroundColor: AppColors.error,
          icon: Icons.error,
          duration: duration,
        );
      } else {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.textOnPrimary,
          icon: const Icon(Icons.error, color: AppColors.textOnPrimary),
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
    });
  }

  // ✅ WARNING SNACKBAR
  static void showWarning({
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    _debounceAndShow(() {
      if (context != null) {
        _showNativeSnackbar(
          context: context,
          message: message,
          backgroundColor: AppColors.warning,
          icon: Icons.warning,
          duration: duration,
        );
      } else {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnWarning,
          icon: Icon(Icons.warning, color: AppColors.textOnWarning),
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
    });
  }

  // ✅ INFO SNACKBAR
  static void showInfo({
    required String title,
    required String message,
    Duration? duration,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    _debounceAndShow(() {
      if (context != null) {
        _showNativeSnackbar(
          context: context,
          message: message,
          backgroundColor: AppColors.info,
          icon: Icons.info,
          duration: duration,
        );
      } else {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.info,
          colorText: AppColors.textOnPrimary,
          icon: const Icon(Icons.info, color: AppColors.textOnPrimary),
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
    });
  }

  // ✅ LOADING SNACKBAR
  static void showLoading({
    required String title,
    String? message,
    BuildContext? context,
  }) {
    if (context != null) {
      _showNativeSnackbar(
        context: context,
        message: message ?? 'Please wait...',
        backgroundColor: AppColors.primary,
        icon: null,
        duration: const Duration(seconds: 30),
        showLoading: true,
      );
    } else {
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
        duration: const Duration(seconds: 30),
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
  }

  // ✅ ACTION SNACKBAR
  static void showAction({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    BuildContext? context,
  }) {
    if (context != null) {
      _showNativeSnackbar(
        context: context,
        message: message,
        backgroundColor: backgroundColor ?? AppColors.primary,
        icon: icon,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      );
    } else {
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

  // ✅ DISMISS SNACKBAR
  static void dismiss() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  // ✅ DEBOUNCE HELPER
  static void _debounceAndShow(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), callback);
  }

  // ✅ NATIVE FLUTTER SNACKBAR HELPER
  static void _showNativeSnackbar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showLoading = false,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (showLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (icon != null)
            Icon(icon, color: Colors.white, size: 20),
          if (icon != null || showLoading) const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

// ✅ CUSTOM SNACKBAR dengan full customization
  static void showCustom({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    Duration? duration,
    VoidCallback? onTap,
    SnackPosition position = SnackPosition.TOP,
    String? actionLabel, // ✅ Action support
    VoidCallback? onActionPressed, // ✅ Action support
    BuildContext? context,
  }) {
    _debounceAndShow(() {
      if (context != null) {
        _showNativeSnackbar(
          context: context,
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
          duration: duration,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
        );
      } else {
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
          // ✅ Action button support
          mainButton: actionLabel != null && onActionPressed != null
              ? TextButton(
                  onPressed: () {
                    Get.closeCurrentSnackbar();
                    onActionPressed();
                  },
                  child: Text(
                    actionLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          boxShadows: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
      }
    });
  }

// ✅ QUICK ACTION METHODS dengan default styling
  static void showSuccessWithAction({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
    BuildContext? context,
  }) {
    showCustom(
      title: title,
      message: message,
      backgroundColor: AppColors.success,
      textColor: AppColors.textOnPrimary,
      icon: Icons.check_circle,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      context: context,
    );
  }

  static void showErrorWithAction({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
    BuildContext? context,
  }) {
    showCustom(
      title: title,
      message: message,
      backgroundColor: AppColors.error,
      textColor: AppColors.textOnPrimary,
      icon: Icons.error,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      context: context,
    );
  }

// ✅ RETRY ACTION - Common use case
  static void showRetryError({
    required String title,
    required String message,
    required VoidCallback onRetry,
    BuildContext? context,
  }) {
    showErrorWithAction(
      title: title,
      message: message,
      actionLabel: 'Retry',
      onActionPressed: onRetry,
      context: context,
    );
  }

// ✅ UNDO ACTION - Common use case
  static void showUndoSuccess({
    required String title,
    required String message,
    required VoidCallback onUndo,
    BuildContext? context,
  }) {
    showSuccessWithAction(
      title: title,
      message: message,
      actionLabel: 'Undo',
      onActionPressed: onUndo,
      context: context,
    );
  }
}
