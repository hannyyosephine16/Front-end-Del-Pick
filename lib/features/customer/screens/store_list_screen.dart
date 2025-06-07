import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/widgets/loading_widget.dart';
import 'package:del_pick/core/widgets/empty_state_widget.dart';
import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
import 'package:del_pick/features/customer/controllers/store_controller.dart';
import 'package:del_pick/features/customer/widgets/store_card.dart';
import 'package:del_pick/features/customer/widgets/store_filter_widget.dart';
import 'package:del_pick/features/customer/widgets/store_search_bar.dart';
import 'package:del_pick/app/themes/app_colors.dart';

class StoreListScreen extends StatelessWidget {
  const StoreListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      init: StoreController(
        storeRepository: Get.find(),
        locationService: Get.find(),
      ),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Restaurants'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context, controller),
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
              return const LoadingWidget();
            }

            if (controller.hasError) {
              return app_error.ErrorWidget(
                message: controller.errorMessage,
                onRetry: controller.refreshStores,
              );
            }

            if (!controller.hasStores) {
              return const EmptyStateWidget(
                message: 'No restaurants found nearby',
                icon: Icons.store_mall_directory_outlined,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.stores.length,
              itemBuilder: (context, index) {
                final store = controller.stores[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: StoreCard(
                    store: store,
                    onTap: () => Get.toNamed(
                      Routes.STORE_DETAIL,
                      arguments: {'storeId': store.id},
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, StoreController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: StoreSearchBar(
          onSearch: controller.filterStores,
          onClear: controller.refreshStores,
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, StoreController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StoreFilterWidget(
        onSortByDistance: controller.sortStoresByDistance,
        onSortByRating: controller.sortStoresByRating,
      ),
    );
  }
}

// // lib/features/customer/screens/store_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/app/routes/app_routes.dart';
// import 'package:del_pick/core/widgets/loading_widget.dart';
// import 'package:del_pick/core/widgets/empty_state_widget.dart';
// import 'package:del_pick/core/widgets/error_widget.dart' as app_error;
// import 'package:del_pick/features/customer/controllers/store_controller.dart';
// import 'package:del_pick/features/customer/widgets/store_card.dart';
// import 'package:del_pick/features/customer/widgets/store_filter_widget.dart';
// import 'package:del_pick/features/customer/widgets/store_search_bar.dart';
// import 'package:del_pick/app/themes/app_colors.dart';
// import 'package:del_pick/app/themes/app_text_styles.dart';
// import 'package:del_pick/app/themes/app_dimensions.dart';
//
// class StoreListScreen extends StatelessWidget {
//   StoreListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<StoreController>(
//       init: Get.find<StoreController>(),
//       builder: (controller) => Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: const Text('Nearby Restaurants'),
//           backgroundColor: AppColors.surface,
//           elevation: 0,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.search),
//               onPressed: () => _showSearchDialog(context, controller),
//             ),
//             IconButton(
//               icon: const Icon(Icons.filter_list),
//               onPressed: () => _showFilterBottomSheet(context, controller),
//             ),
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () => controller.refreshStores(),
//             ),
//           ],
//         ),
//         body: RefreshIndicator(
//           onRefresh: controller.refreshStores,
//           child: Obx(() {
//             print(
//                 'Building StoreListScreen - Loading: ${controller.isLoading}, HasError: ${controller.hasError}, StoreCount: ${controller.stores.length}');
//
//             if (controller.isLoading) {
//               return const Center(child: LoadingWidget());
//             }
//
//             if (controller.hasError) {
//               return Center(
//                 child: app_error.ErrorWidget(
//                   message: controller.errorMessage,
//                   onRetry: controller.refreshStores,
//                 ),
//               );
//             }
//
//             if (!controller.hasStores) {
//               return const Center(
//                 child: EmptyStateWidget(
//                   message: 'No restaurants found nearby',
//                   icon: Icons.store_mall_directory_outlined,
//                 ),
//               );
//             }
//
//             return Column(
//               children: [
//                 // Location status indicator
//                 if (!controller.hasLocation)
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(AppDimensions.paddingMD),
//                     color: AppColors.warning.withOpacity(0.1),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.location_off,
//                           color: AppColors.warning,
//                           size: AppDimensions.iconSM,
//                         ),
//                         const SizedBox(width: AppDimensions.spacingSM),
//                         Expanded(
//                           child: Text(
//                             'Location not available. Showing all restaurants.',
//                             style: AppTextStyles.bodySmall.copyWith(
//                               color: AppColors.warning,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 // Store count info
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(AppDimensions.paddingMD),
//                   child: Text(
//                     '${controller.stores.length} restaurants found',
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ),
//
//                 // Store list
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: AppDimensions.paddingLG,
//                     ),
//                     itemCount: controller.stores.length,
//                     itemBuilder: (context, index) {
//                       final store = controller.stores[index];
//                       return Container(
//                         margin: const EdgeInsets.only(
//                           bottom: AppDimensions.spacingMD,
//                         ),
//                         child: StoreCard(
//                           store: store,
//                           onTap: () {
//                             print('Navigating to store detail: ${store.id}');
//                             Get.toNamed(
//                               Routes.STORE_DETAIL,
//                               arguments: {'storeId': store.id},
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             print('Refreshing stores manually');
//             controller.refreshStores();
//           },
//           child: const Icon(Icons.refresh),
//         ),
//       ),
//     );
//   }
//
//   void _showSearchDialog(BuildContext context, StoreController controller) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         contentPadding: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         content: StoreSearchBar(
//           onSearch: (query) {
//             print('Searching for: $query');
//             controller.filterStores(query);
//           },
//           onClear: () {
//             print('Clearing search');
//             controller.refreshStores();
//           },
//         ),
//       ),
//     );
//   }
//
//   void _showFilterBottomSheet(
//       BuildContext context, StoreController controller) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => StoreFilterWidget(
//         onSortByDistance: () {
//           print('Sorting by distance');
//           controller.sortStoresByDistance();
//         },
//         onSortByRating: () {
//           print('Sorting by rating');
//           controller.sortStoresByRating();
//         },
//       ),
//     );
//   }
// }
