// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';
import 'core/services/external/notification_service.dart';
import 'core/services/external/location_service.dart';
import 'core/services/external/permission_service.dart';

// ✅ Firebase messaging background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}

void main() async {
  // ✅ Comprehensive error handling untuk initialization
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ Configure system UI untuk better performance
    await _configureSystemUI();

    // ✅ Setup global error handling sebelum app initialization
    _setupErrorHandling();

    // ✅ Initialize Firebase dengan timeout protection
    await _initializeFirebaseWithTimeout();

    // ✅ Initialize app services dengan timeout protection
    await _initializeServicesWithTimeout();

    debugPrint('✅ App initialization completed successfully');

    // ✅ Run optimized app
    runApp(const DelPickApp());
  } catch (e, stackTrace) {
    debugPrint('❌ Fatal error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    // ✅ Log to crash reporting service if available
    // FirebaseCrashlytics.instance.recordError(e, stackTrace);

    // ✅ Fallback: Run minimal recovery app
    runApp(_createRecoveryApp(e.toString()));
  }
}

// ✅ Configure system UI untuk better performance
Future<void> _configureSystemUI() async {
  try {
    // ✅ Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ✅ Configure system UI overlay
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // ✅ Enable edge-to-edge mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    debugPrint('✅ System UI configured successfully');
  } catch (e) {
    debugPrint('❌ Error configuring system UI: $e');
    // Don't throw, continue with app initialization
  }
}

// ✅ Global error handling
void _setupErrorHandling() {
  // ✅ Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Library: ${details.library}');
    debugPrint('Context: ${details.context}');

    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      // ✅ Log to crash reporting in release mode
      // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  // ✅ Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    debugPrint('Stack: $stack');

    if (!kDebugMode) {
      // ✅ Log to crash reporting in release mode
      // FirebaseCrashlytics.instance.recordError(error, stack);
    }

    return true; // Handled
  };
}

// ✅ Initialize Firebase dengan timeout protection
Future<void> _initializeFirebaseWithTimeout() async {
  try {
    await Future.any([
      Firebase.initializeApp(),
      Future.delayed(const Duration(seconds: 15)).then(
          (_) => throw TimeoutException('Firebase initialization timeout')),
    ]);

    // Set Firebase messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');

    if (e.toString().contains('timeout')) {
      throw Exception(
          'Firebase initialization timed out. Please check your internet connection.');
    }

    // For DelPick, Firebase is not critical, so we can continue without it
    debugPrint('⚠️ Continuing without Firebase services');
  }
}

// ✅ Initialize app services dengan timeout protection
Future<void> _initializeServicesWithTimeout() async {
  try {
    await Future.any([
      _initializeServices(),
      Future.delayed(const Duration(seconds: 15)).then(
          (_) => throw TimeoutException('Services initialization timeout')),
    ]);

    debugPrint('✅ Services initialized successfully');
  } catch (e) {
    debugPrint('❌ Services initialization error: $e');

    if (e.toString().contains('timeout')) {
      throw Exception(
          'Services initialization timed out. Please restart the app.');
    }
    rethrow;
  }
}

// ✅ Initialize core services
Future<void> _initializeServices() async {
  try {
    // Initialize notification service
    // Get.put(NotificationService(), permanent: true);
    // await Get.find<NotificationService>().initialize();

    // Initialize location service
    Get.put(LocationService(), permanent: true);

    // Initialize permission service
    Get.put(PermissionService(), permanent: true);

    debugPrint('✅ Core services initialized');
  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
    throw Exception('Failed to initialize core services: $e');
  }
}

// ✅ Main app class dengan comprehensive error handling
class DelPickApp extends StatelessWidget {
  const DelPickApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DelPick',
      debugShowCheckedModeBanner: false,

      // ✅ Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ✅ Routes
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,

      // ✅ Initial binding
      initialBinding: InitialBinding(),

      // ✅ Localization
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('en', 'US'),

      // ✅ Performance optimizations
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),

      // ✅ Memory management
      smartManagement: SmartManagement.keepFactory,

      // ✅ Unknown route handling
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => const _ErrorPage(
          title: 'Halaman Tidak Ditemukan',
          message: 'Halaman yang Anda cari tidak dapat ditemukan.',
          showRetryButton: false,
        ),
      ),

      // ✅ Global app builder dengan error handling
      builder: (context, child) {
        // ✅ Configure global error widget
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _ErrorPage(
            title: 'Terjadi Kesalahan',
            message: kDebugMode
                ? '${details.exception}\n\n${details.stack?.toString().split('\n').take(3).join('\n')}'
                : 'Terjadi kesalahan yang tidak terduga. Silakan restart aplikasi.',
            showRetryButton: true,
          );
        };

        // ✅ Wrap dengan MediaQuery untuk responsive design
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor:
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      // ✅ Global navigation observer untuk debugging
      navigatorObservers: kDebugMode ? [_CustomNavigatorObserver()] : [],

      // ✅ Enable logging
      enableLog: kDebugMode,
    );
  }
}

// ✅ Navigation observer untuk debugging
class _CustomNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('🔄 Navigated to: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('🔙 Popped from: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint(
        '🔄 Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }
}

// ✅ Recovery app untuk emergency cases
Widget _createRecoveryApp(String errorMessage) {
  return MaterialApp(
    title: 'DelPick - Recovery',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      fontFamily: 'Inter',
    ),
    home: _ErrorPage(
      title: 'Gagal Memulai Aplikasi',
      message: 'DelPick gagal dimulai dengan benar.\n\nError: $errorMessage',
      showRetryButton: true,
      isRecoveryMode: true,
    ),
  );
}

// ✅ Comprehensive error page widget
class _ErrorPage extends StatelessWidget {
  final String title;
  final String message;
  final bool showRetryButton;
  final bool isRecoveryMode;

  const _ErrorPage({
    Key? key,
    required this.title,
    required this.message,
    this.showRetryButton = true,
    this.isRecoveryMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // ✅ Error illustration
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ Error icon dengan animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                isRecoveryMode
                                    ? Icons.settings_backup_restore
                                    : Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade600,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // ✅ Error title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // ✅ Error message dengan scrollable container
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ Action buttons
              if (showRetryButton) ...[
                const SizedBox(height: 32),
                Column(
                  children: [
                    // ✅ Primary action button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleRetryAction(),
                        icon: const Icon(Icons.refresh),
                        label:
                            Text(isRecoveryMode ? 'Restart App' : 'Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D3E),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ Secondary action button
                    if (!isRecoveryMode) ...[
                      TextButton(
                        onPressed: () => _handleNavigateToSafeScreen(),
                        child: const Text(
                          'Ke Halaman Login',
                          style: TextStyle(
                            color: Color(0xFF2E7D3E),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // ✅ Debug info untuk development
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Debug Mode',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => _showDebugInfo(),
                      child: const Text('Show Logs'),
                    ),
                    TextButton(
                      onPressed: () => _copyErrorToClipboard(),
                      child: const Text('Copy Error'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleRetryAction() {
    if (isRecoveryMode) {
      // ✅ Force restart aplikasi
      _restartApp();
    } else {
      // ✅ Try to navigate back atau retry operation
      try {
        if (Get.isRegistered<GetxController>()) {
          Get.offAllNamed(Routes.SPLASH);
        } else {
          _restartApp();
        }
      } catch (e) {
        _restartApp();
      }
    }
  }

  void _handleNavigateToSafeScreen() {
    try {
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      _restartApp();
    }
  }

  void _restartApp() {
    // ✅ In a real app, you might use restart_app package
    // For now, we'll try to reinitialize
    try {
      Get.deleteAll(force: true);
      main();
    } catch (e) {
      debugPrint('❌ Failed to restart app: $e');
    }
  }

  void _showDebugInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDebugRow('Platform', defaultTargetPlatform.name),
              _buildDebugRow('Error', title),
              _buildDebugRow('Message', message),
              _buildDebugRow('Recovery Mode', isRecoveryMode.toString()),
              _buildDebugRow(
                  'GetX Ready', Get.isRegistered<GetxController>().toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _copyErrorToClipboard() {
    final errorText =
        'Title: $title\nMessage: $message\nRecovery Mode: $isRecoveryMode';
    Clipboard.setData(ClipboardData(text: errorText));

    if (Get.isRegistered<GetxController>()) {
      Get.snackbar(
        'Tersalin',
        'Informasi error berhasil disalin ke clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

// ✅ Exception classes untuk better error handling
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
