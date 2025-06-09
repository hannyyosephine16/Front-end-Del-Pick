// // lib/features/customer/widgets/advanced_store_filter_widget.dart
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/features/customer/controllers/store_controller.dart';
// import 'package:del_pick/app/themes/app_colors.dart';
// import 'package:del_pick/app/themes/app_text_styles.dart';
// import 'package:del_pick/app/themes/app_dimensions.dart';
//
// class AdvancedStoreFilterWidget extends StatefulWidget {
//   final StoreController controller;
//
//   const AdvancedStoreFilterWidget({
//     super.key,
//     required this.controller,
//   });
//
//   @override
//   State<AdvancedStoreFilterWidget> createState() =>
//       _AdvancedStoreFilterWidgetState();
// }
//
// class _AdvancedStoreFilterWidgetState extends State<AdvancedStoreFilterWidget> {
//   late String _selectedStatus;
//   late String _selectedSortBy;
//   late String _selectedSortOrder;
//   late double _minRating;
//   late double _maxDistance;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeValues();
//   }
//
//   void _initializeValues() {
//     _selectedStatus = widget.controller.statusFilter.value;
//     _selectedSortBy = widget.controller.sortBy;
//     _selectedSortOrder = widget.controller.sortOrder;
//     _minRating = widget.controller.minRatingFilter.value;
//     _maxDistance = widget.controller.maxDistanceFilter.value;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.8,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildHeader(),
//           Flexible(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(AppDimensions.paddingLG),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSortSection(),
//                   const SizedBox(height: AppDimensions.spacingXL),
//                   _buildStatusFilterSection(),
//                   const SizedBox(height: AppDimensions.spacingXL),
//                   _buildRatingFilterSection(),
//                   if (widget.controller.hasLocation) ...[
//                     const SizedBox(height: AppDimensions.spacingXL),
//                     _buildDistanceFilterSection(),
//                   ],
//                   const SizedBox(height: AppDimensions.spacingXXL),
//                 ],
//               ),
//             ),
//           ),
//           _buildActionButtons(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.paddingLG),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: const BorderRadius.vertical(
//           top: Radius.circular(AppDimensions.radiusLG),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text('Filter & Sort', style: AppTextStyles.h5),
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.close),
//             style: IconButton.styleFrom(
//               backgroundColor: AppColors.background,
//               foregroundColor: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSortSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Sort By', style: AppTextStyles.h6),
//         const SizedBox(height: AppDimensions.spacingMD),
//         _buildSortOptions(),
//         const SizedBox(height: AppDimensions.spacingMD),
//         _buildSortOrderOptions(),
//       ],
//     );
//   }
//
//   Widget _buildSortOptions() {
//     final sortOptions = [
//       {'value': 'distance', 'label': 'Distance', 'icon': Icons.location_on},
//       {'value': 'rating', 'label': 'Rating', 'icon': Icons.star},
//       {'value': 'name', 'label': 'Name', 'icon': Icons.sort_by_alpha},
//       {'value': 'createdAt', 'label': 'Newest', 'icon': Icons.new_releases},
//     ];
//
//     return Wrap(
//       spacing: AppDimensions.spacingSM,
//       children: sortOptions.map((option) {
//         final isSelected = _selectedSortBy == option['value'];
//         // Disable distance if no location
//         final isEnabled =
//             option['value'] != 'distance' || widget.controller.hasLocation;
//
//         return ChoiceChip(
//           label: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 option['icon'] as IconData,
//                 size: 16,
//                 color: isSelected
//                     ? AppColors.surface
//                     : isEnabled
//                         ? AppColors.textSecondary
//                         : AppColors.disabled,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 option['label'] as String,
//                 style: AppTextStyles.labelMedium.copyWith(
//                   color: isSelected
//                       ? AppColors.surface
//                       : isEnabled
//                           ? AppColors.textPrimary
//                           : AppColors.disabled,
//                 ),
//               ),
//             ],
//           ),
//           selected: isSelected,
//           onSelected: isEnabled
//               ? (selected) {
//                   if (selected) {
//                     setState(() {
//                       _selectedSortBy = option['value'] as String;
//                     });
//                   }
//                 }
//               : null,
//           selectedColor: AppColors.primary,
//           backgroundColor: AppColors.background,
//           disabledColor: AppColors.disabled.withOpacity(0.1),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildSortOrderOptions() {
//     return Row(
//       children: [
//         Text(
//           'Order: ',
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: AppColors.textSecondary,
//           ),
//         ),
//         const SizedBox(width: AppDimensions.spacingSM),
//         ChoiceChip(
//           label: Text('Ascending', style: AppTextStyles.labelMedium),
//           selected: _selectedSortOrder == 'ASC',
//           onSelected: (selected) {
//             if (selected) {
//               setState(() {
//                 _selectedSortOrder = 'ASC';
//               });
//             }
//           },
//           selectedColor: AppColors.primary,
//           backgroundColor: AppColors.background,
//         ),
//         const SizedBox(width: AppDimensions.spacingSM),
//         ChoiceChip(
//           label: Text('Descending', style: AppTextStyles.labelMedium),
//           selected: _selectedSortOrder == 'DESC',
//           onSelected: (selected) {
//             if (selected) {
//               setState(() {
//                 _selectedSortOrder = 'DESC';
//               });
//             }
//           },
//           selectedColor: AppColors.primary,
//           backgroundColor: AppColors.background,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatusFilterSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Store Status', style: AppTextStyles.h6),
//         const SizedBox(height: AppDimensions.spacingMD),
//         Wrap(
//           spacing: AppDimensions.spacingSM,
//           children: [
//             ChoiceChip(
//               label: Text('All', style: AppTextStyles.labelMedium),
//               selected: _selectedStatus == 'all',
//               onSelected: (selected) {
//                 if (selected) {
//                   setState(() {
//                     _selectedStatus = 'all';
//                   });
//                 }
//               },
//               selectedColor: AppColors.primary,
//               backgroundColor: AppColors.background,
//             ),
//             ChoiceChip(
//               label: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 8,
//                     height: 8,
//                     decoration: const BoxDecoration(
//                       color: AppColors.success,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Text('Active Only', style: AppTextStyles.labelMedium),
//                 ],
//               ),
//               selected: _selectedStatus == 'active',
//               onSelected: (selected) {
//                 if (selected) {
//                   setState(() {
//                     _selectedStatus = 'active';
//                   });
//                 }
//               },
//               selectedColor: AppColors.primary,
//               backgroundColor: AppColors.background,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildRatingFilterSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Minimum Rating', style: AppTextStyles.h6),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppDimensions.paddingSM,
//                 vertical: AppDimensions.paddingXS,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.star, color: AppColors.rating, size: 16),
//                   const SizedBox(width: 4),
//                   Text(
//                     _minRating == 0 ? 'Any' : _minRating.toStringAsFixed(1),
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: AppColors.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: AppDimensions.spacingMD),
//         Slider(
//           value: _minRating,
//           min: 0,
//           max: 5,
//           divisions: 10,
//           activeColor: AppColors.primary,
//           inactiveColor: AppColors.primary.withOpacity(0.3),
//           onChanged: (value) {
//             setState(() {
//               _minRating = value;
//             });
//           },
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Any', style: AppTextStyles.labelSmall),
//             Text('5.0', style: AppTextStyles.labelSmall),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDistanceFilterSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Maximum Distance', style: AppTextStyles.h6),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppDimensions.paddingSM,
//                 vertical: AppDimensions.paddingXS,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.location_on,
//                       color: AppColors.primary, size: 16),
//                   const SizedBox(width: 4),
//                   Text(
//                     _maxDistance >= 50
//                         ? 'Any'
//                         : '${_maxDistance.toStringAsFixed(0)} km',
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: AppColors.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: AppDimensions.spacingMD),
//         Slider(
//           value: _maxDistance,
//           min: 1,
//           max: 50,
//           divisions: 49,
//           activeColor: AppColors.primary,
//           inactiveColor: AppColors.primary.withOpacity(0.3),
//           onChanged: (value) {
//             setState(() {
//               _maxDistance = value;
//             });
//           },
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('1 km', style: AppTextStyles.labelSmall),
//             Text('50+ km', style: AppTextStyles.labelSmall),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.paddingLG),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow,
//             blurRadius: 4,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton(
//               onPressed: _resetFilters,
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: AppColors.textSecondary,
//                 side: BorderSide(color: AppColors.border),
//                 padding: const EdgeInsets.symmetric(
//                   vertical: AppDimensions.paddingMD,
//                 ),
//               ),
//               child: const Text('Reset'),
//             ),
//           ),
//           const SizedBox(width: AppDimensions.spacingMD),
//           Expanded(
//             flex: 2,
//             child: ElevatedButton(
//               onPressed: _applyFilters,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: AppColors.surface,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: AppDimensions.paddingMD,
//                 ),
//               ),
//               child: const Text('Apply Filters'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _resetFilters() {
//     setState(() {
//       _selectedStatus = 'active';
//       _selectedSortBy = 'distance';
//       _selectedSortOrder = 'ASC';
//       _minRating = 0.0;
//       _maxDistance = 50.0;
//     });
//   }
//
//   void _applyFilters() {
//     widget.controller.applyFilters(
//       sortBy: _selectedSortBy,
//       sortOrder: _selectedSortOrder,
//       status: _selectedStatus == 'all' ? null : _selectedStatus,
//       minRating: _minRating > 0 ? _minRating : null,
//       maxDistance: _maxDistance < 50 ? _maxDistance : null,
//     );
//
//     Navigator.pop(context);
//
//     Get.snackbar(
//       'Filters Applied',
//       'Search results updated',
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 2),
//     );
//   }
// }
