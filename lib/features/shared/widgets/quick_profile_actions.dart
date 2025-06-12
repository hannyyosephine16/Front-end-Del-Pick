import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/app/routes/app_routes.dart';

// Create a simple DriverData class to replace the undefined one
class DriverData {
  final String status;
  final String vehicleNumber;
  final double rating;
  final String location;

  DriverData({
    required this.status,
    required this.vehicleNumber,
    required this.rating,
    required this.location,
  });
}

class QuickProfileActions extends StatelessWidget {
  const QuickProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser;
      if (user == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(AppDimensions.marginLG),
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
              'Quick Actions',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppDimensions.spacingLG),

            // Role-specific actions
            if (authController.isCustomer) ..._buildCustomerActions(),
            if (authController.isDriver) ..._buildDriverActions(),
            if (authController.isStore) ..._buildStoreActions(),
          ],
        ),
      );
    });
  }

  List<Widget> _buildCustomerActions() {
    return [
      _buildActionTile(
        icon: Icons.restaurant_menu,
        title: 'Browse Restaurants',
        subtitle: 'Find nearby restaurants',
        onTap: () => Get.toNamed(Routes.STORE_LIST),
      ),
      _buildActionTile(
        icon: Icons.history,
        title: 'Order History',
        subtitle: 'View past orders',
        onTap: () => Get.toNamed(Routes.ORDER_HISTORY),
      ),
      _buildActionTile(
        icon: Icons.shopping_cart,
        title: 'Cart',
        subtitle: 'View your cart',
        onTap: () => Get.toNamed(Routes.CART),
      ),
    ];
  }

  List<Widget> _buildDriverActions() {
    return [
      _buildActionTile(
        icon: Icons.delivery_dining,
        title: 'Active Deliveries',
        subtitle: 'View current deliveries',
        onTap: () => Get.toNamed(Routes.DRIVER_ORDERS),
      ),
      _buildActionTile(
        icon: Icons.location_on,
        title: 'Update Location',
        subtitle: 'Update your current location',
        onTap: () => _updateDriverLocation(),
      ),
      _buildActionTile(
        icon: Icons.monetization_on,
        title: 'Earnings',
        subtitle: 'View your earnings',
        onTap: () => Get.toNamed(Routes.DRIVER_EARNINGS),
      ),
    ];
  }

  List<Widget> _buildStoreActions() {
    return [
      _buildActionTile(
        icon: Icons.dashboard,
        title: 'Dashboard',
        subtitle: 'View store dashboard',
        onTap: () => Get.toNamed(Routes.STORE_DASHBOARD),
      ),
      _buildActionTile(
        icon: Icons.menu_book,
        title: 'Manage Menu',
        subtitle: 'Update your menu',
        onTap: () => Get.toNamed(Routes.MENU_MANAGEMENT),
      ),
      _buildActionTile(
        icon: Icons.receipt_long,
        title: 'Orders',
        subtitle: 'View incoming orders',
        onTap: () => Get.toNamed(Routes.STORE_ORDERS),
      ),
    ];
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSM),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.iconMD,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: AppDimensions.iconSM,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _updateDriverLocation() {
    // Implementation for updating driver location
    Get.snackbar(
      'Location Update',
      'Driver location update feature will be implemented here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
