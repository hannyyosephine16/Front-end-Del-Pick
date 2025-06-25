// lib/features/shared/screens/onboarding_screen.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';
import 'package:del_pick/core/widgets/custom_button.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final StorageService _storageService = Get.find<StorageService>();

  int _currentPage = 0;

  // ✅ Onboarding data sesuai dengan backend (customer, driver, store)
  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      title: 'Selamat Datang di DelPick',
      subtitle: 'Platform delivery terpercaya untuk semua kebutuhan Anda',
      description:
          'Nikmati kemudahan memesan makanan, menggunakan jasa kurir, dan mengelola toko dalam satu aplikasi.',
      icon: Icons.delivery_dining,
      color: AppColors.primary,
    ),
    OnboardingData(
      title: 'Untuk Customer',
      subtitle: 'Pesan makanan favorit dengan mudah',
      description:
          'Jelajahi berbagai toko, pilih menu favorit, dan nikmati pengiriman cepat langsung ke lokasi Anda.',
      icon: Icons.restaurant_menu,
      color: Colors.orange,
    ),
    OnboardingData(
      title: 'Untuk Driver',
      subtitle: 'Bergabung sebagai mitra driver',
      description:
          'Dapatkan penghasilan tambahan dengan menjadi driver DelPick. Atur jadwal kerja Anda sendiri.',
      icon: Icons.two_wheeler,
      color: Colors.blue,
    ),
    OnboardingData(
      title: 'Untuk Store',
      subtitle: 'Kembangkan bisnis kuliner Anda',
      description:
          'Daftarkan toko Anda, kelola menu, dan jangkau lebih banyak pelanggan melalui platform kami.',
      icon: Icons.store,
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  // ✅ FIXED: Complete onboarding and navigate to login
  Future<void> _completeOnboarding() async {
    try {
      // Mark onboarding as completed
      await _storageService.writeBool(StorageConstants.hasSeenOnboarding, true);
      await _storageService.writeBool(StorageConstants.isFirstTime, false);

      print('Onboarding completed, navigating to login');

      // Navigate to login screen
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('Error completing onboarding: $e');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: AppDimensions.spacingSM),
                      Text(
                        'DelPick',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Skip button
                  if (_currentPage < _onboardingPages.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Lewati',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = _onboardingPages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 80,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXXL),

                        // Title
                        Text(
                          page.title,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.spacingMD),

                        // Subtitle
                        Text(
                          page.subtitle,
                          style: AppTextStyles.h6.copyWith(
                            color: page.color,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.spacingLG),

                        // Description
                        Text(
                          page.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingPages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingXS,
                        ),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),

                  // Next/Get Started button
                  CustomButton.primary(
                    text: _currentPage == _onboardingPages.length - 1
                        ? 'Mulai'
                        : 'Selanjutnya',
                    onPressed: _nextPage,
                    isExpanded: true,
                  ),
                  const SizedBox(height: AppDimensions.spacingMD),

                  // Progress text
                  Text(
                    '${_currentPage + 1} dari ${_onboardingPages.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Data model untuk onboarding
class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
