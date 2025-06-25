// lib/features/customer/screens/order_tracking_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/order_tracking_controller.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderTrackingController>(
      init: OrderTrackingController(
        trackingRepository: Get.find(),
        orderRepository: Get.find(),
      ),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Order Tracking'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          actions: [
            Obx(() {
              if (controller.isTrackingActive) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Live',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            IconButton(
              onPressed: controller.refreshTracking,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading) {
            return const LoadingWidget(message: 'Loading tracking info...');
          }

          if (controller.hasError) {
            return app_error.ErrorWidget(
              message: controller.errorMessage,
              onRetry: () {
                if (controller.order != null) {
                  controller.loadOrderTracking(controller.order!.id);
                }
              },
            );
          }

          if (controller.order == null) {
            return const EmptyStateWidget(
              message: 'Order not found',
              icon: Icons.receipt_long_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshTracking,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info Card
                  _buildOrderInfoCard(controller),

                  const SizedBox(height: AppDimensions.spacingXL),

                  // Tracking Timeline
                  _buildTrackingTimeline(controller),

                  const SizedBox(height: AppDimensions.spacingXL),

                  // Driver Info (if available)
                  if (controller.hasDriver) ...[
                    _buildDriverInfoCard(controller),
                    const SizedBox(height: AppDimensions.spacingXL),
                  ],

                  // Map Section (placeholder for now)
                  if (controller.canTrack) ...[
                    _buildMapSection(controller),
                    const SizedBox(height: AppDimensions.spacingXL),
                  ],

                  // Action Buttons
                  _buildActionButtons(controller),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderInfoCard(OrderTrackingController controller) {
    final order = controller.order!;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.toString().padLeft(6, '0')}',
                style: AppTextStyles.h6,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSM,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Text(
                  controller.currentStatus,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMD),

          // Store info
          if (order.store != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.store,
                  size: AppDimensions.iconSM,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingSM),
                Expanded(
                  child: Text(
                    order.store!.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSM),
          ],

          // Status description
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: AppDimensions.iconSM,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: AppDimensions.spacingSM),
                Expanded(
                  child: Text(
                    controller.getOrderStatusDescription(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Estimated delivery time
          if (controller.canTrack) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: AppDimensions.iconSM,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingSM),
                Text(
                  'Est. delivery: ${controller.getEstimatedDeliveryTime()}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(OrderTrackingController controller) {
    final steps = controller.getTrackingSteps();

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
          Text('Order Progress', style: AppTextStyles.h6),
          const SizedBox(height: AppDimensions.spacingLG),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: step.isCompleted
                              ? AppColors.success
                              : step.isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step.isCompleted
                              ? Icons.check
                              : step.isActive
                                  ? step.icon
                                  : step.icon,
                          size: 16,
                          color: step.isCompleted || step.isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: step.isCompleted
                              ? AppColors.success
                              : AppColors.textSecondary.withOpacity(0.3),
                        ),
                    ],
                  ),

                  const SizedBox(width: AppDimensions.spacingMD),

                  // Step content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: step.isCompleted || step.isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.subtitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDriverInfoCard(OrderTrackingController controller) {
    final driver = controller.driverInfo!;

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
          Text('Your Driver', style: AppTextStyles.h6),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            children: [
              // Driver avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.spacingMD),

              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating as String,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Call button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: controller.contactDriver,
                  icon: const Icon(
                    Icons.phone,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(OrderTrackingController controller) {
    return Container(
      height: 200,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Stack(
          children: [
            // Map placeholder
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade200,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Map View',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Real-time tracking',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Map overlay info
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Delivery to: Institut Teknologi Del',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderTrackingController controller) {
    return Column(
      children: [
        // View Order Detail Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.navigateToOrderDetail,
            icon: const Icon(Icons.receipt_long),
            label: const Text('View Order Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ),

        // Contact Support (if needed)
        const SizedBox(height: AppDimensions.spacingSM),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              Get.snackbar(
                'Contact Support',
                'Support feature coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact Support'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
