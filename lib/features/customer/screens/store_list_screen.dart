import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/store_controller.dart';
import 'package:del_pick/features/customer/widgets/store_card.dart';
import 'package:del_pick/features/customer/widgets/store_search_bar.dart';
import 'package:del_pick/features/customer/widgets/store_filter_widget.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as core_error;
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class StoreListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      init: StoreController(
        storeRepository: Get.find(),
        locationService: Get.find(),
      ),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Restaurants'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchBottomSheet(context, controller),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterBottomSheet(context, controller),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: controller.refreshStores,
          child: Obx(() {
            if (controller.isLoading) {
              return const LoadingWidget(message: 'Loading restaurants...');
            }

            if (controller.hasError) {
              return core_error.ErrorWidget(
                message: controller.errorMessage,
                onRetry: controller.refreshStores,
              );
            }

            if (!controller.hasStores) {
              return const EmptyStateWidget(
                message: 'No restaurants found',
                icon: Icons.store_mall_directory_outlined,
              );
            }

            return _buildStoreList(controller);
          }),
        ),
      ),
    );
  }

  Widget _buildStoreList(StoreController controller) {
    return Column(
      children: [
        // Location info
        if (controller.hasLocation)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            color: AppColors.primary.withOpacity(0.1),
            child: Text(
              'Showing restaurants near you',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Store list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            itemCount: controller.stores.length,
            itemBuilder: (context, index) {
              final store = controller.stores[index];
              return StoreCard(
                store: store,
                onTap: () => Get.toNamed(
                  '/store_detail',
                  arguments: {'store': store},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSearchBottomSheet(
      BuildContext context, StoreController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
          child: StoreSearchBar(
            onSearch: controller.filterStores,
            onClear: controller.refreshStores,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, StoreController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        child: StoreFilterWidget(
          onSortByDistance: controller.sortStoresByDistance,
          onSortByRating: controller.sortStoresByRating,
        ),
      ),
    );
  }
}
