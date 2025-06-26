// lib/main.dart - DelPick App Entry Point (Completely Clean - No Firebase)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';
import 'core/services/local/storage_service.dart';
import 'core/services/external/location_service.dart';
import 'core/services/external/permission_service.dart';

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    try {
      // ✅ Essential Flutter initialization
      WidgetsFlutterBinding.ensureInitialized();

      // ✅ Configure system UI
      await _configureSystemUI();

      // ✅ Setup error handling
      _setupGlobalErrorHandling();

      // ✅ Initialize only core services (NO FIREBASE)
      await _initializeCoreServices();

      debugPrint('✅ DelPick app initialized successfully');

      // ✅ Launch app
      runApp(const DelPickApp());
    } catch (e, stackTrace) {
      debugPrint('❌ Fatal initialization error: $e');
      debugPrint('Stack trace: $stackTrace');

      // ✅ Launch recovery app
      runApp(_createEmergencyApp(e.toString()));
    }
  }, (error, stackTrace) {
    debugPrint('🔴 Unhandled error: $error');
    if (kDebugMode) {
      debugPrint('Stack: $stackTrace');
    }
  });
}

// ✅ Configure system UI
Future<void> _configureSystemUI() async {
  try {
    // Set portrait orientation only
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configure status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    debugPrint('✅ System UI configured');
  } catch (e) {
    debugPrint('⚠️ System UI configuration failed: $e');
  }
}

// ✅ Setup error handling
void _setupGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 Flutter Error: ${details.exception}');
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 Platform Error: $error');
    return true;
  };
}

// ✅ Initialize ONLY core services (NO FIREBASE)
Future<void> _initializeCoreServices() async {
  try {
    debugPrint('🔄 Initializing core services...');

    // Storage service - critical for app
    final storageService = StorageService();
    Get.put<StorageService>(storageService, permanent: true);

    // Location service - needed for delivery
    final locationService = LocationService();
    Get.put<LocationService>(locationService, permanent: true);

    // Permission service
    final permissionService = PermissionService();
    Get.put<PermissionService>(permissionService, permanent: true);

    debugPrint('✅ Core services initialized');
  } catch (e) {
    debugPrint('❌ Service initialization failed: $e');
    rethrow;
  }
}

// ✅ Main DelPick Application
class DelPickApp extends StatelessWidget {
  const DelPickApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DelPick - Food Delivery',
      debugShowCheckedModeBanner: false,

      // ✅ Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ✅ Navigation: Splash → Onboarding → Login → Home
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),

      // ✅ Localization
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('en', 'US'),

      // ✅ Performance
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      smartManagement: SmartManagement.keepFactory,

      // ✅ Error handling
      unknownRoute: GetPage(
        name: '/404',
        page: () => const DelPickErrorPage(
          title: 'Halaman Tidak Ditemukan',
          message: 'Halaman yang Anda cari tidak dapat ditemukan.',
        ),
      ),

      // ✅ Global wrapper
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return DelPickErrorPage(
            title: 'Terjadi Kesalahan',
            message: kDebugMode
                ? 'Error: ${details.exception}'
                : 'Terjadi kesalahan. Silakan restart aplikasi.',
          );
        };

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor:
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      // ✅ Debug settings
      enableLog: kDebugMode,
      logWriterCallback: kDebugMode
          ? (text, {isError = false}) {
              debugPrint(isError ? '🔴 GetX: $text' : '🟢 GetX: $text');
            }
          : null,
    );
  }
}

// ✅ Emergency app for critical failures
Widget _createEmergencyApp(String error) {
  return MaterialApp(
    title: 'DelPick - Recovery',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      useMaterial3: true,
    ),
    home: DelPickErrorPage(
      title: 'DelPick Tidak Dapat Dimulai',
      message: 'Aplikasi mengalami masalah saat startup.\n\n$error',
    ),
  );
}

// ✅ Simple error page
class DelPickErrorPage extends StatelessWidget {
  final String title;
  final String message;

  const DelPickErrorPage({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Error icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 32),

              // ✅ Title
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

              // ✅ Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // ✅ Restart button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    try {
                      Get.deleteAll(force: true);
                      main();
                    } catch (e) {
                      debugPrint('❌ Restart failed: $e');
                    }
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart Aplikasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
