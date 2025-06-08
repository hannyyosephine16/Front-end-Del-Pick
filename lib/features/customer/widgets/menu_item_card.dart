// lib/features/customer/widgets/menu_item_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel menuItem;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final Widget? quantityWidget;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.onTap,
    this.onAddToCart,
    this.quantityWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menu item image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: menuItem.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: menuItem.imageUrl!,
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

              // Menu item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and availability
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            menuItem.name,
                            style: AppTextStyles.h6,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!menuItem.isAvailable || !menuItem.isInStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              !menuItem.isAvailable
                                  ? 'Unavailable'
                                  : 'Out of Stock',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacingXS),

                    // Description
                    if (menuItem.description != null &&
                        menuItem.description!.isNotEmpty)
                      Text(
                        menuItem.description!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: AppDimensions.spacingSM),

                    // Category
                    if (menuItem.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          menuItem.category!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                    const SizedBox(height: AppDimensions.spacingSM),

                    // Price and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          menuItem.formattedPrice,
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.primary,
                          ),
                        ),

                        // Quantity widget or add button
                        if (quantityWidget != null)
                          quantityWidget!
                        else if (menuItem.canOrder)
                          IconButton(
                            onPressed: onAddToCart ?? onTap,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              minimumSize: const Size(36, 36),
                            ),
                          )
                        else
                          const SizedBox(width: 36, height: 36),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
