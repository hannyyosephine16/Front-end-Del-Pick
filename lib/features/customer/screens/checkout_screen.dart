// lib/features/customer/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/checkout_controller.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      init: CheckoutController(
        orderRepository: Get.find(),
        cartController: Get.find<CartController>(),
      ),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: Obx(() {
          if (controller.isLoading) {
            return const LoadingWidget(message: 'Processing order...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery address section
                _buildDeliveryAddressSection(controller),

                const SizedBox(height: AppDimensions.spacingXL),

                // Order items section
                _buildOrderItemsSection(controller),

                const SizedBox(height: AppDimensions.spacingXL),

                // Order notes section
                _buildOrderNotesSection(controller),

                const SizedBox(height: AppDimensions.spacingXL),

                // Order summary section
                _buildOrderSummarySection(controller),

                const SizedBox(height: AppDimensions.spacingXXL),
              ],
            ),
          );
        }),
        bottomNavigationBar: _buildBottomBar(controller),
      ),
    );
  }

  Widget _buildDeliveryAddressSection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Delivery Address',
                style: AppTextStyles.h6,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Obx(() => Text(
                controller.deliveryAddress,
                style: AppTextStyles.bodyLarge,
              )),
          const SizedBox(height: AppDimensions.spacingMD),
          TextButton.icon(
            onPressed: () {
              // TODO: Implement address selection
              _showAddressSelectionDialog(controller);
            },
            icon: const Icon(Icons.edit_location_alt),
            label: const Text('Change Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(CheckoutController controller) {
    final cartController = controller.cartController;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Order Items',
                style: AppTextStyles.h6,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),

          // Store name
          Text(
            'From: ${cartController.currentStoreName}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),

          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartController.cartItems.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: AppDimensions.spacingSM,
            ),
            itemBuilder: (context, index) {
              final item = cartController.cartItems[index];
              return Row(
                children: [
                  Text(
                    '${item.quantity}x',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSM),
                  Expanded(
                    child: Text(
                      item.name,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Text(
                    item.formattedTotalPrice,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNotesSection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.note_alt,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Order Notes (Optional)',
                style: AppTextStyles.h6,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Add any special instructions for your order...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: controller.updateNotes,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(CheckoutController controller) {
    final cartController = controller.cartController;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Order Summary',
                style: AppTextStyles.h6,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: AppTextStyles.bodyLarge,
              ),
              Text(
                cartController.formattedSubtotal,
                style: AppTextStyles.bodyLarge,
              ),
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
              Text(
                cartController.formattedServiceCharge,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
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
                style: AppTextStyles.h5,
              ),
              Text(
                cartController.formattedTotal,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CheckoutController controller) {
    final cartController = controller.cartController;

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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Payment method (placeholder)
            Row(
              children: [
                const Icon(Icons.payment, color: AppColors.primary),
                const SizedBox(width: AppDimensions.spacingSM),
                Text(
                  'Cash on Delivery',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // TextButton(
                //   onPressed: () {
                //     // TODO: Implement payment method selection
                //   },
                //   child: const Text('Change'),
                // ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLG),

            // Place order button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    controller.canPlaceOrder ? controller.placeOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Place Order • ${cartController.formattedTotal}',
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSelectionDialog(CheckoutController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Delivery Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Institut Teknologi Del'),
              subtitle: const Text('Jl. Sisingamangaraja, Sitoluama'),
              onTap: () {
                controller.updateDeliveryAddress('Institut Teknologi Del');
                Get.back();
              },
            ),
            // Add more addresses here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
