// lib/features/customer/screens/menu_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/core/widgets/network_image_widget.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

import '../../shared/widgets/netwrok_image_widget.dart';

class MenuDetailScreen extends StatefulWidget {
  const MenuDetailScreen({super.key});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  late MenuItemModel menuItem;
  late StoreModel store;
  final CartController cartController = Get.find<CartController>();

  int quantity = 1;
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    menuItem = arguments['menuItem'] as MenuItemModel;
    store = arguments['store'] as StoreModel;
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Image Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'menu_item_${menuItem.id}',
                child: NetworkImageWidget(
                  imageUrl: menuItem.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Availability
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                menuItem.name,
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!menuItem.isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingSM,
                                  vertical: AppDimensions.paddingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSM,
                                  ),
                                ),
                                child: Text(
                                  'Out of Stock',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spacingSM),

                        // Price
                        Text(
                          menuItem.formattedPrice,
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingMD),

                        // Category
                        if (menuItem.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingSM,
                              vertical: AppDimensions.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSM,
                              ),
                            ),
                            child: Text(
                              menuItem.category!,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),

                        const SizedBox(height: AppDimensions.spacingLG),

                        // Description
                        if (menuItem.description != null &&
                            menuItem.description!.isNotEmpty) ...[
                          Text('Description', style: AppTextStyles.h6),
                          const SizedBox(height: AppDimensions.spacingSM),
                          Text(
                            menuItem.description!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingLG),
                        ],

                        // Store Info
                        Container(
                          padding:
                              const EdgeInsets.all(AppDimensions.paddingMD),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMD,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.store,
                                color: AppColors.textSecondary,
                                size: AppDimensions.iconSM,
                              ),
                              const SizedBox(width: AppDimensions.spacingSM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      store.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (store.rating != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: AppDimensions.iconSM,
                                    ),
                                    const SizedBox(
                                        width: AppDimensions.spacingXS),
                                    Text(
                                      store.rating!.toStringAsFixed(1),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Quantity Selection
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity', style: AppTextStyles.h6),
                        const SizedBox(height: AppDimensions.spacingMD),
                        Row(
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingLG,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingLG,
                                vertical: AppDimensions.paddingSM,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMD,
                                ),
                              ),
                              child: Text(
                                '$quantity',
                                style: AppTextStyles.h5.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add,
                              onPressed: () => setState(() => quantity++),
                            ),
                            const Spacer(),
                            Text(
                              'Total: ${_formatPrice(menuItem.price * quantity)}',
                              style: AppTextStyles.h6.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Notes Section
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Special Instructions', style: AppTextStyles.h6),
                        const SizedBox(height: AppDimensions.spacingMD),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          maxLength: 100,
                          decoration: InputDecoration(
                            hintText: 'Any special requests? (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMD,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMD,
                              ),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.all(
                              AppDimensions.paddingMD,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom padding for FAB
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: menuItem.isAvailable ? _addToCart : null,
        backgroundColor: menuItem.isAvailable
            ? AppColors.primary
            : AppColors.textSecondary.withOpacity(0.3),
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.shopping_cart),
        label: Text(
          menuItem.isAvailable
              ? 'Add to Cart • ${_formatPrice(menuItem.price * quantity)}'
              : 'Out of Stock',
          style: AppTextStyles.buttonMedium,
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: onPressed != null ? AppColors.primary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: onPressed != null ? AppColors.primary : AppColors.textSecondary,
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  Future<void> _addToCart() async {
    final notes = notesController.text.trim();
    final success = await cartController.addToCart(
      menuItem,
      store,
      quantity: quantity,
      notes: notes.isEmpty ? null : notes,
    );

    if (success) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${menuItem.name} added to cart'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back or show cart option
      _showCartOption();
    }
  }

  void _showCartOption() {
    Get.dialog(
      AlertDialog(
        title: const Text('Item Added!'),
        content: Text('${menuItem.name} has been added to your cart.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to store detail
            },
            child: const Text('Continue Shopping'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.toNamed('/cart');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('View Cart'),
          ),
        ],
      ),
    );
  }
}
