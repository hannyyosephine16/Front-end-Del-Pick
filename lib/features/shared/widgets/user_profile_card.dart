import 'package:flutter/material.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class UserProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsPressed;

  const UserProfileCard({
    super.key,
    required this.user,
    this.onTap,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppDimensions.marginMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: _getRoleColor(user.role),
                backgroundImage:
                    user.avatar != null ? NetworkImage(user.avatar!) : null,
                child: user.avatar == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.spacingLG),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.h6,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      user.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSM,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getRoleColor(user.role),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details Button
              if (onDetailsPressed != null)
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: onDetailsPressed,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'store':
        return AppColors.secondary;
      case 'driver':
        return AppColors.accent;
      case 'customer':
      default:
        return AppColors.primary;
    }
  }
}
