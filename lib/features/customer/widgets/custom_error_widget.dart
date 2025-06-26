// lib/core/widgets/error_widget.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/widgets/custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;
  final String? title;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            Text(
              title ?? 'Oops! Something went wrong',
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingXL),
              CustomButton.primary(
                text: retryText ?? 'Try Again',
                onPressed: onRetry!,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Alternative error widget untuk inline errors
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
          compact ? AppDimensions.paddingMD : AppDimensions.paddingLG),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: compact ? AppDimensions.iconMD : AppDimensions.iconLG,
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Text(
              message,
              style:
                  compact ? AppTextStyles.bodyMedium : AppTextStyles.bodyLarge,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppDimensions.spacingMD),
            CustomButton.text(
              text: 'Retry',
              onPressed: onRetry!,
              size: compact ? ButtonSize.small : ButtonSize.medium,
            ),
          ],
        ],
      ),
    );
  }
}

// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      onRetry: onRetry,
      retryText: 'Retry',
    );
  }
}

// Server error widget
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      icon: Icons.cloud_off,
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later.',
      onRetry: onRetry,
      retryText: 'Try Again',
    );
  }
}

// Not found error widget
class NotFoundErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const NotFoundErrorWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      icon: Icons.search_off,
      title: 'Not Found',
      message: message ?? 'The requested item could not be found.',
      onRetry: onRetry,
      retryText: 'Go Back',
    );
  }
}
