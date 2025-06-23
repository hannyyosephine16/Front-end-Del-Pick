import 'package:flutter/material.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/data/models/order/order_model_extensions.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel menuItem;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menu Item Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: menuItem.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          menuItem.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.restaurant,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        color: AppColors.primary,
                        size: 40,
                      ),
              ),

              const SizedBox(width: 12),

              // Menu Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.name,
                      style: AppTextStyles.h6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (menuItem.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        menuItem.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          menuItem.formattedPrice,
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        // Availability Status
                        if (!menuItem.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Unavailable',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          )
                        else if (menuItem.quantity != null &&
                            menuItem.quantity! <= 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Add to Cart Button
              if (menuItem.canOrder)
                IconButton(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
