// lib/features/customer/widgets/order_filter_tabs.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class OrderFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final List<Map<String, dynamic>> filterOptions;
  final Function(String) onFilterChanged;
  final Map<String, int> orderCounts;

  const OrderFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onFilterChanged,
    required this.orderCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        separatorBuilder: (context, index) => const SizedBox(
          width: AppDimensions.spacingSM,
        ),
        itemBuilder: (context, index) {
          final option = filterOptions[index];
          final isSelected = selectedFilter == option['key'];
          final count = orderCounts[option['key']] ?? 0;

          return _buildFilterTab(
            label: option['label'],
            icon: option['icon'],
            isSelected: isSelected,
            count: count,
            onTap: () => onFilterChanged(option['key']),
          );
        },
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
          vertical: AppDimensions.paddingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.primaryLight,
            ),
            const SizedBox(width: AppDimensions.spacingXS),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: AppDimensions.spacingXS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                ),
                child: Text(
                  count.toString(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
