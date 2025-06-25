// 1. lib/features/shared/views/splash_view.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/widgets/loading_widget.dart';
import 'package:del_pick/features/shared/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'DelPick',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // App Name and Tagline
              Text(
                'DelPick',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Delivery Made Simple',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 80),

              // Loading Animation
              Obx(() => AnimatedOpacity(
                    opacity: controller.isLoading.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        // Fixed LoadingWidget without parameters
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.loadingText.value,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 100),

              // Version Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Version 1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
