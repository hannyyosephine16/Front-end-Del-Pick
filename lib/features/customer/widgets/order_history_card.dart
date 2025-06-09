// lib/features/customer/widgets/order_history_card.dart
import 'package:flutter/material.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onReview;
  final VoidCallback? onCancel;
  final VoidCallback? onReorder;

  const OrderHistoryCard({
    super.key,
    required this.order,
    this.onTap,
    this.onTrack,
    this.onReview,
    this.onCancel,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                children: [
                  // Order code and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.code,
                              style: AppTextStyles.h6,
                            ),
                            const SizedBox(height: AppDimensions.spacingXS),
                            Text(
                              order.storeName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingMD),

                  // Order details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            order.formattedDate,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            order.formattedTotal,
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Order items preview
                  if (order.items != null && order.items!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingMD),
                    _buildItemsPreview(),
                  ],
                ],
              ),
            ),

            // Action buttons
            if (_hasActions()) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor;
    String statusText = order.statusDisplayName;

    switch (order.orderStatus) {
      case OrderStatusConstants.pending:
        statusColor = AppColors.warning;
        break;
      case OrderStatusConstants.preparing:
        statusColor = AppColors.info;
        break;
      case OrderStatusConstants.onDelivery:
        statusColor = AppColors.secondary;
        break;
      case OrderStatusConstants.delivered:
        statusColor = AppColors.success;
        break;
      case OrderStatusConstants.cancelled:
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelMedium.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildItemsPreview() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items:',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          ...order.items!.take(3).map((item) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingXS / 2,
                ),
                child: Row(
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingXS),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.formattedPrice,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
          if (order.items!.length > 3)
            Text(
              '... and ${order.items!.length - 3} more items',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  bool _hasActions() {
    return onTrack != null ||
        onReview != null ||
        onCancel != null ||
        onReorder != null;
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSM),
        child: Row(
          children: [
            // Track button
            if (onTrack != null)
              Expanded(
                child: _buildActionButton(
                  label: 'Track',
                  icon: Icons.location_on,
                  onPressed: onTrack!,
                  isPrimary: true,
                ),
              ),

            // Review button
            if (onReview != null) ...[
              if (onTrack != null)
                const SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: _buildActionButton(
                  label: 'Review',
                  icon: Icons.star,
                  onPressed: onReview!,
                ),
              ),
            ],

            // Cancel button
            if (onCancel != null) ...[
              if (onTrack != null || onReview != null)
                const SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: _buildActionButton(
                  label: 'Cancel',
                  icon: Icons.cancel,
                  onPressed: onCancel!,
                  isDestructive: true,
                ),
              ),
            ],

            // Reorder button
            if (onReorder != null) ...[
              if (onTrack != null || onReview != null || onCancel != null)
                const SizedBox(width: AppDimensions.spacingSM),
              Expanded(
                child: _buildActionButton(
                  label: 'Reorder',
                  icon: Icons.refresh,
                  onPressed: onReorder!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    Color buttonColor;
    Color textColor;

    if (isDestructive) {
      buttonColor = AppColors.error.withOpacity(0.1);
      textColor = AppColors.error;
    } else if (isPrimary) {
      buttonColor = AppColors.primary;
      textColor = AppColors.onPrimary;
    } else {
      buttonColor = AppColors.surface;
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSM,
          horizontal: AppDimensions.paddingMD,
        ),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDestructive ? AppColors.error : AppColors.primary,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: AppDimensions.spacingXS),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
