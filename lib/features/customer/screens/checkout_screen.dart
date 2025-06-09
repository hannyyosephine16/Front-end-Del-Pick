// lib/features/customer/screens/checkout_screen.dart

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
    // Ensure controller is initialized
    final CheckoutController controller = Get.put(CheckoutController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return const Center(
            child: Text('Cart is empty'),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Address Section
                    _buildDeliveryAddressSection(controller),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Store Info Section
                    _buildStoreInfoSection(controller),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Order Items Section
                    _buildOrderItemsSection(controller),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Notes Section
                    _buildNotesSection(controller),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Order Summary Section
                    _buildOrderSummarySection(controller),
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

  Widget _buildDeliveryAddressSection(CheckoutController controller) {
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
                Icons.location_on,
                color: AppColors.primary,
                size: AppDimensions.iconMD,
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Text('Delivery Address', style: AppTextStyles.h6),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Obx(() => Text(
                controller.deliveryAddress,
                style: AppTextStyles.bodyLarge,
              )),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            'Coordinates: ${controller.customerLatitude.toStringAsFixed(6)}, ${controller.customerLongitude.toStringAsFixed(6)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
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
          const Icon(
            Icons.store,
            color: AppColors.secondary,
            size: AppDimensions.iconMD,
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order from',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    )),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(controller.storeName, style: AppTextStyles.h6),
              ],
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
          Text('Order Items', style: AppTextStyles.h6),
          const SizedBox(height: AppDimensions.spacingMD),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.cartItems.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = controller.cartItems[index];
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: AppTextStyles.bodyMedium),
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Text(
                            'Note: ${item.notes}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text('${item.quantity}x', style: AppTextStyles.bodyMedium),
                  const SizedBox(width: AppDimensions.spacingMD),
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
          Text('Order Notes (Optional)', style: AppTextStyles.h6),
          const SizedBox(height: AppDimensions.spacingMD),
          TextField(
            onChanged: controller.updateNotes,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add special instructions for your order...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(AppDimensions.paddingMD),
            ),
          ),
        ],
      ),
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.bodyMedium),
              Text(controller.formattedSubtotal,
                  style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),
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
                controller.formattedServiceCharge,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: AppDimensions.spacingLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.h6),
              Text(
                controller.formattedTotal,
                style: AppTextStyles.h6.copyWith(color: AppColors.primary),
              ),
            ],
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
            height: 48,
            child: ElevatedButton(
              onPressed: controller.isLoading ? null : controller.placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Place Order (${controller.formattedTotal})',
                      style: AppTextStyles.buttonLarge,
                    ),
            ),
          )),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? AppTextStyles.h6 : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.h6.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )
              : AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}
