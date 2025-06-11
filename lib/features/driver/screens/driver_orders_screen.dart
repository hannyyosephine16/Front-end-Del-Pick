// lib/features/driver/screens/driver_orders_screen.dart
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
    // final controller = Get.find<DriverOrdersController>();
    final controller =
        Get.put(DriverOrdersController(Get.find<OrderRepository>()));
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
                '${controller.totalOrders} total pesanan',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textOnPrimary.withOpacity(0.8),
                ),
              )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textOnPrimary),
          onPressed: () => controller.refreshOrders(),
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
        activeOrders: stats['active'],
        completedOrders: stats['completed'],
        todayDeliveries: stats['todayDeliveries'],
        todayEarnings: controller.formatCurrency(stats['todayEarnings']),
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
            itemCount: controller.filterOptions.length,
            itemBuilder: (context, index) {
              final filter = controller.filterOptions[index];
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
        onRefresh: controller.refreshOrders,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                controller.hasMoreData &&
                !controller.isLoading) {
              controller.loadMoreOrders();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            itemCount:
                controller.orders.length + (controller.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.orders.length) {
                return _buildLoadMoreIndicator();
              }

              final order = controller.orders[index];
              return DriverOrderCard(
                order: order,
                onTap: () => controller.goToOrderDetail(order),
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
            onPressed: controller.refreshOrders,
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
        controller.goToNavigation(order);
        break;
      case 'track':
        controller.goToOrderTracking(order);
        break;
      case 'contact':
        _showContactOptions(order);
        break;
    }
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: AppColors.info),
              title: const Text('Chat'),
              onTap: () {
                Get.back();
                // Implement chat
              },
            ),
          ],
        ),
      ),
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
            ...controller.filterOptions.map((filter) {
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
}
