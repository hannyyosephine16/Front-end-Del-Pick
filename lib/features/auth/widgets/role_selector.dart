// lib/features/auth/widgets/role_selector.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleSelected;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildRoleChip(AppConstants.roleCustomer, 'Customer'),
        ),
        const SizedBox(width: AppDimensions.spacingSM),
        Expanded(
          child: _buildRoleChip(AppConstants.roleDriver, 'Driver'),
        ),
        const SizedBox(width: AppDimensions.spacingSM),
        Expanded(
          child: _buildRoleChip(AppConstants.roleStore, 'Store'),
        ),
      ],
    );
  }

  Widget _buildRoleChip(String value, String label) {
    final isSelected = selectedRole == value;
    return GestureDetector(
      onTap: () => onRoleSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color:
                isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
