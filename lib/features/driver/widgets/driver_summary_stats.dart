// lib/features/driver/widgets/driver_summary_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class DriverSummaryStatsWidget extends StatelessWidget {
  final List<StatItem> stats;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isCompact;

  const DriverSummaryStatsWidget({
    super.key,
    required this.stats,
    this.onTap,
    this.margin,
    this.padding,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppDimensions.paddingLG),
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Padding(
            padding: isCompact
                ? const EdgeInsets.all(AppDimensions.paddingSM)
                : const EdgeInsets.all(AppDimensions.paddingMD),
            child: _buildStatsGrid(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (stats.length <= 2) {
      return Row(
        children: stats
            .map((stat) => Expanded(child: _buildStatItem(stat)))
            .expand((widget) => [
                  widget,
                  if (stats.indexOf(widget.child as StatItem) <
                      stats.length - 1)
                    const SizedBox(width: AppDimensions.spacingMD)
                ])
            .toList(),
      );
    } else {
      // For more than 2 stats, use 2x2 grid
      final firstRow = stats.take(2).toList();
      final secondRow = stats.skip(2).take(2).toList();

      return Column(
        children: [
          Row(
            children: firstRow
                .map((stat) => Expanded(child: _buildStatItem(stat)))
                .expand((widget) => [
                      widget,
                      if (firstRow.indexOf(widget.child as StatItem) <
                          firstRow.length - 1)
                        const SizedBox(width: AppDimensions.spacingMD)
                    ])
                .toList(),
          ),
          if (secondRow.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            Row(
              children: secondRow
                  .map((stat) => Expanded(child: _buildStatItem(stat)))
                  .expand((widget) => [
                        widget,
                        if (secondRow.indexOf(widget.child as StatItem) <
                            secondRow.length - 1)
                          const SizedBox(width: AppDimensions.spacingMD)
                      ])
                  .toList(),
            ),
          ],
        ],
      );
    }
  }

  Widget _buildStatItem(StatItem stat) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSM),
          decoration: BoxDecoration(
            color: stat.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            stat.icon,
            color: stat.color,
            size: isCompact ? 20 : 24,
          ),
        ),
        SizedBox(
            height:
                isCompact ? AppDimensions.spacingXS : AppDimensions.spacingSM),
        Text(
          stat.value,
          style:
              (isCompact ? AppTextStyles.bodyLarge : AppTextStyles.h6).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class StatItem {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
}
