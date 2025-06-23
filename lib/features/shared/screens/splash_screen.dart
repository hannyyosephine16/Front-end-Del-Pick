// lib/features/shared/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/features/shared/controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delivery_dining,
              size: 120,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'DelPick',
              style: AppTextStyles.h1.copyWith(color: AppColors.textOnPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Food Delivery App',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: AppColors.textOnPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
