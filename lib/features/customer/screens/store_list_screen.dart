// lib/features/customer/screens/store_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
import 'package:del_pick/features/customer/controllers/store_controller.dart';
import 'package:del_pick/features/customer/widgets/store_card.dart';
import 'package:del_pick/features/customer/widgets/store_filter_widget.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class StoreListScreen extends GetWidget<StoreController> {
  const StoreListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Search
            _buildCustomAppBar(context),

            // Status and Filter Bar
            _buildStatusBar(),

            // Store List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshStores,
                child: Obx(() {
                  if (controller.isLoading && controller.stores.isEmpty) {
                    return const LoadingWidget(
                        message: 'Loading restaurants...');
                  }

                  if (controller.hasError) {
                    return app_error.ErrorWidget(
                      message: controller.errorMessage,
                      onRetry: controller.refreshStores,
                    );
                  }

                  if (!controller.hasStores) {
                    return EmptyStateWidget(
                      message: controller.searchQuery.isNotEmpty
                          ? 'No restaurants found for "${controller.searchQuery}"'
                          : 'No restaurants found nearby',
                      icon: Icons.store_mall_directory_outlined,
                      onRetry: controller.refreshStores,
                      retryText: 'Refresh',
                    );
                  }

                  return _buildStoreList();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          // Top row with back button and actions
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Text(
                  'Nearby Restaurants',
                  style: AppTextStyles.h5,
                ),
              ),
              IconButton(
                onPressed: () => _showFilterBottomSheet(context),
                icon: const Icon(Icons.filter_list),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMD),

          // Search Bar
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Obx(() => Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            onChanged: controller.searchStores,
            decoration: InputDecoration(
              hintText: 'Search restaurants...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: controller.isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: controller.searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clearSearch();
                        // Clear the text field
                        FocusScope.of(Get.context!).unfocus();
                      },
                      icon: const Icon(Icons.clear,
                          color: AppColors.textSecondary),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
                vertical: AppDimensions.paddingSM,
              ),
            ),
          ),
        ));
  }

  Widget _buildStatusBar() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingSM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Results count
              Text(
                controller.searchQuery.isNotEmpty
                    ? '${controller.filteredStoresCount} of ${controller.totalStoresCount} restaurants'
                    : '${controller.totalStoresCount} restaurants found',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              // Current sort indicator
              if (controller.stores.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      _getSortIcon(controller.currentSortBy),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'by ${controller.currentSortBy}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ));
  }

  IconData _getSortIcon(String sortBy) {
    switch (sortBy) {
      case 'distance':
        return Icons.location_on;
      case 'rating':
        return Icons.star;
      case 'name':
        return Icons.sort_by_alpha;
      default:
        return Icons.sort;
    }
  }

  Widget _buildStoreList() {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingSM,
          ),
          itemCount: controller.stores.length,
          itemBuilder: (context, index) {
            final store = controller.stores[index];
            return Container(
              margin: EdgeInsets.only(
                bottom: index < controller.stores.length - 1
                    ? AppDimensions.spacingMD
                    : AppDimensions.spacingLG,
              ),
              child: StoreCard(
                store: store,
                onTap: () => Get.toNamed(
                  Routes.STORE_DETAIL,
                  arguments: {'storeId': store.id},
                ),
              ),
            );
          },
        ));
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingLG),

            // Title
            Text('Filter & Sort', style: AppTextStyles.h5),

            const SizedBox(height: AppDimensions.spacingLG),

            // Sort options
            Text('Sort by', style: AppTextStyles.h6),
            const SizedBox(height: AppDimensions.spacingMD),

            _buildSortOption(
              icon: Icons.location_on,
              title: 'Distance',
              subtitle: 'Nearest first',
              isSelected: controller.currentSortBy == 'distance',
              onTap: () {
                controller.sortStoresByDistance();
                Navigator.pop(context);
              },
            ),

            _buildSortOption(
              icon: Icons.star,
              title: 'Rating',
              subtitle: 'Highest rated first',
              isSelected: controller.currentSortBy == 'rating',
              onTap: () {
                controller.sortStoresByRating();
                Navigator.pop(context);
              },
            ),

            _buildSortOption(
              icon: Icons.sort_by_alpha,
              title: 'Name',
              subtitle: 'A to Z',
              isSelected: controller.currentSortBy == 'name',
              onTap: () {
                controller.sortStoresByName();
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: AppDimensions.spacingLG),
            const Divider(),
            const SizedBox(height: AppDimensions.spacingMD),

            // Filter options
            Text('Filter by', style: AppTextStyles.h6),
            const SizedBox(height: AppDimensions.spacingMD),

            _buildFilterOption(
              icon: Icons.schedule,
              title: 'Open Now',
              onTap: () {
                controller.filterOpenStores();
                Navigator.pop(context);
              },
            ),

            _buildFilterOption(
              icon: Icons.star_border,
              title: 'Highly Rated (4.0+)',
              onTap: () {
                controller.filterByRating(4.0);
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: AppDimensions.spacingLG),

            // Reset button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  controller.resetFilters();
                  Navigator.pop(context);
                },
                child: const Text('Reset All Filters'),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingSM),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
          isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
