// lib/features/customer/screens/store_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:del_pick/features/customer/controllers/store_detail_controller.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/features/customer/widgets/menu_item_card.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StoreModel store = Get.arguments['store'];

    return GetBuilder<StoreDetailController>(
      init: StoreDetailController(
        menuRepository: Get.find(),
        storeId: store.id,
      ),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(store),
            SliverToBoxAdapter(
              child: _buildStoreInfo(store),
            ),
            SliverToBoxAdapter(
              child: _buildMenuSection(controller),
            ),
          ],
        ),
        bottomNavigationBar: _buildCartBottomBar(),
      ),
    );
  }

  Widget _buildSliverAppBar(StoreModel store) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: store.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: store.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingWidget(),
                errorWidget: (context, url, error) => Image.asset(
                  AppConstants.defaultStoreImageUrl,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                AppConstants.defaultStoreImageUrl,
                fit: BoxFit.cover,
              ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Implement favorite functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Implement share functionality
          },
        ),
      ],
    );
  }

  Widget _buildStoreInfo(StoreModel store) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: AppTextStyles.h4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: store.isOpenNow()
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  store.isOpenNow() ? 'Open' : 'Closed',
                  style: AppTextStyles.labelMedium.copyWith(
                    color:
                        store.isOpenNow() ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            store.address,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            children: [
              // Rating
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.rating,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    store.displayRating,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ' (${store.reviewCount ?? 0} reviews)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.spacingLG),
              // Distance
              if (store.distance != null)
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
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
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Opening hours
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${store.openTime} - ${store.closeTime}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(StoreDetailController controller) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu',
            style: AppTextStyles.h5,
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Obx(() {
            if (controller.isLoading) {
              return const LoadingWidget(message: 'Loading menu...');
            }

            if (controller.hasError) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      controller.errorMessage,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.refreshMenu,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!controller.hasMenuItems) {
              return const EmptyStateWidget(
                message: 'No menu items available',
                icon: Icons.restaurant_menu,
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = controller.menuItems[index];
                return MenuItemCard(
                  menuItem: menuItem,
                  onTap: () => _showMenuItemDetail(menuItem),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCartBottomBar() {
    return GetBuilder<CartController>(
      builder: (cartController) => Obx(() {
        if (cartController.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLG),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cartController.itemCount} items',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        cartController.formattedTotal,
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('View Cart'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showMenuItemDetail(menuItem) {
    Get.bottomSheet(
      MenuItemDetailBottomSheet(menuItem: menuItem),
      isScrollControlled: true,
    );
  }
}

// Menu Item Detail Bottom Sheet
class MenuItemDetailBottomSheet extends StatelessWidget {
  final dynamic menuItem;

  const MenuItemDetailBottomSheet({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context) {
    final RxInt quantity = 1.obs;
    final RxString notes = ''.obs;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    if (menuItem.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: menuItem.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: AppColors.border,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppDimensions.spacingLG),

                    // Name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            menuItem.name,
                            style: AppTextStyles.h5,
                          ),
                        ),
                        Text(
                          menuItem.formattedPrice,
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacingMD),

                    // Description
                    if (menuItem.description != null &&
                        menuItem.description!.isNotEmpty)
                      Text(
                        menuItem.description!,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // Quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity',
                          style: AppTextStyles.h6,
                        ),
                        Obx(() => Row(
                              children: [
                                IconButton(
                                  onPressed: quantity.value > 1
                                      ? () => quantity.value--
                                      : null,
                                  icon: const Icon(Icons.remove),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.border,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    quantity.value.toString(),
                                    style: AppTextStyles.h6,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => quantity.value++,
                                  icon: const Icon(Icons.add),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.textOnPrimary,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacingLG),

                    // Notes
                    Text(
                      'Special Notes (Optional)',
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: AppDimensions.spacingSM),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Add any special instructions...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) => notes.value = value,
                    ),

                    const SizedBox(height: AppDimensions.spacingXXL),
                  ],
                ),
              ),
            ),

            // Add to cart button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: () => _addToCart(quantity.value, notes.value),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Add to Cart • ${_calculateTotalPrice(quantity.value)}',
                        style: AppTextStyles.buttonMedium,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalPrice(int quantity) {
    final total = menuItem.price * quantity;
    return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _addToCart(int quantity, String notes) {
    final CartController cartController = Get.find<CartController>();
    final StoreModel store = Get.arguments['store'];

    cartController
        .addToCart(
      menuItem,
      store,
      quantity: quantity,
      notes: notes.isNotEmpty ? notes : null,
    )
        .then((success) {
      if (success) {
        Get.back(); // Close bottom sheet
      }
    });
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:del_pick/features/customer/controllers/store_detail_controller.dart';
// import 'package:del_pick/features/customer/controllers/cart_controller.dart';
// import 'package:del_pick/features/customer/widgets/menu_item_card.dart';
// import 'package:del_pick/core/widgets/loading_widget.dart';
// import 'package:del_pick/core/widgets/empty_state_widget.dart';
// import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
// import 'package:del_pick/app/themes/app_colors.dart';
// import 'package:del_pick/app/themes/app_text_styles.dart';
// import 'package:del_pick/app/themes/app_dimensions.dart';
//
// class StoreDetailScreen extends StatelessWidget {
//   const StoreDetailScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<StoreDetailController>(
//       init: StoreDetailController(),
//       builder: (controller) => Scaffold(
//         backgroundColor: AppColors.background,
//         body: RefreshIndicator(
//           onRefresh: controller.refreshData,
//           child: CustomScrollView(
//             slivers: [
// // App Bar with Store Image
//               _buildSliverAppBar(controller),
//               // Store Info
//               SliverToBoxAdapter(
//                 child: _buildStoreInfo(controller),
//               ),
//
//               // Category Tabs
//               SliverToBoxAdapter(
//                 child: _buildCategoryTabs(controller),
//               ),
//
//               // Menu Items
//               _buildMenuItemsList(controller),
//             ],
//           ),
//         ),
//         // Floating Cart Button
//         floatingActionButton: _buildCartButton(),
//       ),
//     );
//   }
//
//   Widget _buildSliverAppBar(StoreDetailController controller) {
//     return SliverAppBar(
//       expandedHeight: 250,
//       pinned: true,
//       flexibleSpace: FlexibleSpaceBar(
//         background: controller.store?.imageUrl != null
//             ? CachedNetworkImage(
//                 imageUrl: controller.store!.imageUrl!,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   color: AppColors.surface,
//                   child: const Center(child: CircularProgressIndicator()),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   color: AppColors.surface,
//                   child: const Icon(
//                     Icons.store,
//                     size: 64,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               )
//             : Container(
//                 color: AppColors.surface,
//                 child: const Icon(
//                   Icons.store,
//                   size: 64,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.share),
//           onPressed: () {
// // Implement share functionality
//           },
//         ),
//         IconButton(
//           icon: const Icon(Icons.favorite_border),
//           onPressed: () {
// // Implement favorite functionality
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStoreInfo(StoreDetailController controller) {
//     if (controller.store == null) {
//       return Container(
//         padding: const EdgeInsets.all(AppDimensions.paddingLG),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Store Name',
//               style: AppTextStyles.h4,
//             ),
//             const SizedBox(height: AppDimensions.spacingSM),
//             Text(
//               'Loading store information...',
//               style: AppTextStyles.bodyLarge.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     final store = controller.store!;
//     return Container(
//       color: AppColors.surface,
//       padding: const EdgeInsets.all(AppDimensions.paddingLG),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Store name and status
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   store.name,
//                   style: AppTextStyles.h4,
//                 ),
//               ),
//               _buildStoreStatusBadge(store),
//             ],
//           ),
//
//           const SizedBox(height: AppDimensions.spacingSM),
//
//           // Description
//           if (store.description != null) ...[
//             Text(
//               store.description!,
//               style: AppTextStyles.bodyLarge.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: AppDimensions.spacingMD),
//           ],
//
//           // Store stats
//           Row(
//             children: [
//               // Rating
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppDimensions.paddingSM,
//                   vertical: AppDimensions.paddingXS,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.rating.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.star,
//                       color: AppColors.rating,
//                       size: 16,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       store.displayRating,
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       '(${store.reviewCount ?? 0})',
//                       style: AppTextStyles.bodySmall.copyWith(
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(width: AppDimensions.spacingMD),
//
//               // Distance
//               if (store.distance != null)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppDimensions.paddingSM,
//                     vertical: AppDimensions.paddingXS,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.location_on,
//                         color: AppColors.primary,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         store.displayDistance,
//                         style: AppTextStyles.bodyMedium.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//
//           const SizedBox(height: AppDimensions.spacingMD),
//
//           // Store hours and contact
//           Row(
//             children: [
//               // Hours
//               if (store.openTime != null && store.closeTime != null)
//                 Expanded(
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.access_time,
//                         color: AppColors.textSecondary,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${store.openTime} - ${store.closeTime}',
//                         style: AppTextStyles.bodyMedium,
//                       ),
//                     ],
//                   ),
//                 ),
//
//               // Phone
//               if (store.phone != null)
//                 GestureDetector(
//                   onTap: () {
//                     // Implement call functionality
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(AppDimensions.paddingSM),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(0.1),
//                       borderRadius:
//                           BorderRadius.circular(AppDimensions.radiusSM),
//                     ),
//                     child: const Icon(
//                       Icons.phone,
//                       color: AppColors.primary,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStoreStatusBadge(store) {
//     final isOpen = store.isOpenNow();
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppDimensions.paddingSM,
//         vertical: AppDimensions.paddingXS,
//       ),
//       decoration: BoxDecoration(
//         color: isOpen
//             ? AppColors.success.withOpacity(0.1)
//             : AppColors.error.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
//       ),
//       child: Text(
//         isOpen ? 'Open' : 'Closed',
//         style: AppTextStyles.labelSmall.copyWith(
//           color: isOpen ? AppColors.success : AppColors.error,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCategoryTabs(StoreDetailController controller) {
//     return Obx(() => Container(
//           height: 50,
//           color: AppColors.surface,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppDimensions.paddingLG,
//             ),
//             itemCount: controller.categories.length,
//             itemBuilder: (context, index) {
//               final category = controller.categories[index];
//               final isSelected = category == controller.selectedCategory;
//               return Container(
//                 margin: const EdgeInsets.only(right: AppDimensions.spacingSM),
//                 child: FilterChip(
//                   label: Text(category),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     controller.selectCategory(category);
//                   },
//                   backgroundColor: AppColors.surface,
//                   selectedColor: AppColors.primary.withOpacity(0.1),
//                   labelStyle: AppTextStyles.bodyMedium.copyWith(
//                     color: isSelected
//                         ? AppColors.primary
//                         : AppColors.textSecondary,
//                     fontWeight:
//                         isSelected ? FontWeight.w600 : FontWeight.normal,
//                   ),
//                   side: BorderSide(
//                     color: isSelected ? AppColors.primary : AppColors.border,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ));
//   }
//
//   Widget _buildMenuItemsList(StoreDetailController controller) {
//     return Obx(() {
//       if (controller.isLoading || controller.isLoadingMenu) {
//         return const SliverToBoxAdapter(
//           child: SizedBox(
//             height: 200,
//             child: LoadingWidget(),
//           ),
//         );
//       }
//       if (controller.hasError) {
//         return SliverToBoxAdapter(
//           child: app_error.ErrorWidget(
//             message: controller.errorMessage,
//             onRetry: controller.refreshData,
//           ),
//         );
//       }
//
//       if (!controller.hasMenuItems) {
//         return const SliverToBoxAdapter(
//           child: EmptyStateWidget(
//             message: 'No menu items available',
//             icon: Icons.restaurant_menu,
//           ),
//         );
//       }
//
//       return SliverPadding(
//         padding: const EdgeInsets.all(AppDimensions.paddingLG),
//         sliver: SliverList(
//           delegate: SliverChildBuilderDelegate(
//             (context, index) {
//               final menuItem = controller.filteredMenuItems[index];
//               return MenuItemCard(
//                 menuItem: menuItem,
//                 onTap: () => controller.navigateToMenuItemDetail(menuItem),
//                 onAddToCart: () => controller.addToCart(menuItem),
//               );
//             },
//             childCount: controller.filteredMenuItems.length,
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildCartButton() {
//     return GetBuilder<CartController>(
//       builder: (cartController) => cartController.isNotEmpty
//           ? FloatingActionButton.extended(
//               onPressed: cartController.proceedToCheckout,
//               backgroundColor: AppColors.primary,
//               foregroundColor: AppColors.textOnPrimary,
//               icon: const Icon(Icons.shopping_cart),
//               label: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '${cartController.itemCount} items',
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: AppColors.textOnPrimary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     width: 1,
//                     height: 16,
//                     color: AppColors.textOnPrimary.withOpacity(0.3),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     cartController.formattedTotal,
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: AppColors.textOnPrimary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : const SizedBox.shrink(),
//     );
//   }
// }
