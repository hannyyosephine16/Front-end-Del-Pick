import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/menu_controller.dart';
import 'package:del_pick/features/customer/widgets/menu_item_card.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/features/customer/widgets/custom_error_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/custom_text_field.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class MenuScreen extends GetView<MenuController> {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget();
        }

        if (controller.hasError) {
          return CustomErrorWidget(
            error: controller.errorMessage,
            onRetry: () => controller.refreshMenuItems(),
          );
        }

        return _buildMenuContent();
      }),
      floatingActionButton: _buildCartFAB(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Obx(() => Text(
            controller.currentStore?.name ?? 'Menu',
            style: AppTextStyles.h2.copyWith(color: Colors.white),
          )),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        Obx(() => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: controller.navigateToCart,
                ),
                if (controller.hasItemsInCart)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${controller.cartItemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            )),
      ],
    );
  }

  Widget _buildMenuContent() {
    return Column(
      children: [
        _buildStoreInfo(),
        _buildSearchBar(),
        _buildCategoryFilter(),
        Expanded(
          child: Obx(() {
            if (!controller.hasMenuItems) {
              return const EmptyStateWidget(
                message: 'Tidak ada menu tersedia',
                icon: Icons.restaurant_menu,
              );
            }

            return _buildMenuGrid();
          }),
        ),
      ],
    );
  }

  Widget _buildStoreInfo() {
    return Obx(() {
      final store = controller.currentStore;
      if (store == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.padding),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    store.name,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStoreRating(store),
              ],
            ),
            if (store.description != null && store.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                store.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStoreOpenHours(store),
                const SizedBox(width: 16),
                _buildStoreDistance(store),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStoreRating(store) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          store.rating?.toStringAsFixed(1) ?? '0.0',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreOpenHours(store) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          color: AppColors.textSecondary,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          '${store.openTime} - ${store.closeTime}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreDistance(store) {
    if (store.distance == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          color: AppColors.textSecondary,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          '${store.distance!.toStringAsFixed(1)} km',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: CustomTextField(
        hintText: 'Cari menu...',
        prefixIcon: Icons.search,
        onChanged: controller.searchMenuItems,
        suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clearSearch,
              )
            : null),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() {
      final categories = controller.categories;
      if (categories.length <= 1) return const SizedBox.shrink();

      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.padding,
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = controller.selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => controller.selectCategory(category),
                backgroundColor: Colors.grey[200],
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMenuGrid() {
    return RefreshIndicator(
      onRefresh: controller.refreshMenuItems,
      child: Obx(() {
        final menuItems = controller.menuItems;

        return GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.padding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: AppDimensions.spacing,
            mainAxisSpacing: AppDimensions.spacing,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final menuItem = menuItems[index];
            return MenuItemCard(
              menuItem: menuItem,
              onTap: () => controller.navigateToMenuItemDetail(menuItem),
              onAddToCart: (quantity, notes) => controller.addToCart(
                menuItem,
                quantity: quantity,
                notes: notes,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCartFAB() {
    return Obx(() {
      if (!controller.hasItemsInCart) return const SizedBox.shrink();

      return FloatingActionButton.extended(
        onPressed: controller.navigateToCart,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: Text(
          'Cart (${controller.cartItemCount})',
          style: const TextStyle(color: Colors.white),
        ),
      );
    });
  }
}
