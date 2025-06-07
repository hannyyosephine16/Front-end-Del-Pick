import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class UserProfileCard extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const UserProfileCard({
    super.key,
    this.showDetails = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser;
      if (user == null) return const SizedBox.shrink();

      return GestureDetector(
          onTap: onTap ?? () => Get.toNamed(Routes.PROFILE),
          child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                    backgroundImage:
                        user.avatar != null && user.avatar!.isNotEmpty
                            ? NetworkImage(user.avatar!)
                            : null,
                    child: user.avatar == null || user.avatar!.isEmpty
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    onDetailsPressed: () => Get.toNamed(Routes.PROFILE),
                  ),
                ],
              )));
    });
  }
}
