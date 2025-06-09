// lib/features/customer/widgets/mapbox_delivery_map.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class MapboxDeliveryMap extends StatelessWidget {
  final double storeLatitude;
  final double storeLongitude;
  final double customerLatitude;
  final double customerLongitude;
  final double? driverLatitude;
  final double? driverLongitude;

  const MapboxDeliveryMap({
    super.key,
    required this.storeLatitude,
    required this.storeLongitude,
    required this.customerLatitude,
    required this.customerLongitude,
    this.driverLatitude,
    this.driverLongitude,
  });

  @override
  Widget build(BuildContext context) {
    // For now, we'll create a placeholder map widget
    // In a real implementation, you would integrate with Mapbox SDK
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Map placeholder
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppDimensions.spacingSM),
                  Text(
                    'Live Map Tracking',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Driver location will appear here',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Location markers info overlay
          Positioned(
            top: AppDimensions.paddingSM,
            left: AppDimensions.paddingSM,
            right: AppDimensions.paddingSM,
            child: _buildLocationInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSM),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationItem(
            icon: Icons.store,
            label: 'Restaurant',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          if (driverLatitude != null && driverLongitude != null)
            _buildLocationItem(
              icon: Icons.delivery_dining,
              label: 'Driver',
              color: AppColors.warning,
            ),
          if (driverLatitude != null && driverLongitude != null)
            const SizedBox(height: AppDimensions.spacingXS),
          _buildLocationItem(
            icon: Icons.location_on,
            label: 'Delivery Address',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXS),
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppDimensions.spacingXS),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class DeliveryMapInfo extends StatelessWidget {
  final String storeName;
  final String customerAddress;
  final String estimatedTime;

  const DeliveryMapInfo({
    super.key,
    required this.storeName,
    required this.customerAddress,
    required this.estimatedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // From - To
          Row(
            children: [
              Expanded(
                child: _buildLocationPoint(
                  label: 'From',
                  location: storeName,
                  icon: Icons.store,
                  color: AppColors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSM,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              Expanded(
                child: _buildLocationPoint(
                  label: 'To',
                  location: customerAddress,
                  icon: Icons.location_on,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMD),

          // Estimated time
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSM),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppDimensions.spacingXS),
                Text(
                  'ETA: $estimatedTime',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPoint({
    required String label,
    required String location,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppDimensions.spacingXS),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXS / 2),
        Text(
          location,
          style: AppTextStyles.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
