// lib/features/customer/screens/checkout_screen.dart - FINAL CLEAN VERSION

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/checkout_controller.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutController controller = Get.put(CheckoutController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        // Empty cart state
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCartState();
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Info Section
                    _buildStoreInfoSection(controller),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Order Items Section
                    _buildOrderItemsSection(controller),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Notes Section
                    _buildNotesSection(controller),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Order Summary Section (NO payment method)
                    _buildOrderSummarySection(controller),

                    // Add some bottom padding for better scrolling
                    const SizedBox(height: AppDimensions.spacingXXL),
                  ],
                ),
              ),
            ),

            // Place Order Button
            _buildPlaceOrderButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          Text(
            'Your cart is empty',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            'Add some items to your cart to continue',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoSection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSM),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: const Icon(
              Icons.store,
              color: AppColors.secondary,
              size: AppDimensions.iconMD,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order from',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  controller.storeName,
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          // Items count badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSM,
              vertical: AppDimensions.paddingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Text(
              '${controller.cartItems.length} items',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Items', style: AppTextStyles.h6),
              Text(
                '${controller.cartItems.length} items',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.cartItems.length,
            separatorBuilder: (context, index) => const Divider(
              height: AppDimensions.spacingLG,
            ),
            itemBuilder: (context, index) {
              final item = controller.cartItems[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.notes != null && item.notes!.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.spacingXS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingSM,
                              vertical: AppDimensions.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusXS),
                            ),
                            child: Text(
                              'Note: ${item.notes}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.orange.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMD),
                  Text(
                    item.formattedTotalPrice,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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

  Widget _buildNotesSection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.note_alt_outlined,
                color: AppColors.textSecondary,
                size: AppDimensions.iconSM,
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Text('Order Notes', style: AppTextStyles.h6),
              const SizedBox(width: AppDimensions.spacingSM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                ),
                child: Text(
                  'Optional',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          TextField(
            onChanged: controller.setDeliveryNotes,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Add special instructions for your order...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(AppDimensions.paddingMD),
              counterStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Order Summary - NO payment method selection, only cash
  Widget _buildOrderSummarySection(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTextStyles.h6),
          const SizedBox(height: AppDimensions.spacingMD),

          // Subtotal
          _buildSummaryRow('Subtotal', controller.formattedSubtotal),
          const SizedBox(height: AppDimensions.spacingSM),

          // Delivery fee info
          _buildSummaryRow(
            'Delivery Fee',
            'Calculated by distance',
            isSecondary: true,
            isCalculated: true,
          ),

          const Divider(height: AppDimensions.spacingLG),

          // Total shows as "Will be calculated"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.h6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Will be calculated',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'after order confirmation',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingSM),

          // Info about delivery and payment (CASH ONLY)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSM),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: AppDimensions.iconSM,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: AppDimensions.spacingSM),
                    Expanded(
                      child: Text(
                        'Delivery fee calculated based on distance from store',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Row(
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: AppDimensions.iconSM,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: AppDimensions.spacingSM),
                    Expanded(
                      child: Text(
                        'Payment: Cash on Delivery (COD)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Obx(() => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  controller.cartItems.isNotEmpty && !controller.isLoading
                      ? controller.showOrderConfirmation
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                disabledBackgroundColor:
                    AppColors.textSecondary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
                elevation: controller.cartItems.isNotEmpty ? 2 : 0,
              ),
              child: controller.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingSM),
                        Text(
                          'Placing Order...',
                          style: AppTextStyles.buttonLarge,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_checkout),
                        const SizedBox(width: AppDimensions.spacingSM),
                        Text(
                          'Place Order (${controller.formattedSubtotal})',
                          style: AppTextStyles.buttonLarge,
                        ),
                      ],
                    ),
            ),
          )),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isSecondary = false,
    bool isCalculated = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.h6
              : AppTextStyles.bodyMedium.copyWith(
                  color: isSecondary ? AppColors.textSecondary : null,
                ),
        ),
        Text(
          value,
          style: isCalculated
              ? AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                )
              : isTotal
                  ? AppTextStyles.h6.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    )
                  : AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSecondary
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
        ),
      ],
    );
  }
}
