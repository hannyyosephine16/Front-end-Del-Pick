// lib/features/customer/screens/customer_home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/home_controller.dart';
import 'package:del_pick/features/customer/widgets/store_card.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

import '../widgets/recent_order_card.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerHomeController>(
      init: CustomerHomeController(
        storeRepository: Get.find(),
        orderRepository: Get.find(),
        locationService: Get.find(),
      ),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.greeting,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary.withOpacity(0.8),
                          ),
                        )),
                    const Text(
                      'DelPick',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: controller.navigateToCart,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: controller.navigateToProfile,
                  ),
                ],
              ),

              // Location Section
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.textOnPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.textOnPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() => Text(
                                controller.currentAddress,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textOnPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                        TextButton(
                          onPressed: controller.refreshLocation,
                          child: Text(
                            'Change',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.store,
                          label: 'Browse Stores',
                          onTap: controller.navigateToStores,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.history,
                          label: 'Order History',
                          onTap: controller.navigateToOrders,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.search,
                          label: 'Search',
                          onTap: controller.navigateToSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Nearby Stores Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nearby Stores', style: AppTextStyles.h5),
                      TextButton(
                        onPressed: controller.navigateToStores,
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),

              // Stores Loading/Error/Content
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoadingStores) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingWidget(message: 'Loading stores...'),
                    );
                  }

                  if (controller.hasError && !controller.hasStores) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: app_error.ErrorWidget(
                        message: controller.errorMessage,
                        onRetry: controller.refreshData,
                      ),
                    );
                  }

                  if (!controller.hasStores) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: EmptyStateWidget(
                        message: 'No stores nearby',
                        icon: Icons.store_outlined,
                      ),
                    );
                  }

                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.nearbyStores.length,
                      itemBuilder: (context, index) {
                        final store = controller.nearbyStores[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          child: StoreCard(
                            store: store,
                            onTap: () =>
                                controller.navigateToStoreDetail(store.id),
                            showDistance: true,
                            isCompact: true,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),

              // Recent Orders Section
              SliverToBoxAdapter(
                child: Obx(() {
                  if (!controller.hasOrders && !controller.isLoadingOrders) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Orders', style: AppTextStyles.h5),
                        TextButton(
                          onPressed: controller.navigateToOrders,
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // Orders Loading/Content
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoadingOrders) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingWidget(message: 'Loading your orders...'),
                    );
                  }

                  if (!controller.hasOrders) {
                    return const SizedBox.shrink();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.recentOrders.length,
                    itemBuilder: (context, index) {
                      final order = controller.recentOrders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RecentOrderCard(
                          order: order,
                          onTap: () =>
                              controller.navigateToOrderDetail(order.id),
                          onTrack: order.canTrack
                              ? () =>
                                  controller.navigateToOrderTracking(order.id)
                              : null,
                        ),
                      );
                    },
                  );
                }),
              ),

              // Active Orders Section (if any)
              SliverToBoxAdapter(
                child: Obx(() {
                  if (!controller.hasActiveOrders) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Active Orders',
                              style: AppTextStyles.h6.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have ${controller.activeOrders.length} active order(s)',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.navigateToOrders,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              foregroundColor: AppColors.textOnPrimary,
                            ),
                            child: const Text('Track Orders'),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
