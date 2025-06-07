import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:del_pick/features/customer/controllers/store_detail_controller.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/features/customer/widgets/menu_item_card.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreDetailController>(
      init: StoreDetailController(),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
// App Bar with Store Image
              _buildSliverAppBar(controller),
              // Store Info
              SliverToBoxAdapter(
                child: _buildStoreInfo(controller),
              ),

              // Category Tabs
              SliverToBoxAdapter(
                child: _buildCategoryTabs(controller),
              ),

              // Menu Items
              _buildMenuItemsList(controller),
            ],
          ),
        ),
        // Floating Cart Button
        floatingActionButton: _buildCartButton(),
      ),
    );
  }

  Widget _buildSliverAppBar(StoreDetailController controller) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: controller.store?.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: controller.store!.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.store,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : Container(
                color: AppColors.surface,
                child: const Icon(
                  Icons.store,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
// Implement share functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
// Implement favorite functionality
          },
        ),
      ],
    );
  }

  Widget _buildStoreInfo(StoreDetailController controller) {
    if (controller.store == null) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Name',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              'Loading store information...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    final store = controller.store!;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: AppTextStyles.h4,
                ),
              ),
              _buildStoreStatusBadge(store),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingSM),

          // Description
          if (store.description != null) ...[
            Text(
              store.description!,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMD),
          ],

          // Store stats
          Row(
            children: [
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSM,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.rating.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.rating,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      store.displayRating,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${store.reviewCount ?? 0})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.spacingMD),

              // Distance
              if (store.distance != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSM,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        store.displayDistance,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMD),

          // Store hours and contact
          Row(
            children: [
              // Hours
              if (store.openTime != null && store.closeTime != null)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${store.openTime} - ${store.closeTime}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),

              // Phone
              if (store.phone != null)
                GestureDetector(
                  onTap: () {
                    // Implement call functionality
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingSM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStatusBadge(store) {
    final isOpen = store.isOpenNow();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: AppTextStyles.labelSmall.copyWith(
          color: isOpen ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(StoreDetailController controller) {
    return Obx(() => Container(
          height: 50,
          color: AppColors.surface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final isSelected = category == controller.selectedCategory;
              return Container(
                margin: const EdgeInsets.only(right: AppDimensions.spacingSM),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.selectCategory(category);
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
              );
            },
          ),
        ));
  }

  Widget _buildMenuItemsList(StoreDetailController controller) {
    return Obx(() {
      if (controller.isLoading || controller.isLoadingMenu) {
        return const SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: LoadingWidget(),
          ),
        );
      }
      if (controller.hasError) {
        return SliverToBoxAdapter(
          child: app_error.ErrorWidget(
            message: controller.errorMessage,
            onRetry: controller.refreshData,
          ),
        );
      }

      if (!controller.hasMenuItems) {
        return const SliverToBoxAdapter(
          child: EmptyStateWidget(
            message: 'No menu items available',
            icon: Icons.restaurant_menu,
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final menuItem = controller.filteredMenuItems[index];
              return MenuItemCard(
                menuItem: menuItem,
                onTap: () => controller.navigateToMenuItemDetail(menuItem),
                onAddToCart: () => controller.addToCart(menuItem),
              );
            },
            childCount: controller.filteredMenuItems.length,
          ),
        ),
      );
    });
  }

  Widget _buildCartButton() {
    return GetBuilder<CartController>(
      builder: (cartController) => cartController.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: cartController.proceedToCheckout,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              icon: const Icon(Icons.shopping_cart),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${cartController.itemCount} items',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 16,
                    color: AppColors.textOnPrimary.withOpacity(0.3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cartController.formattedTotal,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
