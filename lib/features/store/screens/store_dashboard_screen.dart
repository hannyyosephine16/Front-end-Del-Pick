import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';

class StoreDashboardScreen extends StatelessWidget {
  const StoreDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.store, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        authController.currentUser?.name ?? 'Store Name',
                        style: AppTextStyles.appBarTitle,
                        overflow: TextOverflow.ellipsis,
                      )),
                  const Text(
                    'Status: Buka',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Store Status Toggle
          Switch(
            value: true,
            onChanged: (value) {
              // TODO: Implement store status toggle
            },
            activeColor: Colors.white,
          ),
          const SizedBox(width: 8),

          // Profile Button
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            onSelected: (String result) {
              switch (result) {
                case 'profile':
                  Get.toNamed(Routes.PROFILE);
                  break;
                case 'settings':
                  Get.toNamed(Routes.STORE_SETTINGS);
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profil Toko'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Penjualan Hari Ini',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.trending_up,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rp 450.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '15 Pesanan • Rating 4.7 ⭐',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  'Pesanan Baru',
                  '3',
                  Icons.shopping_cart,
                  AppColors.warning,
                  onTap: () => Get.toNamed(Routes.STORE_ORDERS),
                ),
                _buildStatCard(
                  'Siap Diantar',
                  '2',
                  Icons.check_circle,
                  AppColors.success,
                  onTap: () => Get.toNamed(Routes.STORE_ORDERS),
                ),
                _buildStatCard(
                  'Menu Aktif',
                  '24',
                  Icons.restaurant_menu,
                  Colors.purple,
                  onTap: () => Get.toNamed(Routes.MENU_MANAGEMENT),
                ),
                _buildStatCard(
                  'Stok Habis',
                  '1',
                  Icons.warning,
                  AppColors.error,
                  onTap: () => Get.toNamed(Routes.MENU_MANAGEMENT),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan Terbaru',
                  style: AppTextStyles.h5,
                ),
                TextButton(
                  onPressed: () => Get.toNamed(Routes.STORE_ORDERS),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Orders List
            _buildOrderCard(
              orderId: '#DL003',
              customerName: 'Maya Sari',
              items: '2x Nasi Gudeg, 1x Es Teh',
              total: '35.000',
              time: '10:45',
              status: 'Baru',
              statusColor: AppColors.warning,
              actionText: 'Terima',
              onTap: () => Get.toNamed(Routes.STORE_ORDER_DETAIL,
                  arguments: {'orderId': 'DL003'}),
            ),

            const SizedBox(height: 12),

            _buildOrderCard(
              orderId: '#DL004',
              customerName: 'Budi Santoso',
              items: '1x Ayam Bakar, 1x Nasi Putih',
              total: '28.000',
              time: '10:30',
              status: 'Diproses',
              statusColor: AppColors.info,
              actionText: 'Siap',
              onTap: () => Get.toNamed(Routes.STORE_ORDER_DETAIL,
                  arguments: {'orderId': 'DL004'}),
            ),

            const SizedBox(height: 12),

            _buildOrderCard(
              orderId: '#DL005',
              customerName: 'Lisa Permata',
              items: '3x Bakso Urat, 2x Es Jeruk',
              total: '42.000',
              time: '10:15',
              status: 'Siap',
              statusColor: AppColors.success,
              actionText: 'Selesai',
              onTap: () => Get.toNamed(Routes.STORE_ORDER_DETAIL,
                  arguments: {'orderId': 'DL005'}),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(Routes.ADD_MENU_ITEM),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(Routes.STORE_ANALYTICS),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Laporan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (title == 'Stok Habis' && value != '0')
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h3,
            ),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String customerName,
    required String items,
    required String total,
    required String time,
    required String status,
    required Color statusColor,
    required String actionText,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderId, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(customerName, style: AppTextStyles.bodyMedium),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              items,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rp $total',
                  style: AppTextStyles.price,
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement order action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey[600],
      currentIndex: 0, // Dashboard is selected
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Get.toNamed(Routes.STORE_ORDERS);
            break;
          case 2:
            Get.toNamed(Routes.MENU_MANAGEMENT);
            break;
          case 3:
            Get.toNamed(Routes.STORE_ANALYTICS);
            break;
          case 4:
            Get.toNamed(Routes.STORE_SETTINGS);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Pesanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analitik',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout Confirmation!'),
        content: const Text('Are you sure you want to logout?!'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
