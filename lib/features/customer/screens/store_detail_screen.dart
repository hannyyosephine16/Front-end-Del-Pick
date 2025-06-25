// lib/features/customer/views/store_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/store_detail_controller.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/features/customer/widgets/menu_item_card.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
import 'package:del_pick/core/widgets/network_image_widget.dart';
import 'package:del_pick/core/widgets/status_badge.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

import '../../shared/widgets/netwrok_image_widget.dart';

class StoreDetailView extends StatelessWidget {
  const StoreDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreDetailController>(
      init: StoreDetailController(
        storeRepository: Get.find(),
        menuRepository: Get.find(),
        cartController: Get.find<CartController>(),
      ),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          if (controller.isLoading) {
            return const LoadingWidget(message: 'Loading store details...');
          }

          if (controller.hasError) {
            return app_error.ErrorWidget(
              message: controller.errorMessage,
              onRetry: controller.retryLoadStore,
            );
          }

          if (controller.store == null) {
            return const EmptyStateWidget(
              message: 'Store not found',
              icon: Icons.store_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshStore,
            child: CustomScrollView(
              slivers: [
                // Store Header with Image
                _buildStoreHeader(controller),

                // Store Info Card
                _buildStoreInfo(controller),

                // Menu Section Header
                _buildMenuSectionHeader(controller),

                // Menu Items
                _buildMenuItems(controller),

                // Bottom padding for FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        }),
        floatingActionButton: _buildCartFAB(),
      ),
    );
  }

  Widget _buildStoreHeader(StoreDetailController controller) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWidget(
              imageUrl: controller.store!.imageUrl,
              fit: BoxFit.cover,
              placeholder: Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.store,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.store!.name,
                    style: AppTextStyles.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.store!.description != null &&
                      controller.store!.description!.isNotEmpty)
                    Text(
                      controller.store!.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo(StoreDetailController controller) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surface,
        margin: const EdgeInsets.all(AppDimensions.paddingMD),
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Status & Rating Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSM,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: controller.store!.isOpen
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Text(
                    controller.store!.isOpen ? 'Open' : 'Closed',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: controller.store!.isOpen
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMD),
                if (controller.store!.rating != null) ...[
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: AppDimensions.iconSM,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    controller.store!.rating!.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (controller.store!.reviewCount != null &&
                      controller.store!.reviewCount! > 0)
                    Text(
                      ' (${controller.store!.reviewCount})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
                const Spacer(),
                if (controller.store!.distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSM,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: Text(
                      '${controller.store!.distance!.toStringAsFixed(1)} km',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingMD),

            // Store Details
            if (controller.store!.openTime != null &&
                controller.store!.closeTime != null)
              _buildStoreDetailRow(
                Icons.access_time,
                '${controller.store!.openTime} - ${controller.store!.closeTime}',
              ),

            if (controller.store!.phone != null)
              _buildStoreDetailRow(
                Icons.phone,
                controller.store!.phone!,
              ),

            if (controller.store!.address != null)
              _buildStoreDetailRow(
                Icons.location_on,
                controller.store!.address!,
                isMultiline: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreDetailRow(IconData icon, String text,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingSM),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSM,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spacingSM),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
              maxLines: isMultiline ? null : 1,
              overflow: isMultiline ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSectionHeader(StoreDetailController controller) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menu',
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() {
              if (controller.hasMenuItems) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSM,
                    vertical: AppDimensions.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Text(
                    '${controller.menuItems.length} items',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(StoreDetailController controller) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoadingMenu) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingLG),
            child: LoadingWidget(message: 'Loading menu...'),
          );
        }

        if (!controller.hasMenuItems) {
          return const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingLG),
            child: EmptyStateWidget(
              message: 'No menu items available',
              icon: Icons.restaurant_menu_outlined,
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
          ),
          itemCount: controller.menuItems.length,
          separatorBuilder: (context, index) => const SizedBox(
            height: AppDimensions.spacingMD,
          ),
          itemBuilder: (context, index) {
            final menuItem = controller.menuItems[index];
            return MenuItemCard(
              menuItem: menuItem,
              onTap: () => controller.showAddToCartDialog(menuItem),
              onAddToCart: () => controller.addToCart(menuItem),
            );
          },
        );
      }),
    );
  }

  Widget _buildCartFAB() {
    return Obx(() {
      final cartController = Get.find<CartController>();

      // Show cart FAB only if there are items in cart
      if (cartController.isNotEmpty) {
        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/cart'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          icon: const Icon(Icons.shopping_cart),
          label: Text(
            '${cartController.itemCount} items • ${cartController.formattedSubtotal}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
