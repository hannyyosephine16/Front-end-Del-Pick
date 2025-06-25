// 3. lib/core/widgets/loading_widget.dart (FIXED - update sesuai penggunaan)
import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showSkeletons;
  final Widget? skeletonWidget;

  const LoadingWidget({
    super.key,
    this.message,
    this.showSkeletons = false,
    this.skeletonWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Jika ada skeleton, tampilkan skeleton instead of spinner
    if (showSkeletons && skeletonWidget != null) {
      return skeletonWidget!;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spinner yang lebih ringan
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Loading overlay yang tidak blocking UI
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: LoadingWidget(message: message),
          ),
      ],
    );
  }
}
