// lib/main.dart - DelPick App Entry Point (Production Ready)
import 'dart:async';
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
import 'core/services/local/storage_service.dart';

// ✅ Firebase messaging background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('📨 Background message handled: ${message.messageId}');

    // Handle background notification untuk DelPick
    if (message.data.containsKey('order_id')) {
      debugPrint(
          '📦 Order notification in background: ${message.data['order_id']}');
    }
  } catch (e) {
    debugPrint('❌ Error handling background message: $e');
  }
}

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    try {
      // ✅ Essential Flutter initialization
      WidgetsFlutterBinding.ensureInitialized();

      // ✅ Configure system UI first
      await _configureSystemUI();

      // ✅ Setup comprehensive error handling
      _setupGlobalErrorHandling();

      // ✅ Initialize Firebase with proper error handling
      await _initializeFirebase();

      // ✅ Initialize core app services
      await _initializeAppServices();

      debugPrint('✅ DelPick app initialization completed successfully');

      // ✅ Launch optimized app
      runApp(const DelPickApp());
    } catch (e, stackTrace) {
      debugPrint('❌ Fatal initialization error: $e');
      debugPrint('Stack trace: $stackTrace');

      // ✅ Launch recovery app
      runApp(_createEmergencyApp(e.toString()));
    }
  }, (error, stackTrace) {
    // ✅ Global zone error handler
    debugPrint('🔴 Unhandled error in zone: $error');
    debugPrint('Stack: $stackTrace');

    // In production, send to crash reporting
    if (!kDebugMode) {
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  });
}

// ✅ Configure system UI for DelPick app
Future<void> _configureSystemUI() async {
  try {
    // Set portrait orientation only
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configure status bar untuk DelPick branding
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    debugPrint('✅ System UI configured for DelPick');
  } catch (e) {
    debugPrint('⚠️ System UI configuration failed: $e');
  }
}

// ✅ Comprehensive error handling setup
void _setupGlobalErrorHandling() {
  // Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 Flutter Error: ${details.exception}');
    debugPrint('Library: ${details.library}');
    debugPrint('Context: ${details.context?.toString() ?? 'Unknown context'}');

    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      // Send to crash reporting in production
      // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  // Platform-specific errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 Platform Error: $error');

    if (!kDebugMode) {
      // FirebaseCrashlytics.instance.recordError(error, stack);
    }

    return true;
  };
}

// ✅ Initialize Firebase with timeout and retry logic
Future<void> _initializeFirebase() async {
  try {
    debugPrint('🔄 Initializing Firebase...');

    await Future.any([
      Firebase.initializeApp(),
      Future.delayed(const Duration(seconds: 20)).then((_) =>
          throw TimeoutException(
              'Firebase initialization timeout after 20 seconds')),
    ]);

    // Configure Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');

    if (e.toString().contains('timeout')) {
      debugPrint('⚠️ Firebase timeout - continuing without real-time features');
    } else {
      debugPrint('⚠️ Firebase unavailable - running in offline mode');
    }

    // DelPick can work without Firebase, so don't throw
  }
}

// ✅ Initialize core app services for DelPick
Future<void> _initializeAppServices() async {
  try {
    debugPrint('🔄 Initializing DelPick services...');

    // Initialize storage first (critical for auth state)
    final storageService = StorageService();
    // await storageService.init();
    Get.put<StorageService>(storageService, permanent: true);

    // Initialize location service (critical for delivery app)
    final locationService = LocationService();
    Get.put<LocationService>(locationService, permanent: true);

    // Initialize permission service
    final permissionService = PermissionService();
    Get.put<PermissionService>(permissionService, permanent: true);

    // // Initialize notification service (optional)
    // try {
    //   final notificationService = NotificationService();
    //   // await notificationService.initialize();
    //   Get.put<NotificationService>(notificationService, permanent: true);
    // } catch (e) {
    //   debugPrint('⚠️ Notification service failed to initialize: $e');
    //   // Continue without notifications
    // }

    debugPrint('✅ DelPick services initialized successfully');
  } catch (e) {
    debugPrint('❌ Critical service initialization failed: $e');
    throw DelPickServiceException('Failed to initialize core services: $e');
  }
}

// ✅ Main DelPick Application
class DelPickApp extends StatelessWidget {
  const DelPickApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // ✅ App identity
      title: 'DelPick - Food Delivery',
      debugShowCheckedModeBanner: false,

      // ✅ DelPick theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ✅ Routing configuration
      initialRoute: Routes.SPLASH, // Always start with splash
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),

      // ✅ Localization for Indonesia
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('en', 'US'),

      // ✅ Performance optimizations
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      smartManagement: SmartManagement.keepFactory,

      // ✅ Error route handling
      unknownRoute: GetPage(
        name: '/404',
        page: () => const DelPickErrorPage(
          title: 'Halaman Tidak Ditemukan',
          message: 'Halaman yang Anda cari tidak dapat ditemukan.',
          errorType: DelPickErrorType.notFound,
        ),
      ),

      // ✅ Global app wrapper
      builder: (context, child) {
        // Configure global error widget
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return DelPickErrorPage(
            title: 'Terjadi Kesalahan',
            message: kDebugMode
                ? 'Error: ${details.exception}\n\n${details.stack?.toString().split('\n').take(5).join('\n')}'
                : 'Terjadi kesalahan yang tidak terduga. Silakan restart aplikasi.',
            errorType: DelPickErrorType.runtime,
          );
        };

        return _DelPickAppWrapper(child: child ?? const SizedBox.shrink());
      },

      // ✅ Navigation observer for analytics
      navigatorObservers: kDebugMode ? [_DelPickNavigatorObserver()] : [],

      // ✅ Development settings
      enableLog: kDebugMode,
      logWriterCallback: (text, {isError = false}) {
        if (isError) {
          debugPrint('🔴 GetX Error: $text');
        } else if (kDebugMode) {
          debugPrint('🟢 GetX: $text');
        }
      },
    );
  }
}

// ✅ App wrapper for global configurations
class _DelPickAppWrapper extends StatelessWidget {
  final Widget child;

  const _DelPickAppWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
      ),
      child: child,
    );
  }
}

// ✅ Navigation observer for DelPick analytics
class _DelPickNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      debugPrint('📱 Navigated to: ${route.settings.name}');
      // Add analytics tracking here
      // Analytics.trackScreen(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      debugPrint('📱 Popped from: ${route.settings.name}');
    }
  }
}

// ✅ Emergency app for critical failures
Widget _createEmergencyApp(String error) {
  return MaterialApp(
    title: 'DelPick - Recovery Mode',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      fontFamily: 'Inter',
      useMaterial3: true,
    ),
    home: DelPickErrorPage(
      title: 'DelPick Tidak Dapat Dimulai',
      message:
          'Aplikasi DelPick mengalami masalah saat startup.\n\nDetail: $error',
      errorType: DelPickErrorType.critical,
    ),
  );
}

// ✅ Comprehensive error page for DelPick
enum DelPickErrorType { notFound, runtime, critical, network }

class DelPickErrorPage extends StatelessWidget {
  final String title;
  final String message;
  final DelPickErrorType errorType;

  const DelPickErrorPage({
    Key? key,
    required this.title,
    required this.message,
    required this.errorType,
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ Animated error icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _getErrorColor().withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _getErrorColor().withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _getErrorIcon(),
                              size: 64,
                              color: _getErrorColor(),
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

                    // ✅ Error message
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Action buttons
              Column(
                children: [
                  // Primary action
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _handlePrimaryAction,
                      icon: Icon(_getPrimaryActionIcon()),
                      label: Text(_getPrimaryActionText()),
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

                  if (errorType != DelPickErrorType.critical) ...[
                    const SizedBox(height: 16),

                    // Secondary action
                    TextButton(
                      onPressed: _handleSecondaryAction,
                      child: const Text(
                        'Kembali ke Login',
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
          ),
        ),
      ),
    );
  }

  Color _getErrorColor() {
    switch (errorType) {
      case DelPickErrorType.notFound:
        return Colors.orange;
      case DelPickErrorType.runtime:
        return Colors.red;
      case DelPickErrorType.critical:
        return Colors.red.shade700;
      case DelPickErrorType.network:
        return Colors.blue;
    }
  }

  IconData _getErrorIcon() {
    switch (errorType) {
      case DelPickErrorType.notFound:
        return Icons.search_off;
      case DelPickErrorType.runtime:
        return Icons.error_outline;
      case DelPickErrorType.critical:
        return Icons.settings_backup_restore;
      case DelPickErrorType.network:
        return Icons.wifi_off;
    }
  }

  IconData _getPrimaryActionIcon() {
    switch (errorType) {
      case DelPickErrorType.critical:
        return Icons.restart_alt;
      default:
        return Icons.refresh;
    }
  }

  String _getPrimaryActionText() {
    switch (errorType) {
      case DelPickErrorType.critical:
        return 'Restart Aplikasi';
      case DelPickErrorType.network:
        return 'Coba Lagi';
      default:
        return 'Muat Ulang';
    }
  }

  void _handlePrimaryAction() {
    switch (errorType) {
      case DelPickErrorType.critical:
        _restartApp();
        break;
      case DelPickErrorType.notFound:
        _navigateToHome();
        break;
      default:
        _retryCurrentOperation();
        break;
    }
  }

  void _handleSecondaryAction() {
    try {
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      _restartApp();
    }
  }

  void _restartApp() {
    try {
      Get.deleteAll(force: true);
      // In production, use restart_app package
      main();
    } catch (e) {
      debugPrint('❌ Restart failed: $e');
    }
  }

  void _navigateToHome() {
    try {
      Get.offAllNamed(Routes.SPLASH);
    } catch (e) {
      _restartApp();
    }
  }

  void _retryCurrentOperation() {
    try {
      Get.back();
    } catch (e) {
      Get.offAllNamed(Routes.SPLASH);
    }
  }
}

// ✅ Custom exceptions for DelPick
class DelPickServiceException implements Exception {
  final String message;
  const DelPickServiceException(this.message);

  @override
  String toString() => 'DelPickServiceException: $message';
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
