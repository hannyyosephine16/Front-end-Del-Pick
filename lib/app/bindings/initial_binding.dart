// lib/app/bindings/initial_binding.dart
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
import 'package:get/get.dart';
import '../../core/services/api/api_service.dart';
import '../../core/services/api/base_api_service.dart';
import '../../core/services/api/auth_service.dart';
import '../../core/services/external/connectivity_service.dart';
import '../../core/services/external/notification_service.dart';
import '../../core/services/external/location_service.dart';
import '../../core/services/external/permission_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/shared/controllers/connectivity_controller.dart';
import '../../features/shared/controllers/notification_controller.dart';
// import '../../features/shared/controllers/location_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);

    // External services
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<LocationService>(LocationService(), permanent: true);
    Get.put<PermissionService>(PermissionService(), permanent: true);

    // Repositories
    Get.put<AuthRepository>(AuthRepository(Get.find<AuthService>())
        // Get.find<AuthRemoteDataSource>(), Get.find<AuthLocalDataSource>()),
        // permanent: true,
        );

    // Controllers
    Get.put<AuthController>(
        AuthController(Get.find<AuthRepository>(),
            Get.find<ConnectivityService>(), Get.find<StorageService>()),
        permanent: true);
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
    // Get.put<LocationController>(LocationController(), permanent: true);
  }
}
