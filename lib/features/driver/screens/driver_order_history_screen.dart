// lib/features/driver/screens/driver_order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/driver/controllers/driver_orders_controller.dart';
import 'package:del_pick/features/driver/widgets/driver_order_card.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/tracking_repository.dart';

class DriverOrderHistoryScreen extends StatelessWidget {
  const DriverOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      DriverOrdersController(
        orderRepository: Get.find<OrderRepository>(),
        trackingRepository: Get.find<TrackingRepository>(),
      ),
      tag: 'history', // Tag berbeda untuk history
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          // Filter untuk History
          _buildHistoryFilterSection(controller),

          // Summary Stats
          _buildHistorySummary(controller),

          // History List
          Expanded(
            child: _buildHistoryList(controller),
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
            'Riwayat Pesanan',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Obx(() => Text(
                '${controller.completedOrders.length} pesanan selesai',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textOnPrimary.withOpacity(0.8),
                ),
              )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textOnPrimary),
          onPressed: () => controller.refreshData(),
        ),
        IconButton(
          icon:
              const Icon(Icons.calendar_today, color: AppColors.textOnPrimary),
          onPressed: () => _showDateRangePicker(controller),
        ),
      ],
    );
  }

  Widget _buildHistoryFilterSection(DriverOrdersController controller) {
    const historyFilters = [
      {'key': 'all', 'label': 'Semua', 'icon': Icons.list_alt},
      {'key': 'delivered', 'label': 'Terkirim', 'icon': Icons.check_circle},
      {'key': 'cancelled', 'label': 'Dibatalkan', 'icon': Icons.cancel},
      {'key': 'today', 'label': 'Hari Ini', 'icon': Icons.today},
      {'key': 'week', 'label': 'Minggu Ini', 'icon': Icons.date_range},
      {'key': 'month', 'label': 'Bulan Ini', 'icon': Icons.calendar_month},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSM),
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
            ),
            itemCount: historyFilters.length,
            itemBuilder: (context, index) {
              final filter = historyFilters[index];
              final isSelected = controller.selectedFilter == filter['key'];

              return Container(
                margin: const EdgeInsets.only(right: AppDimensions.spacingSM),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        filter['label']! as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) =>
                      controller.changeFilter(filter['key']! as String),
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

  Widget _buildHistorySummary(DriverOrdersController controller) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final stats = controller.getOrderStatistics();
        final totalEarnings = controller.totalEarnings;
        final todayCount = controller.todayDeliveryCount;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.delivery_dining,
                    title: 'Total Pesanan',
                    value: '${stats['completedOrders']}',
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.today,
                    title: 'Hari Ini',
                    value: '$todayCount',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.monetization_on,
                    title: 'Total Pendapatan',
                    value: _formatCurrency(totalEarnings),
                    color: AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.star,
                    title: 'Rating',
                    value: '4.8', // You can get this from driver profile
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSM),
        Text(
          value,
          style: AppTextStyles.h6.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryList(DriverOrdersController controller) {
    return Obx(() {
      if (controller.isLoading && controller.orders.isEmpty) {
        return _buildLoadingState();
      }

      // Filter orders for history (completed, cancelled)
      final historyOrders = controller.orders
          .where((order) =>
              order.orderStatus == OrderStatusConstants.delivered ||
              order.orderStatus == OrderStatusConstants.cancelled)
          .toList();

      if (historyOrders.isEmpty) {
        return _buildEmptyHistoryState(controller);
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingSM,
          ),
          itemCount: historyOrders.length,
          itemBuilder: (context, index) {
            final order = historyOrders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
              child: DriverOrderHistoryCard(
                order: order,
                onTap: () => controller.navigateToOrderDetail(order.id),
                onReorder: () => _handleReorder(order),
              ),
            );
          },
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
          Text('Memuat riwayat pesanan...'),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState(DriverOrdersController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          Text(
            'Belum Ada Riwayat',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            'Riwayat pesanan akan muncul di sini\nsetelah Anda menyelesaikan pengiriman',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          ElevatedButton.icon(
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

  void _showDateRangePicker(DriverOrdersController controller) {
    showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    ).then((dateRange) {
      if (dateRange != null) {
        // Filter orders by date range
        _filterByDateRange(controller, dateRange);
      }
    });
  }

  void _filterByDateRange(
      DriverOrdersController controller, DateTimeRange dateRange) {
    // You can implement date range filtering here
    Get.snackbar(
      'Filter Tanggal',
      'Menampilkan pesanan dari ${_formatDate(dateRange.start)} sampai ${_formatDate(dateRange.end)}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        )}';
  }

  void _handleReorder(order) {
    Get.snackbar(
      'Pesan Ulang',
      'Fitur pesan ulang akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

// Widget terpisah untuk card history
class DriverOrderHistoryCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;
  final VoidCallback onReorder;

  const DriverOrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.code ?? 'Order #${order.id}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMD),

              // Order details
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.store?.name ?? 'Unknown Store',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'IT Del', // Static destination
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMD),

              // Earnings and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pendapatan',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatCurrency(order.deliveryFee ?? 0),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Detail'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      if (order.orderStatus == OrderStatusConstants.delivered)
                        TextButton.icon(
                          onPressed: onReorder,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Ulang'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.orderStatus) {
      case OrderStatusConstants.delivered:
        statusColor = AppColors.success;
        statusText = 'Terkirim';
        statusIcon = Icons.check_circle;
        break;
      case OrderStatusConstants.cancelled:
        statusColor = AppColors.error;
        statusText = 'Dibatalkan';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Selesai';
        statusIcon = Icons.check;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: AppTextStyles.bodySmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        )}';
  }
}
