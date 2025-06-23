// lib/app/bindings/initial_binding.dart - FIXED VERSION
import 'package:get/get.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/services/local/cache_service.dart';
import 'package:del_pick/core/services/local/database_service.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/core/services/external/notification_service.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/services/external/permission_service.dart';
import 'package:del_pick/features/shared/controllers/navigation_controller.dart';
import 'package:del_pick/features/shared/controllers/theme_controller.dart';
import 'package:del_pick/features/shared/controllers/language_controller.dart';
import 'package:del_pick/features/shared/controllers/notification_controller.dart';
import 'package:del_pick/features/shared/controllers/connectivity_controller.dart';

import '../../core/services/api/auth_service.dart';
import '../../features/shared/controllers/splash_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.lazyPut(() => AuthApiService(Get.find()), fenix: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);

    Get.lazyPut<CacheService>(() => CacheService(), fenix: true);
    Get.lazyPut<DatabaseService>(() => DatabaseService(), fenix: true);
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);
    Get.lazyPut<PermissionService>(() => PermissionService(), fenix: true);
    Get.lazyPut<SplashController>(() => SplashController());
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(),
        fenix: true);
    Get.lazyPut<ConnectivityController>(() => ConnectivityController(),
        fenix: true);
  }
}
