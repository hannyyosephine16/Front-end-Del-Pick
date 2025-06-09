// lib/features/customer/screens/order_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/order_tracking_controller.dart';
import 'package:del_pick/features/customer/widgets/mapbox_delivery_map.dart';
import 'package:del_pick/features/customer/widgets/tracking_timeline_widget.dart';
import 'package:del_pick/features/customer/widgets/driver_info_widget.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
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
          title: const Text('Track Order'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.goBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.refreshTracking,
            ),
            if (controller.order != null)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: controller.navigateToOrderDetail,
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
              onRetry: () => controller.loadOrderTracking(
                Get.arguments?['orderId'] ?? 0,
              ),
            );
          }

          if (controller.order == null) {
            return const Center(
              child: Text('Order not found'),
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

                  const SizedBox(height: AppDimensions.spacingLG),

                  // Map Section (only if can track)
                  if (controller.canTrack) ...[
                    _buildMapSection(controller),
                    const SizedBox(height: AppDimensions.spacingLG),
                  ],

                  // Driver Info (if available)
                  if (controller.hasDriver) ...[
                    DriverInfoWidget(
                      driver: controller.trackingInfo!.driver!,
                      onCall: controller.contactDriver,
                    ),
                    const SizedBox(height: AppDimensions.spacingLG),
                  ],

                  // Tracking Timeline
                  TrackingTimelineWidget(
                    steps: controller.getTrackingSteps(),
                  ),

                  const SizedBox(height: AppDimensions.spacingLG),

                  // Real-time Status
                  if (controller.isTrackingActive)
                    _buildRealTimeStatus(controller),
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
              Text(order.code, style: AppTextStyles.h5),
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
                  order.statusDisplayName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            order.storeName,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            controller.getOrderStatusDescription(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Items',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${order.totalItems} items',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    order.formattedTotal,
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(OrderTrackingController controller) {
    if (controller.storeLatitude == null || controller.storeLongitude == null) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text('Map not available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Live Tracking', style: AppTextStyles.h6),
        const SizedBox(height: AppDimensions.spacingSM),

        // Map
        MapboxDeliveryMap(
          storeLatitude: controller.storeLatitude!,
          storeLongitude: controller.storeLongitude!,
          customerLatitude: controller.customerLatitude,
          customerLongitude: controller.customerLongitude,
          driverLatitude: controller.driverLatitude,
          driverLongitude: controller.driverLongitude,
        ),

        const SizedBox(height: AppDimensions.spacingSM),

        // Map Info
        DeliveryMapInfo(
          storeName: controller.order!.storeName,
          customerAddress: controller.order!.deliveryAddress,
          estimatedTime: controller.getEstimatedDeliveryTime(),
        ),
      ],
    );
  }

  Widget _buildRealTimeStatus(OrderTrackingController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSM),
          Expanded(
            child: Text(
              'Live tracking active • Updates every 15 seconds',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(() => Text(
                'Refresh ${controller.refreshCounter}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                ),
              )),
        ],
      ),
    );
  }
}
