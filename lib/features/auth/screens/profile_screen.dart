import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Avatar and Basic Info
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingXL,
                    0,
                    AppDimensions.paddingXL,
                    AppDimensions.paddingXL,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.spacingMD),
                      // Profile Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user.avatar != null
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: user.avatar == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.spacingMD),

                      // Name
                      Text(
                        user.name,
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSM),

                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleDisplayName(user.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXL),

              // Profile Information Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSectionTitle('Informasi Dasar'),
                    const SizedBox(height: AppDimensions.spacingMD),

                    _buildInfoCard([
                      _buildInfoRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: user.email,
                      ),
                      if (user.phone != null)
                        _buildInfoRow(
                          icon: Icons.phone,
                          label: 'Nomor Telepon',
                          value: user.phone!,
                        ),
                    ]),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // Role-specific Information
                    if (authController.isDriver) ...[
                      _buildDriverSpecificInfo(authController),
                    ] else if (authController.isStore) ...[
                      _buildStoreSpecificInfo(authController),
                    ] else if (authController.isCustomer) ...[
                      _buildCustomerSpecificInfo(authController),
                    ],

                    const SizedBox(height: AppDimensions.spacingXL),

                    // Settings Section
                    _buildSectionTitle('Pengaturan'),
                    const SizedBox(height: AppDimensions.spacingMD),

                    _buildSettingsCard(),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _showLogoutDialog(context, authController),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingMD,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout),
                            const SizedBox(width: 8),
                            Text(
                              'Keluar',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXL),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDriverSpecificInfo(AuthController authController) {
    // Get driver data from storage or API
    return Obx(() {
      // You might need to get this from a driver controller
      // For now, using placeholder data
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informasi Driver'),
          const SizedBox(height: AppDimensions.spacingMD),

          _buildInfoCard([
            _buildInfoRow(
              icon: Icons.directions_car,
              label: 'Nomor Kendaraan',
              value: 'B 1234 XYZ', // Get from driver data
            ),
            _buildInfoRow(
              icon: Icons.star,
              label: 'Rating',
              value: '4.8 (125 ulasan)', // Get from driver data
            ),
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Status',
              value: 'Aktif', // Get from driver status
              valueColor: AppColors.success,
            ),
          ]),

          const SizedBox(height: AppDimensions.spacingMD),

          // Driver Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Pengantaran',
                  '245',
                  Icons.delivery_dining,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: _buildStatCard(
                  'Pendapatan Bulan Ini',
                  'Rp 2.5M',
                  Icons.account_balance_wallet,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStoreSpecificInfo(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informasi Toko'),
        const SizedBox(height: AppDimensions.spacingMD),

        _buildInfoCard([
          _buildInfoRow(
            icon: Icons.store,
            label: 'Nama Toko',
            value: 'Warung Makan Sederhana', // Get from store data
          ),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Alamat',
            value: 'Jl. Sisingamangaraja No. 123', // Get from store data
          ),
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Jam Operasional',
            value: '08:00 - 22:00', // Get from store data
          ),
          _buildInfoRow(
            icon: Icons.check_circle,
            label: 'Status Toko',
            value: 'Buka',
            valueColor: AppColors.success,
          ),
        ]),

        const SizedBox(height: AppDimensions.spacingMD),

        // Store Stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Menu',
                '24',
                Icons.restaurant_menu,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: _buildStatCard(
                'Pesanan Bulan Ini',
                '156',
                Icons.shopping_bag,
                AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSpecificInfo(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informasi Customer'),
        const SizedBox(height: AppDimensions.spacingMD),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Pesanan',
                '28',
                Icons.shopping_bag,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: _buildStatCard(
                'Toko Favorit',
                '5',
                Icons.favorite,
                AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h5.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
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
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.lock,
            title: 'Ubah Password',
            onTap: () {
              // Navigate to change password
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifikasi',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Bantuan',
            onTap: () {
              // Navigate to help
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.info,
            title: 'Tentang Aplikasi',
            onTap: () {
              // Show about dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        return 'Pelanggan';
      case AppConstants.roleDriver:
        return 'Driver';
      case AppConstants.roleStore:
        return 'Pemilik Toko';
      case AppConstants.roleAdmin:
        return 'Administrator';
      default:
        return role;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.logout();
              },
              child: Text(
                'Keluar',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
