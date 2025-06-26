// lib/features/driver/widgets/driver_order_history_card.dart
import 'package:flutter/material.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';

class DriverOrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onReorder;
  final VoidCallback? onRateOrder;
  final bool showActions;
  final EdgeInsetsGeometry? margin;

  const DriverOrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onReorder,
    this.onRateOrder,
    this.showActions = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: margin ?? EdgeInsets.zero,
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
              // Header dengan order code dan status
              _buildHeader(),

              const SizedBox(height: AppDimensions.spacingMD),

              // Order details
              _buildOrderDetails(),

              const SizedBox(height: AppDimensions.spacingMD),

              // Earnings dan delivery info
              _buildEarningsAndDelivery(),

              if (showActions) ...[
                const SizedBox(height: AppDimensions.spacingMD),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.code,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.formattedDate,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      children: [
        // Store info
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
                order.storeName,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Customer info
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                order.customer?.name ?? 'Customer',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Delivery address
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
                order.deliveryAddress,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsAndDelivery() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Earnings info
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

        // Delivery time or items count
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Items',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${order.totalItems} items',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Detail button
        Expanded(
          child: TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Detail'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        // Rate order button (untuk completed orders)
        if (order.orderStatus == OrderStatusConstants.delivered &&
            onRateOrder != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: TextButton.icon(
              onPressed: onRateOrder,
              icon: const Icon(Icons.star, size: 16),
              label: const Text('Rating'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],

        // Reorder button (untuk delivered orders)
        if (order.orderStatus == OrderStatusConstants.delivered &&
            onReorder != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: TextButton.icon(
              onPressed: onReorder,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Ulang'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ],
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
      case OrderStatusConstants.rejected:
        statusColor = AppColors.error;
        statusText = 'Ditolak';
        statusIcon = Icons.block;
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

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        )}';
  }
}
