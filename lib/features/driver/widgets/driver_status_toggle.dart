// lib/features/driver/widgets/driver_status_toggle.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/driver/controllers/driver_home_controller.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class DriverStatusToggle extends StatelessWidget {
  final bool showLabel;
  final bool showDescription;
  final EdgeInsetsGeometry? padding;
  final bool isCompact;

  const DriverStatusToggle({
    super.key,
    this.showLabel = true,
    this.showDescription = true,
    this.padding,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverHomeController>(
      builder: (controller) {
        final statusInfo = controller.statusDisplayInfo;

        return Container(
          padding: padding ??
              (isCompact
                  ? const EdgeInsets.all(AppDimensions.paddingMD)
                  : const EdgeInsets.all(AppDimensions.paddingLG)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main toggle row
              Row(
                children: [
                  // Status indicator and info
                  Expanded(
                    child: Row(
                      children: [
                        // Status indicator dot
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusInfo['color'],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusInfo['color'].withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: AppDimensions.spacingMD),

                        // Status text and description
                        if (showLabel)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${statusInfo['text']}',
                                  style: isCompact
                                      ? AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        )
                                      : AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                ),
                                if (showDescription && !isCompact)
                                  Text(
                                    statusInfo['description'],
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Toggle switch
                  _buildToggleSwitch(controller),
                ],
              ),

              // Loading indicator when updating
              if (controller.isUpdatingStatus) ...[
                const SizedBox(height: AppDimensions.spacingMD),
                _buildLoadingIndicator(),
              ],

              // Warning message if cannot toggle
              if (!controller.canToggleStatus &&
                  !controller.isUpdatingStatus) ...[
                const SizedBox(height: AppDimensions.spacingMD),
                _buildWarningMessage(controller),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleSwitch(DriverHomeController controller) {
    return Obx(() {
      return Switch.adaptive(
        value: controller.isOnline,
        onChanged: controller.canToggleStatus
            ? (_) => controller.toggleDriverStatus()
            : null,
        activeColor: AppColors.success,
        inactiveThumbColor: AppColors.textSecondary,
        inactiveTrackColor: AppColors.textSecondary.withOpacity(0.3),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    });
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSM),
          Text(
            'Updating status...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage(DriverHomeController controller) {
    String message = '';
    IconData icon = Icons.info;

    if (controller.hasActiveOrders) {
      message = 'Complete ${controller.activeOrderCount} active orders first';
      icon = Icons.shopping_bag;
    } else if (controller.currentStatus == 'busy') {
      message = 'Complete current delivery first';
      icon = Icons.delivery_dining;
    }

    if (message.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppDimensions.spacingSM),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ========================================================================
// Enhanced Status Card Widget
// ========================================================================

class DriverStatusCard extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showEarnings;
  final bool showStats;

  const DriverStatusCard({
    super.key,
    this.onTap,
    this.showEarnings = true,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverHomeController>(
      builder: (controller) {
        final statusInfo = controller.statusDisplayInfo;

        return Container(
          margin: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: controller.isOnline
                  ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                  : [
                      AppColors.textSecondary,
                      AppColors.textSecondary.withOpacity(0.8)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: [
              BoxShadow(
                color: (controller.isOnline
                        ? AppColors.success
                        : AppColors.textSecondary)
                    .withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap ?? () => controller.refreshStatus(),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with status and toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusInfo['text'],
                              style: AppTextStyles.h5.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusInfo['description'],
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textOnPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        _buildToggleSwitch(controller),
                      ],
                    ),

                    // Stats section
                    if (showStats && controller.isOnline) ...[
                      const SizedBox(height: AppDimensions.spacingLG),
                      _buildStatsRow(controller),
                    ],

                    // Earnings section
                    if (showEarnings) ...[
                      const SizedBox(height: AppDimensions.spacingLG),
                      _buildEarningsSection(controller),
                    ],

                    // Loading indicator
                    if (controller.isUpdatingStatus) ...[
                      const SizedBox(height: AppDimensions.spacingMD),
                      Center(child: _buildLoadingIndicator()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleSwitch(DriverHomeController controller) {
    return Obx(() {
      return Switch.adaptive(
        value: controller.isOnline,
        onChanged: controller.canToggleStatus
            ? (_) => controller.toggleDriverStatus()
            : null,
        activeColor: AppColors.textOnPrimary,
        inactiveThumbColor: AppColors.textOnPrimary.withOpacity(0.7),
        inactiveTrackColor: AppColors.textOnPrimary.withOpacity(0.3),
      );
    });
  }

  Widget _buildStatsRow(DriverHomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.delivery_dining,
          label: 'Deliveries',
          value: '${controller.todayDeliveries}',
        ),
        _buildStatItem(
          icon: Icons.route,
          label: 'Distance',
          value: controller.formattedTodayDistance,
        ),
        _buildStatItem(
          icon: Icons.star,
          label: 'Rating',
          value: controller.formattedRating,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textOnPrimary.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textOnPrimary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsSection(DriverHomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Earnings',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textOnPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.formattedTodayEarnings,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Icon(
          Icons.trending_up,
          color: AppColors.textOnPrimary.withOpacity(0.8),
          size: 24,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSM),
          Text(
            'Updating...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
