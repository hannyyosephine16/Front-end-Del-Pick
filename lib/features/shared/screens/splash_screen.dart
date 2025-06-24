// // lib/features/shared/controllers/splash_controller.dart
// import 'package:get/get.dart';
// import 'package:del_pick/core/services/local/storage_service.dart';
// import 'package:del_pick/core/constants/storage_constants.dart';
// import 'package:del_pick/app/routes/app_routes.dart';
//
// class SplashController extends GetxController {
//   final StorageService _storageService = Get.find<StorageService>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeApp();
//   }
//
//   Future<void> _initializeApp() async {
//     try {
//       // Tunggu 2 detik untuk splash animation
//       await Future.delayed(const Duration(seconds: 2));
//
//       // Check authentication status
//       await _checkAuthenticationStatus();
//     } catch (e) {
//       print('Error initializing app: $e');
//       // Jika ada error, arahkan ke login
//       Get.offAllNamed(Routes.LOGIN);
//     }
//   }
//
//   Future<void> _checkAuthenticationStatus() async {
//     try {
//       // Cek apakah user sudah login
//       final isLoggedIn = _storageService.readBoolWithDefault(
//           StorageConstants.isLoggedIn, false);
//
//       final token = _storageService.readString(StorageConstants.authToken);
//
//       if (isLoggedIn && token != null && token.isNotEmpty) {
//         // User sudah login, arahkan berdasarkan role
//         _navigateBasedOnRole();
//       } else {
//         // User belum login, arahkan ke login
//         Get.offAllNamed(Routes.LOGIN);
//       }
//     } catch (e) {
//       print('Error checking auth status: $e');
//       Get.offAllNamed(Routes.LOGIN);
//     }
//   }
//
//   void _navigateBasedOnRole() {
//     final userRole = _storageService.readString(StorageConstants.userRole);
//
//     switch (userRole) {
//       case 'customer':
//         Get.offAllNamed(Routes.CUSTOMER_HOME);
//         break;
//       case 'driver':
//         Get.offAllNamed(Routes.DRIVER_MAIN);
//         break;
//       case 'store':
//         Get.offAllNamed(Routes.STORE_DASHBOARD);
//         break;
//       default:
//         Get.offAllNamed(Routes.LOGIN);
//     }
//   }
// }
// lib/features/shared/screens/splash_screen.dart
// lib/features/shared/screens/splash_screen.dart - ENHANCED untuk struktur existing
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:del_pick/features/shared/controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  late SplashController _controller;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // ✅ Initialize controller dengan proper lifecycle
    _controller = Get.put(SplashController());
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // ✅ Logo animations
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // ✅ Text animations
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimationSequence() async {
    // ✅ Start logo animation immediately
    _logoAnimationController.forward();

    // ✅ Start text animation after delay
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _textAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2), // Primary blue
              Color(0xFF1565C0), // Darker blue
              Color(0xFF0D47A1), // Deep blue
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ Main content area
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ Animated logo dengan RepaintBoundary untuk performance
                      RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _logoAnimationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: ScaleTransition(
                                scale: _logoScaleAnimation,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.1),
                                        blurRadius: 16,
                                        offset: const Offset(0, -8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.delivery_dining,
                                    size: 68,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ✅ Animated app name
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: const Text(
                            'DelPick',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ✅ Animated tagline
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: const Text(
                            'Food Delivery App',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ Loading section
              Expanded(
                flex: 1,
                child: Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✅ Loading progress bar
                        Container(
                          width: 200,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _controller.loadingProgress.value,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ✅ Loading message
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _controller.loadingMessage.value,
                            key: ValueKey(_controller.loadingMessage.value),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ✅ Loading spinner
                        if (_controller.isLoading.value)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    )),
              ),

              // ✅ Bottom section dengan emergency controls (debug mode only)
              if (kDebugMode) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ Debug info
                      Obx(() => Text(
                            'Progress: ${(_controller.loadingProgress.value * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          )),

                      const SizedBox(height: 8),

                      // ✅ Emergency buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => _controller.forceNavigateToLogin(),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _controller.retryInitialization(),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // ✅ Show debug info
                              final info = _controller.getStorageInfo();
                              Get.snackbar(
                                'Debug Info',
                                'Storage: ${info['storageSize']} items\nRole: ${info['userRole'] ?? 'None'}',
                                backgroundColor: Colors.black54,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                              );
                            },
                            child: const Text(
                              'Info',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
