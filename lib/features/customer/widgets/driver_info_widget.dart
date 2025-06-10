// lib/features/customer/widgets/driver_info_widget.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

import '../../../data/models/driver/driver_model.dart';

class DriverInfoWidget extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback? onCall;

  const DriverInfoWidget({
    super.key,
    required this.driver,
    this.onCall,
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
            'Your Driver',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            children: [
              // Driver Avatar
              _buildDriverAvatar(),

              const SizedBox(width: AppDimensions.spacingMD),

              // Driver Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    if (driver.vehicleNumber != null) ...[
                      Text(
                        'Vehicle: ${driver.vehicleNumber}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                    ],
                    _buildRatingWidget(),
                  ],
                ),
              ),

              // Call Button
              if (onCall != null) _buildCallButton(),
            ],
          ),

          // Driver Status
          const SizedBox(height: AppDimensions.spacingMD),
          _buildDriverStatus(),
        ],
      ),
    );
  }

  Widget _buildDriverAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: driver.avatar != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                driver.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 30,
      color: AppColors.primary,
    );
  }

  Widget _buildRatingWidget() {
    if (driver.rating == null || driver.rating == 0) {
      return Text(
        'New Driver',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    return Row(
      children: [
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: AppDimensions.spacingXS / 2),
        Text(
          driver.rating!.toStringAsFixed(1),
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (driver.reviewsCount != null && driver.reviewsCount! > 0) ...[
          const SizedBox(width: AppDimensions.spacingXS),
          Text(
            '(${driver.reviewsCount})',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCallButton() {
    return GestureDetector(
      onTap: onCall,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSM),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.phone,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDriverStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSM),
          Expanded(
            child: Text(
              'Driver is on the way to deliver your order',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
