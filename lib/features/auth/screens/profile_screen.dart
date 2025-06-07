import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/core/widgets/custom_button.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as custom_error;
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/core/constants/app_constants.dart';

import '../../../Models/store.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading && profileController.user == null) {
          return const LoadingWidget(message: 'Loading profile...');
        }

        if (profileController.hasError && profileController.user == null) {
          return custom_error.ErrorWidget(
            message: profileController.errorMessage,
            onRetry: () => profileController.loadProfile(),
          );
        }

        final user = profileController.user ?? authController.currentUser;
        if (user == null) {
          return const custom_error.ErrorWidget(
            message: 'User data not found',
          );
        }

        return RefreshIndicator(
          onRefresh: () => profileController.loadProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: AppDimensions.spacingXL),
                _buildUserInfo(user),
                const SizedBox(height: AppDimensions.spacingLG),
                _buildRoleSpecificInfo(user),
                const SizedBox(height: AppDimensions.spacingXL),
                _buildActionButtons(authController),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                    ? NetworkImage(user.avatar!)
                    : null,
                child: user.avatar == null || user.avatar!.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: Icon(
                  _getRoleIcon(user.role),
                  color: AppColors.surface,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLG),

          // Name
          Text(
            user.name,
            style: AppTextStyles.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSM),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD,
              vertical: AppDimensions.paddingSM,
            ),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: AppTextStyles.bodyMedium.copyWith(
                color: _getRoleColor(user.role),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(UserModel user) {
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
            'Personal Information',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          const Divider(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone ?? 'Not provided',
          ),
          const Divider(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: user.createdAt != null
                ? _formatDate(user.createdAt!)
                : 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificInfo(UserModel user) {
    switch (user.role) {
      case AppConstants.roleDriver:
        return _buildDriverInfo(user.driver);
      case AppConstants.roleStore:
        return _buildStoreInfo(user.store);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDriverInfo(DriverModel? driverData) {
    if (driverData == null) return const SizedBox.shrink();

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
            'Driver Information',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.directions_car_outlined,
            label: 'Vehicle Number',
            value: driverData.vehicleNumber,
          ),
          const Divider(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.star_outline,
            label: 'Rating',
            value: driverData.displayRating,
          ),
          const Divider(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.circle,
            label: 'Status',
            value: driverData.statusDisplayName,
            valueColor: _getDriverStatusColor(driverData.status),
          ),
          if (driverData.hasLocation) ...[
            const Divider(height: AppDimensions.spacingLG),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Last Location',
              value: '${driverData.latitude}, ${driverData.longitude}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStoreInfo(StoreModel? storeModel) {
    if (storeModel == null) return const SizedBox.shrink();

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
            'Store Information',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.store_outlined,
            label: 'Store Name',
            value: storeModel.name,
          ),
          if (storeModel.description != null) ...[
            const Divider(height: AppDimensions.spacingLG),
            _buildInfoRow(
              icon: Icons.description_outlined,
              label: 'Description',
              value: storeModel.description!,
            ),
          ],
          if (storeModel.address != null) ...[
            const Divider(height: AppDimensions.spacingLG),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: storeModel.address!,
            ),
          ],
          const Divider(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.access_time_outlined,
            label: 'Operating Hours',
            value: storeModel.openHours,
          ),
          const Divider(height: AppDimensions.spacingLG),
          _buildInfoRow(
            icon: Icons.circle,
            label: 'Status',
            value: storeModel.statusDisplayName,
            valueColor: _getStoreStatusColor(storeModel.status),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AuthController authController) {
    return Column(
      children: [
        CustomButton.outlined(
          text: 'Edit Profile',
          onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
          icon: Icons.edit_outlined,
          isExpanded: true,
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        CustomButton.outlined(
          text: 'Settings',
          onPressed: () => Get.toNamed(Routes.SETTINGS),
          icon: Icons.settings_outlined,
          isExpanded: true,
        ),
        const SizedBox(height: AppDimensions.spacingLG),
        CustomButton(
          text: 'Logout',
          onPressed: () => _showLogoutDialog(authController),
          icon: Icons.logout,
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.textOnPrimary,
          isExpanded: true,
        ),
      ],
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleDriver:
        return AppColors.driverActive;
      case AppConstants.roleStore:
        return AppColors.storeOpen;
      case AppConstants.roleAdmin:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleDriver:
        return Icons.delivery_dining;
      case AppConstants.roleStore:
        return Icons.store;
      case AppConstants.roleAdmin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        return 'Customer';
      case AppConstants.roleDriver:
        return 'Driver';
      case AppConstants.roleStore:
        return 'Store Owner';
      case AppConstants.roleAdmin:
        return 'Administrator';
      default:
        return role;
    }
  }

  Color _getDriverStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.driverActive;
      case 'busy':
        return AppColors.driverBusy;
      case 'inactive':
        return AppColors.driverInactive;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStoreStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.storeOpen;
      case 'inactive':
        return AppColors.storeClosed;
      case 'suspended':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
