// lib/features/customer/widgets/tracking_timeline_widget.dart
import 'package:flutter/material.dart';
import 'package:del_pick/features/customer/controllers/order_tracking_controller.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class TrackingTimelineWidget extends StatelessWidget {
  final List<TrackingStep> steps;

  const TrackingTimelineWidget({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;

            return _buildTimelineItem(
              step: step,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required TrackingStep step,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        _buildTimelineIndicator(step, isLast),

        const SizedBox(width: AppDimensions.spacingMD),

        // Content
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              bottom: isLast ? 0 : AppDimensions.spacingLG,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: step.isCompleted || step.isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  step.subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: step.isCompleted || step.isActive
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                ),
                if (step.isActive) ...[
                  const SizedBox(height: AppDimensions.spacingSM),
                  _buildActiveIndicator(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineIndicator(TrackingStep step, bool isLast) {
    Color indicatorColor;
    Widget indicatorIcon;

    if (step.isCompleted) {
      indicatorColor = AppColors.success;
      indicatorIcon = const Icon(
        Icons.check,
        color: Colors.white,
        size: 16,
      );
    } else if (step.isActive) {
      indicatorColor = AppColors.primary;
      indicatorIcon = Icon(
        step.icon,
        color: Colors.white,
        size: 16,
      );
    } else {
      indicatorColor = AppColors.textDisabled;
      indicatorIcon = Icon(
        step.icon,
        color: Colors.white,
        size: 16,
      );
    }

    return Column(
      children: [
        // Circle indicator
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
            boxShadow: step.isCompleted || step.isActive
                ? [
                    BoxShadow(
                      color: indicatorColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: indicatorIcon,
        ),

        // Connecting line
        if (!isLast)
          Container(
            width: 2,
            height: 40,
            margin:
                const EdgeInsets.symmetric(vertical: AppDimensions.spacingXS),
            decoration: BoxDecoration(
              color: step.isCompleted ? AppColors.success : AppColors.border,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXS),
          Text(
            'In Progress',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
