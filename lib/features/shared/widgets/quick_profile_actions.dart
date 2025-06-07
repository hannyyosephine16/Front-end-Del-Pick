import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class QuickProfileActions extends StatelessWidget {
  const QuickProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser;
      if (user == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            _buildRoleSpecificActions(user.role),
          ],
        ),
      );
    });
  }

  Widget _buildRoleSpecificActions(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        return _buildCustomerActions();
      case AppConstants.roleDriver:
        return _buildDriverActions();
      case AppConstants.roleStore:
        return _buildStoreActions();
      case AppConstants.roleAdmin:
        return _buildAdminActions();
      default:
        return _buildDefaultActions();
    }
  }

  Widget _buildCustomerActions() {
    return Column(
      children: [
        _buildActionRow([
          _buildActionButton(
            icon: Icons.person_outline,
            label: 'Edit Profile',
            onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
          _buildActionButton(
            icon: Icons.location_on_outlined,
            label: 'Addresses',
            onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
          ),
        ]),
        const SizedBox(height: AppDimensions.spacingMD),
        _buildActionRow([
          _buildActionButton(
            icon: Icons.history,
            label: 'Order History',
            onTap: () => Get.toNamed(Routes.ORDER_HISTORY),
          ),
          _buildActionButton(
            icon: Icons.favorite_outline,
            label: 'Favorites',
            onTap: () => Get.toNamed(Routes.FAVORITES),
          ),
        ]),
      ],
    );
  }

  Widget _buildDriverActions() {
    final AuthController authController = Get.find<AuthController>();

    return Column(
      children: [
        _buildActionRow([
          _buildActionButton(
            icon: Icons.person_outline,
            label: 'Edit Profile',
            onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
          _buildActionButton(
            icon: Icons.directions_car_outlined,
            label: 'Vehicle Info',
            onTap: () => _showVehicleInfo(authController.driverData),
          ),
        ]),
        const SizedBox(height: AppDimensions.spacingMD),
        _buildActionRow([
          _buildActionButton(
            icon: Icons.history,
            label: 'Delivery History',
            onTap: () => Get.toNamed(Routes.DRIVER_ORDERS),
          ),
          _buildActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Earnings',
            onTap: () => Get.toNamed(Routes.DRIVER_EARNINGS),
          ),
        ]),
      ],
    );
  }

  Widget _buildStoreActions() {
    return Column(
      children: [
        _buildActionRow([
          _buildActionButton(
            icon: Icons.person_outline,
            label: 'Edit Profile',
            onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
          _buildActionButton(
            icon: Icons.store_outlined,
            label: 'Store Settings',
            onTap: () => Get.toNamed(Routes.STORE_SETTINGS),
          ),
        ]),
        const SizedBox(height: AppDimensions.spacingMD),
        _buildActionRow([
          _buildActionButton(
            icon: Icons.restaurant_menu,
            label: 'Menu',
            onTap: () => Get.toNamed(Routes.MENU_MANAGEMENT),
          ),
          _buildActionButton(
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            onTap: () => Get.toNamed(Routes.STORE_ANALYTICS),
          ),
        ]),
      ],
    );
  }

  Widget _buildAdminActions() {
    return Column(
      children: [
        _buildActionRow([
          _buildActionButton(
            icon: Icons.person_outline,
            label: 'Edit Profile',
            onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
          _buildActionButton(
            icon: Icons.people_outline,
            label: 'User Management',
            onTap: () => Get.toNamed(Routes.USER_MANAGEMENT),
          ),
        ]),
        const SizedBox(height: AppDimensions.spacingMD),
        _buildActionRow([
          _buildActionButton(
            icon: Icons.store_outlined,
            label: 'Store Management',
            onTap: () => Get.toNamed(Routes.STORE_MANAGEMENT),
          ),
          _buildActionButton(
            icon: Icons.analytics_outlined,
            label: 'System Analytics',
            onTap: () => Get.toNamed(Routes.ANALYTICS),
          ),
        ]),
      ],
    );
  }

  Widget _buildDefaultActions() {
    return _buildActionRow([
      _buildActionButton(
        icon: Icons.person_outline,
        label: 'Edit Profile',
        onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
      ),
      _buildActionButton(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () => Get.toNamed(Routes.SETTINGS),
      ),
    ]);
  }

  Widget _buildActionRow(List<Widget> actions) {
    return Row(
      children: actions
          .map((action) => Expanded(child: action))
          .expand((widget) => [widget, const SizedBox(width: 12)])
          .take(actions.length * 2 - 1)
          .toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleInfo(DriverData? driverData) {
    if (driverData == null) {
      Get.snackbar('Info', 'Driver data not available');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Vehicle Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Vehicle Number', driverData.vehicleNumber),
            const SizedBox(height: 8),
            _buildInfoRow('Rating', driverData.formattedRating),
            const SizedBox(height: 8),
            _buildInfoRow('Status', driverData.statusDisplayName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
