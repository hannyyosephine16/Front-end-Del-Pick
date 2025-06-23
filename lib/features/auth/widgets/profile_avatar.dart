// lib/features/auth/widgets/profile_avatar.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String role;
  final double size;
  final bool showEditButton;
  final VoidCallback? onEditPressed;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.role,
    this.size = 100,
    this.showEditButton = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      _getRoleIcon(role),
                      size: size * 0.5,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  _getRoleIcon(role),
                  size: size * 0.5,
                  color: AppColors.primary,
                ),
        ),
        if (showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  size: size * 0.18,
                  color: AppColors.textOnPrimary,
                ),
                onPressed: onEditPressed,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        return Icons.person;
      case AppConstants.roleDriver:
        return Icons.delivery_dining;
      case AppConstants.roleStore:
        return Icons.store;
      default:
        return Icons.person;
    }
  }
}
