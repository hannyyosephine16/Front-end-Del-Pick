import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/features/driver/controllers/driver_profile_controller.dart'; // ✅ ADDED: Only for driver
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/widgets/custom_button.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // ✅ ADDED: Only get DriverProfileController if user is driver
    DriverProfileController? driverController;
    if (authController.userRole == AppConstants.roleDriver) {
      try {
        driverController = Get.find<DriverProfileController>();
      } catch (e) {
        // Gracefully handle if controller not found
        print('DriverProfileController not found: $e');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Obx(
        () => authController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Header - UNCHANGED
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingXL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLG),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Avatar - UNCHANGED
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                            child: authController.userAvatar != null
                                ? ClipOval(
                                    child: Image.network(
                                      authController.userAvatar!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        _getRoleIcon(authController.userRole),
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    _getRoleIcon(authController.userRole),
                                    size: 50,
                                    color: AppColors.primary,
                                  ),
                          ),
                          const SizedBox(height: AppDimensions.spacingLG),

                          // User Name - UNCHANGED
                          Text(
                            authController.userName.isNotEmpty
                                ? authController.userName
                                : 'User Name',
                            style: AppTextStyles.h4,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.spacingSM),

                          // Role Badge - ✅ ENHANCED: Show status for driver only
                          _buildRoleBadge(authController, driverController),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // Profile Information - ✅ ENHANCED: Driver info uses real data
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLG),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.all(AppDimensions.paddingLG),
                            child: Text(
                              _getInfoSectionTitle(authController.userRole),
                              style: AppTextStyles.h6,
                            ),
                          ),
                          const Divider(height: 1),

                          // Email - UNCHANGED
                          _buildInfoTile(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            subtitle: authController.userEmail.isNotEmpty
                                ? authController.userEmail
                                : 'No email',
                          ),

                          // Phone - UNCHANGED
                          _buildInfoTile(
                            icon: Icons.phone_outlined,
                            title: 'Phone',
                            subtitle:
                                authController.userPhone?.isNotEmpty == true
                                    ? authController.userPhone!
                                    : 'No phone number',
                          ),

                          // ✅ MODIFIED: Role-specific information (driver uses real data)
                          ..._buildRoleSpecificInfo(
                              authController.userRole, driverController),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // ✅ NEW: Driver Stats Section (ONLY for drivers)
                    if (authController.userRole == AppConstants.roleDriver &&
                        driverController != null)
                      _buildDriverStatsSection(driverController),

                    // Add spacing only if driver stats section is shown
                    if (authController.userRole == AppConstants.roleDriver &&
                        driverController != null)
                      const SizedBox(height: AppDimensions.spacingXL),

                    // Quick Actions - UNCHANGED for other roles
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLG),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.all(AppDimensions.paddingLG),
                            child: Text(
                              'Quick Actions',
                              style: AppTextStyles.h6,
                            ),
                          ),
                          const Divider(height: 1),

                          _buildActionTile(
                            icon: Icons.edit_outlined,
                            title: 'Edit Profile',
                            subtitle: 'Update your information',
                            onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
                          ),

                          // Role-specific actions - UNCHANGED
                          ..._buildRoleSpecificActions(authController.userRole),

                          _buildActionTile(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            subtitle: 'Get help and support',
                            onTap: () {
                              // Navigate to help page
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXXL),

                    // Logout Button - UNCHANGED
                    CustomButton(
                      text: 'Logout',
                      onPressed: () =>
                          _showLogoutDialog(context, authController),
                      type: ButtonType.outlined,
                      borderColor: AppColors.error,
                      foregroundColor: AppColors.error,
                      icon: Icons.logout,
                      isExpanded: true,
                    ),

                    const SizedBox(height: AppDimensions.spacingLG),
                  ],
                ),
              ),
      ),
    );
  }

  // ✅ NEW: Enhanced role badge with driver status
  Widget _buildRoleBadge(AuthController authController,
      DriverProfileController? driverController) {
    // For non-driver roles, show normal badge (UNCHANGED)
    if (authController.userRole != AppConstants.roleDriver ||
        driverController == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
        decoration: BoxDecoration(
          color: _getRoleColor(authController.userRole).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: _getRoleColor(authController.userRole),
            width: 1,
          ),
        ),
        child: Text(
          _getRoleDisplayName(authController.userRole),
          style: AppTextStyles.labelMedium.copyWith(
            color: _getRoleColor(authController.userRole),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // ✅ ENHANCED: For driver, show role + status
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD,
              vertical: AppDimensions.paddingSM,
            ),
            decoration: BoxDecoration(
              color: _getRoleColor(authController.userRole).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              border: Border.all(
                color: _getRoleColor(authController.userRole),
                width: 1,
              ),
            ),
            child: Text(
              _getRoleDisplayName(authController.userRole),
              style: AppTextStyles.labelMedium.copyWith(
                color: _getRoleColor(authController.userRole),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSM),
          // Status Badge (only for driver)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD,
              vertical: AppDimensions.paddingSM,
            ),
            decoration: BoxDecoration(
              color: driverController.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              border: Border.all(
                color: driverController.statusColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: driverController.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  driverController.statusDisplayName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: driverController.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ✅ NEW: Driver Stats Section (ONLY for drivers)
  Widget _buildDriverStatsSection(DriverProfileController driverController) {
    return Obx(() {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Text(
                'Performance Stats',
                style: AppTextStyles.h6,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.spacingMD,
                mainAxisSpacing: AppDimensions.spacingMD,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Total Earnings',
                    driverController.formattedTotalEarnings,
                    Icons.monetization_on,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'Monthly Earnings',
                    driverController.formattedMonthlyEarnings,
                    Icons.calendar_month,
                    AppColors.info,
                  ),
                  _buildStatCard(
                    'Total Deliveries',
                    '${driverController.driverStats['totalDeliveries'] ?? 0}',
                    Icons.delivery_dining,
                    AppColors.secondary,
                  ),
                  _buildStatCard(
                    'Completion Rate',
                    '${driverController.driverStats['completionRate'] ?? 0}%',
                    Icons.check_circle,
                    AppColors.accent,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            style: AppTextStyles.h6.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ALL METHODS BELOW ARE UNCHANGED EXCEPT _buildRoleSpecificInfo

  IconData _getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        return Icons.person;
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

  Color _getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        return AppColors.primary;
      case AppConstants.roleDriver:
        return AppColors.secondary;
      case AppConstants.roleStore:
        return AppColors.accent;
      case AppConstants.roleAdmin:
        return AppColors.error;
      default:
        return AppColors.primary;
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
        return role.capitalizeFirst ?? role;
    }
  }

  String _getInfoSectionTitle(String role) {
    switch (role) {
      case AppConstants.roleStore:
        return 'Store Information';
      case AppConstants.roleDriver:
        return 'Driver Information';
      case AppConstants.roleAdmin:
        return 'Admin Information';
      default:
        return 'Personal Information';
    }
  }

  // ✅ MODIFIED: Only driver section uses real data, others UNCHANGED
  List<Widget> _buildRoleSpecificInfo(
      String role, DriverProfileController? driverController) {
    switch (role) {
      case AppConstants.roleStore: // ← UNCHANGED
        return [
          _buildInfoTile(
            icon: Icons.category_outlined,
            title: 'Store Type',
            subtitle: 'Restaurant',
          ),
          _buildInfoTile(
            icon: Icons.access_time_outlined,
            title: 'Operating Hours',
            subtitle: '08:00 - 22:00',
          ),
          _buildInfoTile(
            icon: Icons.location_on_outlined,
            title: 'Address',
            subtitle: 'Jl. Sisingamangaraja No. 123, Medan',
            isLast: true,
          ),
        ];
      case AppConstants
            .roleDriver: // ✅ MODIFIED: Uses real data from controller
        if (driverController != null) {
          return [
            Obx(() => _buildInfoTile(
                  icon: Icons.directions_car_outlined,
                  title: 'Vehicle Number',
                  subtitle: driverController.vehicleNumber.isNotEmpty
                      ? driverController.vehicleNumber
                      : 'Not set',
                )),
            Obx(() => _buildInfoTile(
                  icon: Icons.star_outlined,
                  title: 'Rating',
                  subtitle:
                      '${driverController.formattedRating} ⭐ (${driverController.reviewsCount} reviews)',
                )),
            Obx(() => _buildInfoTile(
                  icon: Icons.circle_outlined,
                  title: 'Status',
                  subtitle: driverController.statusDisplayName,
                  isLast: true,
                )),
          ];
        } else {
          // Fallback if controller not available
          return [
            _buildInfoTile(
              icon: Icons.directions_car_outlined,
              title: 'Vehicle Number',
              subtitle: 'Loading...',
            ),
            _buildInfoTile(
              icon: Icons.star_outlined,
              title: 'Rating',
              subtitle: 'Loading...',
            ),
            _buildInfoTile(
              icon: Icons.circle_outlined,
              title: 'Status',
              subtitle: 'Loading...',
              isLast: true,
            ),
          ];
        }
      case AppConstants.roleAdmin: // ← UNCHANGED
        return [
          _buildInfoTile(
            icon: Icons.work_outlined,
            title: 'Department',
            subtitle: 'Operations',
          ),
          _buildInfoTile(
            icon: Icons.security_outlined,
            title: 'Access Level',
            subtitle: 'Full Access',
            isLast: true,
          ),
        ];
      default: // ← UNCHANGED (Customer)
        return [
          _buildInfoTile(
            icon: Icons.location_on_outlined,
            title: 'Address',
            subtitle: 'Jl. Sudirman No. 456, Medan',
            isLast: true,
          ),
        ];
    }
  }

  // ← ALL UNCHANGED
  List<Widget> _buildRoleSpecificActions(String role) {
    switch (role) {
      case AppConstants.roleStore:
        return [
          _buildActionTile(
            icon: Icons.settings_outlined,
            title: 'Store Settings',
            subtitle: 'Manage store preferences',
            onTap: () => Get.toNamed(Routes.STORE_SETTINGS),
          ),
          _buildActionTile(
            icon: Icons.analytics_outlined,
            title: 'View Analytics',
            subtitle: 'Check store performance',
            onTap: () => Get.toNamed(Routes.STORE_ANALYTICS),
          ),
          _buildActionTile(
            icon: Icons.restaurant_menu_outlined,
            title: 'Manage Menu',
            subtitle: 'Add or edit menu items',
            onTap: () => Get.toNamed(Routes.MENU_MANAGEMENT),
          ),
        ];
      case AppConstants.roleDriver:
        return [
          _buildActionTile(
            icon: Icons.settings_outlined,
            title: 'Driver Settings',
            subtitle: 'Manage driver preferences',
            onTap: () => Get.toNamed(Routes.DRIVER_SETTINGS),
          ),
          _buildActionTile(
            icon: Icons.monetization_on_outlined,
            title: 'View Earnings',
            subtitle: 'Check your earnings',
            onTap: () => Get.toNamed(Routes.DRIVER_EARNINGS),
          ),
        ];
      case AppConstants.roleAdmin:
        return [
          _buildActionTile(
            icon: Icons.settings_outlined,
            title: 'System Settings',
            subtitle: 'Manage system preferences',
            onTap: () => Get.toNamed(Routes.SYSTEM_SETTINGS),
          ),
          _buildActionTile(
            icon: Icons.people_outlined,
            title: 'User Management',
            subtitle: 'Manage users and roles',
            onTap: () => Get.toNamed(Routes.USER_MANAGEMENT),
          ),
        ];
      default:
        return [
          _buildActionTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () => Get.toNamed(Routes.SETTINGS),
          ),
        ];
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingSM,
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 72),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingSM,
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 72),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/features/auth/controllers/auth_controller.dart';
// import 'package:del_pick/app/themes/app_colors.dart';
// import 'package:del_pick/app/themes/app_text_styles.dart';
// import 'package:del_pick/app/themes/app_dimensions.dart';
// import 'package:del_pick/core/widgets/custom_button.dart';
// import 'package:del_pick/app/routes/app_routes.dart';
// import 'package:del_pick/core/constants/app_constants.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.find<AuthController>();
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.textOnPrimary,
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
//             icon: const Icon(Icons.edit),
//           ),
//         ],
//       ),
//       body: Obx(
//         () => authController.isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 padding: const EdgeInsets.all(AppDimensions.paddingLG),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Profile Header
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(AppDimensions.paddingXL),
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         borderRadius:
//                             BorderRadius.circular(AppDimensions.radiusLG),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.shadow,
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           // Avatar
//                           Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColors.primary.withOpacity(0.1),
//                               border: Border.all(
//                                 color: AppColors.primary,
//                                 width: 3,
//                               ),
//                             ),
//                             child: authController.userAvatar != null
//                                 ? ClipOval(
//                                     child: Image.network(
//                                       authController.userAvatar!,
//                                       width: 100,
//                                       height: 100,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) => Icon(
//                                         _getRoleIcon(authController.userRole),
//                                         size: 50,
//                                         color: AppColors.primary,
//                                       ),
//                                     ),
//                                   )
//                                 : Icon(
//                                     _getRoleIcon(authController.userRole),
//                                     size: 50,
//                                     color: AppColors.primary,
//                                   ),
//                           ),
//                           const SizedBox(height: AppDimensions.spacingLG),
//
//                           // User Name
//                           Text(
//                             authController.userName.isNotEmpty
//                                 ? authController.userName
//                                 : 'User Name',
//                             style: AppTextStyles.h4,
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: AppDimensions.spacingSM),
//
//                           // Role Badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: AppDimensions.paddingMD,
//                               vertical: AppDimensions.paddingSM,
//                             ),
//                             decoration: BoxDecoration(
//                               color: _getRoleColor(authController.userRole)
//                                   .withOpacity(0.1),
//                               borderRadius:
//                                   BorderRadius.circular(AppDimensions.radiusLG),
//                               border: Border.all(
//                                 color: _getRoleColor(authController.userRole),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Text(
//                               _getRoleDisplayName(authController.userRole),
//                               style: AppTextStyles.labelMedium.copyWith(
//                                 color: _getRoleColor(authController.userRole),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: AppDimensions.spacingXL),
//
//                     // Profile Information
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         borderRadius:
//                             BorderRadius.circular(AppDimensions.radiusLG),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.shadow,
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding:
//                                 const EdgeInsets.all(AppDimensions.paddingLG),
//                             child: Text(
//                               _getInfoSectionTitle(authController.userRole),
//                               style: AppTextStyles.h6,
//                             ),
//                           ),
//                           const Divider(height: 1),
//
//                           // Email
//                           _buildInfoTile(
//                             icon: Icons.email_outlined,
//                             title: 'Email',
//                             subtitle: authController.userEmail.isNotEmpty
//                                 ? authController.userEmail
//                                 : 'No email',
//                           ),
//
//                           // Phone
//                           _buildInfoTile(
//                             icon: Icons.phone_outlined,
//                             title: 'Phone',
//                             subtitle:
//                                 authController.userPhone?.isNotEmpty == true
//                                     ? authController.userPhone!
//                                     : 'No phone number',
//                           ),
//
//                           // Role-specific information
//                           ..._buildRoleSpecificInfo(authController.userRole),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: AppDimensions.spacingXL),
//
//                     // Quick Actions
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         borderRadius:
//                             BorderRadius.circular(AppDimensions.radiusLG),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.shadow,
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding:
//                                 const EdgeInsets.all(AppDimensions.paddingLG),
//                             child: Text(
//                               'Quick Actions',
//                               style: AppTextStyles.h6,
//                             ),
//                           ),
//                           const Divider(height: 1),
//
//                           _buildActionTile(
//                             icon: Icons.edit_outlined,
//                             title: 'Edit Profile',
//                             subtitle: 'Update your information',
//                             onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
//                           ),
//
//                           // Role-specific actions
//                           ..._buildRoleSpecificActions(authController.userRole),
//
//                           _buildActionTile(
//                             icon: Icons.help_outline,
//                             title: 'Help & Support',
//                             subtitle: 'Get help and support',
//                             onTap: () {
//                               // Navigate to help page
//                             },
//                             isLast: true,
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: AppDimensions.spacingXXL),
//
//                     // Logout Button
//                     CustomButton(
//                       text: 'Logout',
//                       onPressed: () =>
//                           _showLogoutDialog(context, authController),
//                       type: ButtonType.outlined,
//                       borderColor: AppColors.error,
//                       foregroundColor: AppColors.error,
//                       icon: Icons.logout,
//                       isExpanded: true,
//                     ),
//
//                     const SizedBox(height: AppDimensions.spacingLG),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
//
//   IconData _getRoleIcon(String role) {
//     switch (role) {
//       case AppConstants.roleCustomer:
//         return Icons.person;
//       case AppConstants.roleDriver:
//         return Icons.delivery_dining;
//       case AppConstants.roleStore:
//         return Icons.store;
//       case AppConstants.roleAdmin:
//         return Icons.admin_panel_settings;
//       default:
//         return Icons.person;
//     }
//   }
//
//   Color _getRoleColor(String role) {
//     switch (role) {
//       case AppConstants.roleCustomer:
//         return AppColors.primary;
//       case AppConstants.roleDriver:
//         return AppColors.secondary;
//       case AppConstants.roleStore:
//         return AppColors.accent;
//       case AppConstants.roleAdmin:
//         return AppColors.error;
//       default:
//         return AppColors.primary;
//     }
//   }
//
//   String _getRoleDisplayName(String role) {
//     switch (role) {
//       case AppConstants.roleCustomer:
//         return 'Customer';
//       case AppConstants.roleDriver:
//         return 'Driver';
//       case AppConstants.roleStore:
//         return 'Store Owner';
//       case AppConstants.roleAdmin:
//         return 'Administrator';
//       default:
//         return role.capitalizeFirst ?? role;
//     }
//   }
//
//   String _getInfoSectionTitle(String role) {
//     switch (role) {
//       case AppConstants.roleStore:
//         return 'Store Information';
//       case AppConstants.roleDriver:
//         return 'Driver Information';
//       case AppConstants.roleAdmin:
//         return 'Admin Information';
//       default:
//         return 'Personal Information';
//     }
//   }
//
//   List<Widget> _buildRoleSpecificInfo(String role) {
//     switch (role) {
//       case AppConstants.roleStore:
//         return [
//           _buildInfoTile(
//             icon: Icons.category_outlined,
//             title: 'Store Type',
//             subtitle: 'Restaurant',
//           ),
//           _buildInfoTile(
//             icon: Icons.access_time_outlined,
//             title: 'Operating Hours',
//             subtitle: '08:00 - 22:00',
//           ),
//           _buildInfoTile(
//             icon: Icons.location_on_outlined,
//             title: 'Address',
//             subtitle: 'Jl. Sisingamangaraja No. 123, Medan',
//             isLast: true,
//           ),
//         ];
//       case AppConstants.roleDriver:
//         return [
//           _buildInfoTile(
//             icon: Icons.directions_car_outlined,
//             title: 'Vehicle Number',
//             subtitle: 'B 1234 XYZ',
//           ),
//           _buildInfoTile(
//             icon: Icons.star_outlined,
//             title: 'Rating',
//             subtitle: '4.8 ⭐ (124 reviews)',
//           ),
//           _buildInfoTile(
//             icon: Icons.circle_outlined,
//             title: 'Status',
//             subtitle: 'Active',
//             isLast: true,
//           ),
//         ];
//       case AppConstants.roleAdmin:
//         return [
//           _buildInfoTile(
//             icon: Icons.work_outlined,
//             title: 'Department',
//             subtitle: 'Operations',
//           ),
//           _buildInfoTile(
//             icon: Icons.security_outlined,
//             title: 'Access Level',
//             subtitle: 'Full Access',
//             isLast: true,
//           ),
//         ];
//       default:
//         return [
//           _buildInfoTile(
//             icon: Icons.location_on_outlined,
//             title: 'Address',
//             subtitle: 'Jl. Sudirman No. 456, Medan',
//             isLast: true,
//           ),
//         ];
//     }
//   }
//
//   List<Widget> _buildRoleSpecificActions(String role) {
//     switch (role) {
//       case AppConstants.roleStore:
//         return [
//           _buildActionTile(
//             icon: Icons.settings_outlined,
//             title: 'Store Settings',
//             subtitle: 'Manage store preferences',
//             onTap: () => Get.toNamed(Routes.STORE_SETTINGS),
//           ),
//           _buildActionTile(
//             icon: Icons.analytics_outlined,
//             title: 'View Analytics',
//             subtitle: 'Check store performance',
//             onTap: () => Get.toNamed(Routes.STORE_ANALYTICS),
//           ),
//           _buildActionTile(
//             icon: Icons.restaurant_menu_outlined,
//             title: 'Manage Menu',
//             subtitle: 'Add or edit menu items',
//             onTap: () => Get.toNamed(Routes.MENU_MANAGEMENT),
//           ),
//         ];
//       case AppConstants.roleDriver:
//         return [
//           _buildActionTile(
//             icon: Icons.settings_outlined,
//             title: 'Driver Settings',
//             subtitle: 'Manage driver preferences',
//             onTap: () => Get.toNamed(Routes.DRIVER_SETTINGS),
//           ),
//           _buildActionTile(
//             icon: Icons.monetization_on_outlined,
//             title: 'View Earnings',
//             subtitle: 'Check your earnings',
//             onTap: () => Get.toNamed(Routes.DRIVER_EARNINGS),
//           ),
//         ];
//       case AppConstants.roleAdmin:
//         return [
//           _buildActionTile(
//             icon: Icons.settings_outlined,
//             title: 'System Settings',
//             subtitle: 'Manage system preferences',
//             onTap: () => Get.toNamed(Routes.SYSTEM_SETTINGS),
//           ),
//           _buildActionTile(
//             icon: Icons.people_outlined,
//             title: 'User Management',
//             subtitle: 'Manage users and roles',
//             onTap: () => Get.toNamed(Routes.USER_MANAGEMENT),
//           ),
//         ];
//       default:
//         return [
//           _buildActionTile(
//             icon: Icons.settings_outlined,
//             title: 'Settings',
//             subtitle: 'App preferences',
//             onTap: () => Get.toNamed(Routes.SETTINGS),
//           ),
//         ];
//     }
//   }
//
//   Widget _buildInfoTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     bool isLast = false,
//   }) {
//     return Column(
//       children: [
//         ListTile(
//           leading: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: AppColors.primary,
//               size: 20,
//             ),
//           ),
//           title: Text(
//             title,
//             style: AppTextStyles.labelMedium.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//           subtitle: Text(
//             subtitle,
//             style: AppTextStyles.bodyMedium,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingLG,
//             vertical: AppDimensions.paddingSM,
//           ),
//         ),
//         if (!isLast) const Divider(height: 1, indent: 72),
//       ],
//     );
//   }
//
//   Widget _buildActionTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     bool isLast = false,
//   }) {
//     return Column(
//       children: [
//         ListTile(
//           leading: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.secondary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: AppColors.secondary,
//               size: 20,
//             ),
//           ),
//           title: Text(
//             title,
//             style: AppTextStyles.bodyMedium.copyWith(
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           subtitle: Text(
//             subtitle,
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//           trailing: const Icon(
//             Icons.arrow_forward_ios,
//             size: 16,
//             color: AppColors.textSecondary,
//           ),
//           onTap: onTap,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingLG,
//             vertical: AppDimensions.paddingSM,
//           ),
//         ),
//         if (!isLast) const Divider(height: 1, indent: 72),
//       ],
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context, AuthController authController) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               authController.logout();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.error,
//               foregroundColor: AppColors.textOnPrimary,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/features/auth/controllers/auth_controller.dart';
// import 'package:del_pick/core/widgets/loading_widget.dart';
// import 'package:del_pick/app/themes/app_colors.dart';
// import 'package:del_pick/app/themes/app_text_styles.dart';
// import 'package:del_pick/app/themes/app_dimensions.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.find<AuthController>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () => Get.toNamed('/edit_profile'),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (authController.isLoading) {
//           return const LoadingWidget();
//         }
//
//         final user = authController.currentUser;
//         if (user == null) {
//           return const Center(
//             child: Text('No user data available'),
//           );
//         }
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(AppDimensions.paddingLG),
//           child: Column(
//             children: [
//               // Profile Avatar
//               CircleAvatar(
//                 radius: 60,
//                 backgroundImage:
//                     user.avatar != null ? NetworkImage(user.avatar!) : null,
//                 child: user.avatar == null
//                     ? Text(
//                         user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
//                         style: AppTextStyles.h3.copyWith(
//                           color: AppColors.textOnPrimary,
//                         ),
//                       )
//                     : null,
//               ),
//               const SizedBox(height: AppDimensions.spacingLG),
//
//               // User Info
//               _buildInfoCard('Name', user.name),
//               _buildInfoCard('Email', user.email),
//               if (user.phone != null) _buildInfoCard('Phone', user.phone!),
//               _buildInfoCard('Role', user.role.capitalize ?? user.role),
//
//               const SizedBox(height: AppDimensions.spacingXL),
//
//               // Logout Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => _showLogoutDialog(context, authController),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.error,
//                   ),
//                   child: const Text('Logout'),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildInfoCard(String label, String value) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
//       padding: const EdgeInsets.all(AppDimensions.paddingLG),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: AppTextStyles.labelMedium.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingXS),
//           Text(
//             value,
//             style: AppTextStyles.bodyLarge,
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context, AuthController authController) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               authController.logout();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.error,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }
