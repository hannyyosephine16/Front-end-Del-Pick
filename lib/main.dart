// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/app/config/app_config.dart';
// import 'package:del_pick/app/themes/app_theme.dart';
// import 'package:del_pick/app/routes/app_pages.dart';
// import 'package:del_pick/app/bindings/initial_binding.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize app configuration
//   await AppConfig.initialize();
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'DelPick',
//       debugShowCheckedModeBanner: false,
//
//       // Theme
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//
//       // Routes
//       initialRoute: AppPages.INITIAL,
//       getPages: AppPages.routes,
//
//       // Initial Binding
//       initialBinding: InitialBinding(),
//
//       // Locale
//       locale: const Locale('id', 'ID'),
//       fallbackLocale: const Locale('en', 'US'),
//     );
//   }
// }
// lib/main.dart - FIXED ERRORS
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/config/app_config.dart';
import 'package:del_pick/app/themes/app_theme.dart';
import 'package:del_pick/app/routes/app_pages.dart';
import 'package:del_pick/app/bindings/initial_binding.dart';
import 'package:del_pick/core/services/local/storage_service.dart';

void main() async {
  // ✅ OPTIMIZED: Comprehensive error handling untuk initialization
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ OPTIMIZED: Configure system UI untuk better performance
    await _configureSystemUI();

    // ✅ OPTIMIZED: Setup global error handling sebelum app initialization
    _setupErrorHandling();

    // ✅ OPTIMIZED: Initialize app configuration dengan timeout protection
    await _initializeAppWithTimeout();

    // ✅ OPTIMIZED: Run optimized app
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

// ✅ OPTIMIZED: Configure system UI untuk better performance
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
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    debugPrint('✅ System UI configured successfully');
  } catch (e) {
    debugPrint('❌ Error configuring system UI: $e');
    // Don't throw, continue with app initialization
  }
}

// ✅ OPTIMIZED: Global error handling
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

// ✅ OPTIMIZED: Initialize app dengan timeout protection
Future<void> _initializeAppWithTimeout() async {
  try {
    await Future.any([
      AppConfig.initialize(),
      Future.delayed(const Duration(seconds: 30))
          .then((_) => throw TimeoutException('App initialization timeout')),
    ]);

    debugPrint('✅ App configuration initialized successfully');
  } catch (e) {
    debugPrint('❌ App initialization error: $e');

    if (e.toString().contains('timeout')) {
      throw Exception('App initialization timed out. Please restart the app.');
    }
    rethrow;
  }
}

// ✅ OPTIMIZED: Main app class dengan comprehensive error handling
class DelPickApp extends StatelessWidget {
  const DelPickApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DelPick',
      debugShowCheckedModeBanner: false,

      // ✅ OPTIMIZED: Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ✅ OPTIMIZED: Routes
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // ✅ OPTIMIZED: Initial binding
      initialBinding: InitialBinding(),

      // ✅ OPTIMIZED: Localization
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('en', 'US'),

      // ✅ OPTIMIZED: Performance optimizations
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),

      // ✅ OPTIMIZED: Memory management
      smartManagement: SmartManagement.keepFactory,

      // ✅ OPTIMIZED: Unknown route handling
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => const _ErrorPage(
          title: 'Page Not Found',
          message: 'The requested page could not be found.',
          showRetryButton: false,
        ),
      ),

      // ✅ OPTIMIZED: Global app builder dengan error handling
      builder: (context, child) {
        // ✅ Configure global error widget
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _ErrorPage(
            title: 'Something went wrong',
            message: kDebugMode
                ? '${details.exception}\n\n${details.stack?.toString().split('\n').take(3).join('\n')}'
                : 'An unexpected error occurred. Please restart the app.',
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

      // ✅ OPTIMIZED: Global navigation observer untuk debugging
      navigatorObservers: kDebugMode
          ? [
              _CustomNavigatorObserver(),
            ]
          : [],
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

// ✅ OPTIMIZED: Recovery app untuk emergency cases
Widget _createRecoveryApp(String errorMessage) {
  return MaterialApp(
    title: 'DelPick - Recovery',
    debugShowCheckedModeBanner: false,
    home: _ErrorPage(
      title: 'App Initialization Failed',
      message: 'Failed to start DelPick properly.\n\nError: $errorMessage',
      showRetryButton: true,
      isRecoveryMode: true,
    ),
  );
}

// ✅ OPTIMIZED: Comprehensive error page widget
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
                            Text(isRecoveryMode ? 'Restart App' : 'Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ Secondary action button untuk recovery mode
                    if (isRecoveryMode) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleClearDataAction(),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Clear App Data'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // ✅ Normal mode - navigate to safe screen
                      TextButton(
                        onPressed: () => _handleNavigateToSafeScreen(),
                        child: const Text(
                          'Go to Login',
                          style: TextStyle(
                            color: Color(0xFF1976D2),
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
        Get.offAllNamed('/splash');
      } catch (e) {
        _restartApp();
      }
    }
  }

  void _handleClearDataAction() {
    // ✅ Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
          'This will remove all stored data including login information. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _clearAppDataAndRestart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear & Restart'),
          ),
        ],
      ),
    );
  }

  void _handleNavigateToSafeScreen() {
    try {
      Get.offAllNamed('/login');
    } catch (e) {
      _restartApp();
    }
  }

  void _restartApp() {
    // ✅ In a real app, you might use restart_app package
    // For now, we'll try to reinitialize
    try {
      main();
    } catch (e) {
      debugPrint('❌ Failed to restart app: $e');
    }
  }

  Future<void> _clearAppDataAndRestart() async {
    try {
      // ✅ Clear storage if available
      try {
        final storage = Get.find<StorageService>();
        await storage.clearAll();
      } catch (e) {
        debugPrint('Storage service not available: $e');
      }

      // ✅ Clear GetX services
      Get.deleteAll(force: true);

      // ✅ Restart app
      _restartApp();
    } catch (e) {
      debugPrint('❌ Failed to clear data: $e');
      _restartApp();
    }
  }

  void _showDebugInfo() {
    // ✅ FIXED: Get registered services count safely
    int servicesCount = 0;
    try {
      // Try to access GetX internal data safely
      servicesCount = Get.isRegistered<StorageService>() ? 1 : 0;
    } catch (e) {
      servicesCount = 0;
    }

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
              _buildDebugRow('Services', servicesCount.toString()),
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

    Get.snackbar(
      'Copied',
      'Error information copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

// ✅ Exception classes untuk better error handling
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
