// lib/features/driver/screens/driver_order_history_screen.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/driver/controllers/driver_orders_controller.dart';
import 'package:del_pick/features/driver/widgets/filter_chips_widget.dart';
import 'package:del_pick/features/driver/widgets/driver_summary_stats.dart';
import 'package:del_pick/features/driver/widgets/driver_order_history_card.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import '../../../core/widgets/driver_empty_state_widget.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/tracking_repository.dart';
import '../widgets/driver_loading_history_widget.dart';

class DriverOrderHistoryScreen extends StatelessWidget {
  const DriverOrderHistoryScreen({super.key});

  // History-specific filters
  static const List<Map<String, dynamic>> historyFilters = [
    {'key': 'all', 'label': 'Semua', 'icon': Icons.list_alt},
    {'key': 'delivered', 'label': 'Terkirim', 'icon': Icons.check_circle},
    {'key': 'cancelled', 'label': 'Dibatalkan', 'icon': Icons.cancel},
    {'key': 'today', 'label': 'Hari Ini', 'icon': Icons.today},
    {'key': 'week', 'label': 'Minggu Ini', 'icon': Icons.date_range},
    {'key': 'month', 'label': 'Bulan Ini', 'icon': Icons.calendar_month},
  ];

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
          _buildFilterSection(controller),

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

  Widget _buildFilterSection(DriverOrdersController controller) {
    return Obx(() => FilterChipsWidget(
          filters: historyFilters,
          selectedFilter: controller.selectedFilter,
          onFilterSelected: controller.changeFilter,
          showIcons: true,
        ));
  }

  Widget _buildHistorySummary(DriverOrdersController controller) {
    return Obx(() {
      final stats = controller.getOrderStatistics();
      final totalEarnings = controller.totalEarnings;
      final todayCount = controller.todayDeliveryCount;

      final statItems = [
        StatItem(
          icon: Icons.delivery_dining,
          title: 'Total Pesanan',
          value: '${stats['completedOrders']}',
          color: AppColors.success,
        ),
        StatItem(
          icon: Icons.today,
          title: 'Hari Ini',
          value: '$todayCount',
          color: AppColors.info,
        ),
        StatItem(
          icon: Icons.monetization_on,
          title: 'Total Pendapatan',
          value: _formatCurrency(totalEarnings),
          color: AppColors.warning,
        ),
        StatItem(
          icon: Icons.star,
          title: 'Rating',
          value: '4.8', // You can get this from driver profile
          color: AppColors.secondary,
        ),
      ];

      return DriverSummaryStatsWidget(stats: statItems);
    });
  }

  Widget _buildHistoryList(DriverOrdersController controller) {
    return Obx(() {
      if (controller.isLoading && controller.orders.isEmpty) {
        return const DriverLoadingWidget.history();
      }

      // Filter orders for history (completed, cancelled)
      final historyOrders = controller.orders
          .where((order) =>
              order.orderStatus == OrderStatusConstants.delivered ||
              order.orderStatus == OrderStatusConstants.cancelled)
          .toList();

      if (historyOrders.isEmpty) {
        return DriverEmptyStateWidget.noHistory(
          onRefresh: controller.refreshData,
        );
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
            return DriverOrderHistoryCard(
              order: order,
              onTap: () => controller.navigateToOrderDetail(order.id),
              onReorder: () => _handleReorder(order),
              onRateOrder: () => _handleRateOrder(order),
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
            );
          },
        ),
      );
    });
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
        _filterByDateRange(controller, dateRange);
      }
    });
  }

  void _filterByDateRange(
      DriverOrdersController controller, DateTimeRange dateRange) {
    Get.snackbar(
      'Filter Tanggal',
      'Menampilkan pesanan dari ${_formatDate(dateRange.start)} sampai ${_formatDate(dateRange.end)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: AppColors.textOnPrimary,
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
      backgroundColor: AppColors.info,
      colorText: AppColors.textOnPrimary,
    );
  }

  void _handleRateOrder(order) {
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
              'Rating Pesanan',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            Text(
              'Bagaimana pengalaman pengiriman pesanan ${order.code}?',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            // Rating stars bisa ditambahkan di sini
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    // Handle rating
                    Get.back();
                    Get.snackbar(
                      'Rating Diberikan',
                      'Terima kasih atas rating Anda!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.success,
                      colorText: AppColors.textOnPrimary,
                    );
                  },
                  icon: Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMD),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Rating Disimpan',
                        'Rating berhasil disimpan',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: AppColors.textOnPrimary,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
