// lib/features/customer/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';

import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Obx(() => controller.isNotEmpty
              ? TextButton(
                  onPressed: () => _showClearCartDialog(controller),
                  child: Text(
                    'Clear',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isEmpty) {
          return const EmptyStateWidget(
            message: 'Your cart is empty',
            icon: Icons.shopping_cart_outlined,
          );
        }

        return Column(
          children: [
            // Store info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              color: AppColors.surface,
              child: Row(
                children: [
                  const Icon(
                    Icons.store,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.spacingSM),
                  Text(
                    controller.currentStoreName,
                    style: AppTextStyles.h6,
                  ),
                ],
              ),
            ),

            // Cart items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return CartItemWidget(
                    cartItem: item,
                    onQuantityChanged: (newQuantity) {
                      controller.updateQuantity(item.menuItemId, newQuantity);
                    },
                    onRemove: () {
                      controller.removeFromCart(item.menuItemId);
                    },
                  );
                },
              ),
            ),

            // Cart summary
            _buildCartSummary(controller),
          ],
        );
      }),
    );
  }

  Widget _buildCartSummary(CartController controller) {
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
        child: Column(
          children: [
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: AppTextStyles.bodyLarge,
                ),
                Obx(() => Text(
                      controller.formattedSubtotal,
                      style: AppTextStyles.bodyLarge,
                    )),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingSM),

            // Service charge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Charge (10%)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Obx(() => Text(
                      controller.formattedServiceCharge,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingMD),

            const Divider(),

            const SizedBox(height: AppDimensions.spacingMD),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTextStyles.h6,
                ),
                Obx(() => Text(
                      controller.formattedTotal,
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.primary,
                      ),
                    )),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingXL),

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.proceedToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Proceed to Checkout',
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(CartController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCart();
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
