import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/store_detail_controller.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/features/customer/widgets/menu_item_card.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';

class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StoreDetailController controller = Get.find<StoreDetailController>();
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget();
        }

        if (controller.hasError) {
          return app_error.ErrorWidget(
            message: controller.errorMessage,
            onRetry: controller.refreshStore,
          );
        }

        final store = controller.store;
        if (store == null) {
          return const EmptyStateWidget(
            message: 'Store not found',
            icon: Icons.store_mall_directory_outlined,
          );
        }

        return CustomScrollView(
          slivers: [
            // Store Header
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Store Image
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        image: store.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(store.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: store.imageUrl == null
                          ? const Icon(
                              Icons.store,
                              size: 80,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    // Gradient overlay
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
                    // Store info overlay
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: AppTextStyles.h4.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (store.rating != null) ...[
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  store.displayRating,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                              if (store.distance != null) ...[
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  store.displayDistance,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Store Info
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: store.isOpen
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        store.isOpen ? 'Open' : 'Closed',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: store.isOpen
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),

                    if (store.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        store.description!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],

                    if (store.openTime != null && store.closeTime != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Open ${store.openTime} - ${store.closeTime}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Menu Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Menu',
                      style: AppTextStyles.h5,
                    ),
                    const Spacer(),
                    if (controller.isLoadingMenu)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),

            // Menu Items
            if (controller.isLoadingMenu)
              const SliverToBoxAdapter(
                child: LoadingWidget(),
              )
            else if (!controller.hasMenuItems)
              const SliverToBoxAdapter(
                child: EmptyStateWidget(
                  message: 'No menu items available',
                  icon: Icons.restaurant_menu,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final menuItem = controller.menuItems[index];
                    return MenuItemCard(
                      menuItem: menuItem,
                      onTap: () => controller.showAddToCartDialog(menuItem),
                      onAddToCart: () => controller.addToCart(menuItem),
                    );
                  },
                  childCount: controller.menuItems.length,
                ),
              ),
          ],
        );
      }),

      // Floating Cart Button
      floatingActionButton: Obx(() {
        final cartItemCount = cartController.itemCount;
        if (cartItemCount == 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/customer/cart'),
          icon: const Icon(Icons.shopping_cart),
          label: Text('Cart ($cartItemCount)'),
          backgroundColor: AppColors.primary,
        );
      }),
    );
  }
}
