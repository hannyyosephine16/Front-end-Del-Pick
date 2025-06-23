// lib/features/customer/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/order/order_model_extensions.dart';
import 'package:del_pick/features/customer/controllers/order_history_controller.dart';
import 'package:del_pick/features/customer/widgets/order_history_card.dart';
import 'package:del_pick/features/customer/widgets/order_filter_tabs.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderHistoryController>(
      init: OrderHistoryController(orderRepository: Get.find()),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Order History'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.refreshOrders,
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading && controller.orders.isEmpty) {
            return const LoadingWidget(message: 'Loading your orders...');
          }

          if (controller.hasError && controller.orders.isEmpty) {
            return app_error.ErrorWidget(
              message: controller.errorMessage,
              onRetry: controller.refreshOrders,
            );
          }

          return Column(
            children: [
              // Statistics Card (if has orders)
              if (controller.hasOrders) ...[
                OrderStatisticsCard(
                  statistics: controller.getOrderStatistics(),
                ),
                const SizedBox(height: AppDimensions.spacingSM),
              ],

              // Filter Tabs
              OrderFilterTabs(
                selectedFilter: controller.selectedFilter,
                filterOptions: OrderHistoryController.filterOptions,
                onFilterChanged: controller.changeFilter,
                orderCounts: {
                  'all': controller.orders.length,
                  'active': controller.getOrderCountByStatus('active'),
                  'completed': controller.getOrderCountByStatus('completed'),
                  'cancelled': controller.getOrderCountByStatus('cancelled'),
                },
              ),

              const SizedBox(height: AppDimensions.spacingSM),

              // Orders List
              Expanded(
                child: _buildOrdersList(controller),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrdersList(OrderHistoryController controller) {
    if (!controller.hasOrders) {
      return RefreshIndicator(
        onRefresh: controller.refreshOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: Get.height * 0.6,
            child: EmptyStateWidget(
              message: _getEmptyMessage(controller.selectedFilter),
              icon: Icons.receipt_long_outlined,
              onRetry: controller.refreshOrders,
              retryText: 'Refresh',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshOrders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
        ),
        itemCount: controller.orders.length + (controller.canLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Load more indicator
          if (index == controller.orders.length) {
            if (controller.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(AppDimensions.paddingLG),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (controller.canLoadMore) {
              return Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Center(
                  child: ElevatedButton(
                    onPressed: controller.loadMoreOrders,
                    child: const Text('Load More'),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final order = controller.orders[index];
          return Container(
            margin: const EdgeInsets.only(
              bottom: AppDimensions.spacingMD,
            ),
            child: OrderHistoryCard(
              order: order,
              onTap: () => controller.navigateToOrderDetail(order.id),
              onTrack: order.canTrack
                  ? () => controller.navigateToOrderTracking(order.id)
                  : null,
              onReview: order.canReview
                  ? () => controller.navigateToReview(order.id)
                  : null,
              onCancel: order.canCancel
                  ? () => controller.cancelOrder(
                      order) // Fixed: pass OrderModel instead of int
                  : null,
              onReorder: () => controller.reorderItems(order),
            ),
          );
        },
      ),
    );
  }

  String _getEmptyMessage(String filter) {
    switch (filter) {
      case 'active':
        return 'No active orders found.\nPlace your first order!';
      case 'completed':
        return 'No completed orders yet.\nYour delivered orders will appear here.';
      case 'cancelled':
        return 'No cancelled orders found.';
      default:
        return 'No orders found.\nStart by ordering from your favorite restaurant!';
    }
  }
}

// Order Statistics Card Widget
class OrderStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const OrderStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLG,
        vertical: AppDimensions.paddingSM,
      ),
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
          Text('Your Order Summary', style: AppTextStyles.h6),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Orders',
                  statistics['totalOrders'].toString(),
                  Icons.receipt_long_outlined,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Active',
                  statistics['activeOrders'].toString(),
                  Icons.schedule,
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  statistics['completedOrders'].toString(),
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Spent',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rp ${(statistics['totalSpent'] as double).toStringAsFixed(0)}',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppDimensions.spacingSM),
        Text(
          value,
          style: AppTextStyles.h5.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
