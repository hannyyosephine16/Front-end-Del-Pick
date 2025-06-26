// lib/features/driver/screens/driver_orders_screen.dart - FIXED
import 'package:del_pick/data/repositories/tracking_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/driver/controllers/driver_orders_controller.dart';
import 'package:del_pick/features/driver/widgets/driver_order_card.dart';
import 'package:del_pick/features/driver/widgets/order_statistics_card.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import '../../../data/repositories/order_repository.dart';

class DriverOrdersScreen extends StatelessWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Use proper constructor with named parameter
    final controller = Get.put(
      DriverOrdersController(
        orderRepository: Get.find<OrderRepository>(),
        trackingRepository: Get.find<TrackingRepository>(),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          // Statistics Card
          _buildStatisticsSection(controller),

          // Filter Chips
          _buildFilterSection(controller),

          // Orders List
          Expanded(
            child: _buildOrdersList(controller),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DriverOrdersController controller) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesanan Saya',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Obx(() => Text(
                // ✅ FIXED: Use orders.length instead of totalOrders
                '${controller.orders.length} total pesanan',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textOnPrimary.withOpacity(0.8),
                ),
              )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textOnPrimary),
          // ✅ FIXED: Use refreshData instead of refreshOrders
          onPressed: () => controller.refreshData(),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: AppColors.textOnPrimary),
          onPressed: () => _showFilterBottomSheet(controller),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(DriverOrdersController controller) {
    return Obx(() {
      final stats = controller.getOrderStatistics();
      return OrderStatisticsCard(
        activeOrders: stats['activeOrders'] ?? 0,
        completedOrders: stats['completedOrders'] ?? 0,
        // ✅ FIXED: Add today deliveries calculation or default
        todayDeliveries:
            stats['completedOrders'] ?? 0, // You can modify this logic
        // ✅ FIXED: Add formatCurrency method or use simple formatting
        todayEarnings:
            _formatCurrency(0.0), // You can calculate today's earnings
      );
    });
  }

  Widget _buildFilterSection(DriverOrdersController controller) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSM),
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
            ),
            // ✅ FIXED: Access static member properly
            itemCount: DriverOrdersController.filterOptions.length,
            itemBuilder: (context, index) {
              // ✅ FIXED: Access static member properly
              final filter = DriverOrdersController.filterOptions[index];
              final isSelected = controller.selectedFilter == filter['key'];

              return Container(
                margin: const EdgeInsets.only(right: AppDimensions.spacingSM),
                child: FilterChip(
                  label: Text(
                    filter['label']!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => controller.changeFilter(filter['key']!),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  elevation: isSelected ? 4 : 0,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
              );
            },
          )),
    );
  }

  Widget _buildOrdersList(DriverOrdersController controller) {
    return Obx(() {
      if (controller.isLoading && controller.orders.isEmpty) {
        return _buildLoadingState();
      }

      if (controller.orders.isEmpty) {
        return _buildEmptyState(controller);
      }

      return RefreshIndicator(
        // ✅ FIXED: Use refreshData instead of refreshOrders
        onRefresh: controller.refreshData,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                // ✅ FIXED: Use canLoadMore instead of hasMoreData
                controller.canLoadMore &&
                !controller.isLoading) {
              controller.loadMoreOrders();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            itemCount: controller.orders.length +
                // ✅ FIXED: Use canLoadMore instead of hasMoreData
                (controller.canLoadMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.orders.length) {
                return _buildLoadMoreIndicator();
              }

              final order = controller.orders[index];
              return DriverOrderCard(
                order: order,
                // ✅ FIXED: Use navigateToOrderDetail instead of goToOrderDetail
                onTap: () => controller.navigateToOrderDetail(order.id),
                onActionPressed: (action) => _handleOrderAction(
                  controller,
                  order,
                  action,
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppDimensions.spacingLG),
          Text('Memuat pesanan...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DriverOrdersController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          Text(
            'Tidak ada pesanan',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            controller.selectedFilter == 'all'
                ? 'Belum ada pesanan yang masuk'
                : 'Tidak ada pesanan dengan status ini',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          ElevatedButton.icon(
            // ✅ FIXED: Use refreshData instead of refreshOrders
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  void _handleOrderAction(
    DriverOrdersController controller,
    order,
    String action,
  ) {
    switch (action) {
      case 'start_delivery':
        _showConfirmationDialog(
          title: 'Mulai Pengiriman',
          message: 'Apakah Anda yakin ingin memulai pengiriman?',
          onConfirm: () => controller.startDelivery(order.id),
        );
        break;
      case 'complete_delivery':
        _showConfirmationDialog(
          title: 'Selesaikan Pengiriman',
          message: 'Apakah Anda yakin pesanan sudah terkirim?',
          onConfirm: () => controller.completeDelivery(order.id),
        );
        break;
      case 'navigate':
        // ✅ FIXED: Use simple navigation since goToNavigation doesn't exist
        _handleNavigation(order);
        break;
      case 'track':
        // ✅ FIXED: Use navigateToOrderTracking instead of goToOrderTracking
        controller.navigateToOrderTracking(order.id);
        break;
      case 'contact':
        _showContactOptions(order);
        break;
    }
  }

  // ✅ ADDED: Helper method for navigation
  void _handleNavigation(order) {
    // You can implement navigation to maps here
    Get.snackbar(
      'Navigation',
      'Navigasi ke lokasi customer',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(order) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hubungi Customer',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.success),
              title: const Text('Telepon'),
              onTap: () {
                Get.back();
                // Implement phone call
                _handlePhoneCall(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: AppColors.info),
              title: const Text('Chat'),
              onTap: () {
                Get.back();
                // Implement chat
                _handleChat(order);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ADDED: Helper methods for contact
  void _handlePhoneCall(order) {
    Get.snackbar(
      'Phone Call',
      'Memanggil customer...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleChat(order) {
    Get.snackbar(
      'Chat',
      'Membuka chat dengan customer...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showFilterBottomSheet(DriverOrdersController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Pesanan',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            // ✅ FIXED: Access static member properly
            ...DriverOrdersController.filterOptions.map((filter) {
              return Obx(() {
                final isSelected = controller.selectedFilter == filter['key'];
                return ListTile(
                  title: Text(filter['label']!),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    controller.changeFilter(filter['key']!);
                    Get.back();
                  },
                );
              });
            }),
          ],
        ),
      ),
    );
  }

  // ✅ ADDED: Helper method for currency formatting since it's missing from controller
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        )}';
  }
}
