// lib/features/driver/widgets/order_statistics_card.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class OrderStatisticsCard extends StatelessWidget {
  final int activeOrders;
  final int completedOrders;
  final int todayDeliveries;
  final String todayEarnings;
  final VoidCallback? onTap;

  const OrderStatisticsCard({
    super.key,
    required this.activeOrders,
    required this.completedOrders,
    required this.todayDeliveries,
    required this.todayEarnings,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statistik Hari Ini',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingSM),
                      decoration: BoxDecoration(
                        color: AppColors.textOnPrimary.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: AppColors.textOnPrimary,
                        size: AppDimensions.iconMD,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXL),

                // Statistics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.pending_actions,
                        label: 'Aktif',
                        value: activeOrders.toString(),
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingLG),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.check_circle,
                        label: 'Selesai',
                        value: completedOrders.toString(),
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingLG),

                // Today's Performance
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(
                      color: AppColors.textOnPrimary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTodayStatItem(
                            icon: Icons.delivery_dining,
                            label: 'Pengiriman Hari Ini',
                            value: todayDeliveries.toString(),
                          ),
                          _buildTodayStatItem(
                            icon: Icons.monetization_on,
                            label: 'Pendapatan Hari Ini',
                            value: todayEarnings,
                            isEarnings: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingMD),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.trending_up,
                        label: 'Performa',
                        onTap: () {
                          // Navigate to performance screen
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSM),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.history,
                        label: 'Riwayat',
                        onTap: () {
                          // Navigate to history screen
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppDimensions.iconMD,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool isEarnings = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.textOnPrimary.withOpacity(0.8),
                size: AppDimensions.iconSM,
              ),
              const SizedBox(width: AppDimensions.spacingXS),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
              fontSize: isEarnings ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.textOnPrimary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSM,
            horizontal: AppDimensions.paddingMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.textOnPrimary,
                size: AppDimensions.iconSM,
              ),
              const SizedBox(width: AppDimensions.spacingXS),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
