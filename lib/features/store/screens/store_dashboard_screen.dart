import 'package:del_pick/data/models/order/order_model_extensions.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/features/store/controllers/store_dashboard_controller.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart';

class StoreDashboardScreen extends StatelessWidget {
  const StoreDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Get both controllers
    final AuthController authController = Get.find<AuthController>();
    final StoreDashboardController dashboardController =
        Get.find<StoreDashboardController>();

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
                  dashboardController.navigateToStoreProfile();
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
      body: Obx(() {
        // ✅ Show loading state
        if (dashboardController.isLoading &&
            dashboardController.orders.isEmpty) {
          return const Center(child: LoadingWidget());
        }

        // ✅ Show error state
        if (dashboardController.hasError &&
            dashboardController.orders.isEmpty) {
          return Center(
            child: ErrorWidget(
              message: dashboardController.errorMessage,
              onRetry: () => dashboardController.refreshData(),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => dashboardController.refreshData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Today's Summary Card - Using real data from controller
                _buildTodaySummaryCard(dashboardController),

                const SizedBox(height: 24),

                // ✅ Quick Stats Grid - Using real data from controller
                _buildQuickStatsGrid(dashboardController),

                const SizedBox(height: 24),

                // ✅ Recent Orders Section - Using real data from controller
                _buildRecentOrdersSection(dashboardController),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(dashboardController),

                const SizedBox(
                    height: 100), // Extra space for bottom navigation
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavigationBar(dashboardController),
    );
  }

  // ✅ Today's Summary Card with real data
  Widget _buildTodaySummaryCard(StoreDashboardController controller) {
    final stats = controller.getDashboardStatistics();

    return Container(
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
          Text(
            'Rp ${stats['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${stats['todayOrders'] ?? 0} Pesanan Hari Ini • ${stats['completedOrders'] ?? 0} Selesai',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Quick Stats Grid with real data
  Widget _buildQuickStatsGrid(StoreDashboardController controller) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Pesanan Baru',
          '${controller.pendingOrderCount}',
          Icons.shopping_cart,
          AppColors.warning,
          onTap: () => controller.navigateToOrderDetail(
              0), // Navigate to orders with pending filter
        ),
        _buildStatCard(
          'Siap Diantar',
          '${controller.readyForPickupCount}',
          Icons.check_circle,
          AppColors.success,
          onTap: () => controller
              .navigateToOrderDetail(0), // Navigate to orders with ready filter
        ),
        _buildStatCard(
          'Sedang Diproses',
          '${controller.preparingOrderCount}',
          Icons.restaurant_menu,
          Colors.purple,
          onTap: () => controller.navigateToMenuManagement(),
        ),
        _buildStatCard(
          'Total Pesanan',
          '${controller.orders.length}',
          Icons.analytics,
          AppColors.info,
          onTap: () => controller.navigateToStoreAnalytics(),
        ),
      ],
    );
  }

  // ✅ Recent Orders Section with real data
  Widget _buildRecentOrdersSection(StoreDashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pesanan Terbaru',
              style: AppTextStyles.h5,
            ),
            TextButton(
              onPressed: () => controller.navigateToOrderDetail(0),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ✅ Show recent orders from controller
        if (controller.orders.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pesanan',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else
          // Show latest 3 orders
          ...controller.orders.take(3).map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderCard(
                  order: order,
                  controller: controller,
                ),
              )),
      ],
    );
  }

  // ✅ Order Card with real order data
  Widget _buildOrderCard({
    required OrderModel order,
    required StoreDashboardController controller,
  }) {
    // Determine status color and action text based on order status
    Color statusColor;
    String actionText;
    VoidCallback? onActionPressed;

    switch (order.orderStatus) {
      case 'pending':
        statusColor = AppColors.warning;
        actionText = 'Terima';
        onActionPressed = () => controller.approveOrder(order);
        break;
      case 'preparing':
        statusColor = AppColors.info;
        actionText = 'Siap';
        onActionPressed = () => controller.markOrderReadyForPickup(order);
        break;
      case 'ready_for_pickup':
        statusColor = AppColors.success;
        actionText = 'Menunggu Driver';
        onActionPressed = null;
        break;
      case 'on_delivery':
        statusColor = Colors.blue;
        actionText = 'Diantar';
        onActionPressed = null;
        break;
      case 'delivered':
        statusColor = AppColors.success;
        actionText = 'Selesai';
        onActionPressed = null;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        actionText = 'Dibatalkan';
        onActionPressed = null;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        actionText = 'Ditolak';
        onActionPressed = null;
        break;
      default:
        statusColor = Colors.grey;
        actionText = 'Unknown';
        onActionPressed = null;
    }

    return GestureDetector(
      onTap: () => controller.navigateToOrderDetail(order.id),
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
                    Text(order.code, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      order.customer?.name ?? 'Customer',
                      style: AppTextStyles.bodyMedium,
                    ),
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
                        order.statusDisplayName,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.formattedTime,
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
              order.itemsSummary,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.formattedTotal,
                  style: AppTextStyles.price,
                ),
                if (onActionPressed != null)
                  Obx(() => ElevatedButton(
                        onPressed: controller.isProcessingOrder
                            ? null
                            : onActionPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: controller.isProcessingOrder
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                actionText,
                                style: const TextStyle(fontSize: 12),
                              ),
                      ))
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Quick Actions with controller navigation
  Widget _buildQuickActions(StoreDashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.navigateToMenuManagement(),
            icon: const Icon(Icons.add),
            label: const Text('Kelola Menu'),
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
            onPressed: () => controller.navigateToStoreAnalytics(),
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
                if (title == 'Pesanan Baru' && value != '0')
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
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

  Widget _buildBottomNavigationBar(StoreDashboardController controller) {
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
            controller.navigateToOrderDetail(0);
            break;
          case 2:
            controller.navigateToMenuManagement();
            break;
          case 3:
            controller.navigateToStoreAnalytics();
            break;
          case 4:
            controller.navigateToStoreProfile();
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
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
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
