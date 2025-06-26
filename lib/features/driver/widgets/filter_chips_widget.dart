// lib/features/driver/widgets/filter_chips_widget.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filters;
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final double height;
  final bool showIcons;

  const FilterChipsWidget({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.height = 60,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSM),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
        ),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['key'];

          return Container(
            margin: const EdgeInsets.only(right: AppDimensions.spacingSM),
            child: FilterChip(
              label: showIcons
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (filter['icon'] != null) ...[
                          Icon(
                            filter['icon'] as IconData,
                            size: 16,
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          filter['label']! as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      filter['label']! as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(filter['key']! as String),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              elevation: isSelected ? 4 : 0,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }
}
