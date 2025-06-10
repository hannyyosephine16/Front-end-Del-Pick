// lib/features/driver/screens/driver_home_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/driver/controllers/driver_home_controller.dart';
import 'package:del_pick/features/driver/widgets/driver_status_toggle.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah tersedia
    final controller = Get.find<DriverHomeController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Toggle Card - INI YANG DIPERBAIKI
              const DriverStatusCard(
                showEarnings: true,
                showStats: true,
              ),

              const SizedBox(height: AppDimensions.spacingXXL),

              // Quick Stats
              _buildQuickStats(controller),

              const SizedBox(height: AppDimensions.spacingXXL),

              // Current Orders Section
              _buildCurrentOrdersSection(controller),

              const SizedBox(height: AppDimensions.spacingXXL),

              // Action Buttons
              _buildActionButtons(controller),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.textOnPrimary,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, Driver!',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GetBuilder<DriverHomeController>(
                builder: (controller) {
                  return Text(
                    'Status: ${controller.statusDisplayInfo['text']}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.8),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Simple toggle switch in app bar
        GetBuilder<DriverHomeController>(
          builder: (controller) {
            return Padding(
              padding: const EdgeInsets.only(right: AppDimensions.paddingLG),
              child: Center(
                child: Switch.adaptive(
                  value: controller.isOnline,
                  onChanged: controller.canToggleStatus
                      ? (_) => controller.toggleDriverStatus()
                      : null,
                  activeColor: AppColors.textOnPrimary,
                  inactiveThumbColor: AppColors.textOnPrimary.withOpacity(0.7),
                  inactiveTrackColor: AppColors.textOnPrimary.withOpacity(0.3),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats(DriverHomeController controller) {
    return GetBuilder<DriverHomeController>(
      builder: (controller) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pesanan Aktif',
                '${controller.activeOrderCount}',
                Icons.shopping_bag,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: _buildStatCard(
                'Jarak Tempuh',
                controller.formattedTodayDistance,
                Icons.route,
                AppColors.info,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: AppDimensions.iconMD),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingXS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                ),
                child: Icon(icon, color: color, size: AppDimensions.iconSM),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOrdersSection(DriverHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pesanan Saat Ini',
              style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => controller.goToOrders(),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMD),

        // Mock orders - replace with real data
        GetBuilder<DriverHomeController>(
          builder: (controller) {
            if (controller.activeOrderCount == 0) {
              return Container(
                padding: const EdgeInsets.all(AppDimensions.paddingXL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    Text(
                      'Tidak ada pesanan aktif',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      controller.isOnline
                          ? 'Menunggu pesanan masuk...'
                          : 'Aktifkan status untuk menerima pesanan',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildOrderCard(
                  orderId: '#DL001',
                  customerName: 'Andi Pratama',
                  restaurant: 'Warung Makan Sederhana',
                  address: 'Jl. Balige No. 12, Laguboti',
                  distance: '2.5 km',
                  earnings: '15.000',
                  status: 'Ambil Pesanan',
                  statusColor: AppColors.warning,
                ),
                if (controller.activeOrderCount > 1) ...[
                  const SizedBox(height: AppDimensions.spacingMD),
                  _buildOrderCard(
                    orderId: '#DL002',
                    customerName: 'Sari Dewi',
                    restaurant: 'Café Corner',
                    address: 'Jl. Sisingamangaraja No. 45',
                    distance: '1.2 km',
                    earnings: '12.000',
                    status: 'Dalam Perjalanan',
                    statusColor: AppColors.success,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String customerName,
    required String restaurant,
    required String address,
    required String distance,
    required String earnings,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSM,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            customerName,
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            restaurant,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: AppDimensions.iconSM,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spacingXS),
              Expanded(
                child: Text(
                  address,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.route,
                    size: AppDimensions.iconSM,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    distance,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.payments,
                    size: AppDimensions.iconSM,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    'Rp $earnings',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DriverHomeController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.goToMap(),
            icon: const Icon(Icons.location_on),
            label: const Text('Lihat Peta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.goToOrders(),
            icon: const Icon(Icons.history),
            label: const Text('Riwayat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
