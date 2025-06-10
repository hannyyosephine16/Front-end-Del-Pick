// lib/features/customer/widgets/cart_item_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Row(
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              child: SizedBox(
                width: 60,
                height: 60,
                child: cartItem.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: cartItem.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.border,
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.border,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.border,
                        child: Image.asset(
                          AppConstants.defaultFoodImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: AppDimensions.spacingMD),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and remove button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cartItem.name,
                          style: AppTextStyles.h6,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showRemoveDialog(context),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),

                  // Notes (if any)
                  if (cartItem.notes != null && cartItem.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      'Note: ${cartItem.notes}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spacingMD),

                  // Price and quantity controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.formattedPrice,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            cartItem.formattedTotalPrice,
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      // Quantity controls
                      _buildQuantityControls(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: cartItem.quantity > 1
                ? () => onQuantityChanged(cartItem.quantity - 1)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              cartItem.quantity.toString(),
              style: AppTextStyles.h6,
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => onQuantityChanged(cartItem.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color:
              onPressed != null ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${cartItem.name} from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRemove();
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
