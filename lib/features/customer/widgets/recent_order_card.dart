import 'package:del_pick/data/models/order/order_model_extensions.dart';
import 'package:del_pick/features/customer/widgets/price_widget.dart';
import 'package:del_pick/features/customer/widgets/status_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/core/widgets/network_image_widget.dart';
import 'package:del_pick/core/widgets/status_badge.dart';
import 'package:del_pick/core/widgets/price_widget.dart';

import '../../shared/widgets/netwrok_image_widget.dart';

class RecentOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onTrack;

  const RecentOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID, Status, and Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.formattedDate,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    status: order.orderStatus,
                    type: StatusBadgeType.order,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Store Info with Image
              Row(
                children: [
                  // Store Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWidget(
                      imageUrl: order.store?.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        width: 48,
                        height: 48,
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.store,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Store Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.store?.name ?? 'Unknown Store',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.items?.length ?? 0} items',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  PriceWidget(
                    price: order.totalAmount,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Order Items Preview (first 2 items)
              if (order.items != null && order.items!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...order.items!.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PriceWidget(
                            price: item.price * item.quantity,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    )),
                if (order.items!.length > 2)
                  Text(
                    '... and ${order.items!.length - 2} more items',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],

              // Delivery Info (if available)
              if (order.estimatedDeliveryTime != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Est. delivery: ${order.formattedEstimatedDeliveryTime}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action Buttons
              if (_shouldShowActions) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    if (onTrack != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onTrack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              const Text('Track'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _shouldShowActions {
    // Show actions for active orders or orders that can be tracked
    return order.isActive || onTrack != null;
  }
}
