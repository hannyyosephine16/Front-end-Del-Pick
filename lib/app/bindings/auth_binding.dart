import 'package:get/get.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/data/providers/auth_provider.dart';
import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/features/auth/controllers/login_controller.dart';
import 'package:del_pick/features/auth/controllers/register_controller.dart';
import 'package:del_pick/features/auth/controllers/profile_controller.dart';
import 'package:del_pick/core/services/external/notification_service.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/services/api/api_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Pastikan core services sudah tersedia (dari InitialBinding)
    // Jika belum ada, daftarkan dengan fenix untuk bisa re-create
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService(), permanent: true);
    }
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.lazyPut<ConnectivityService>(() => ConnectivityService(),
          fenix: true);
    }
    if (!Get.isRegistered<NotificationService>()) {
      Get.lazyPut<NotificationService>(() => NotificationService(),
          fenix: true);
    }

    // ✅ Data sources - dalam urutan yang benar
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(Get.find<ApiService>()),
      fenix: true,
    );

    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSource(Get.find<StorageService>()),
      fenix: true,
    );

    // ✅ Provider - opsional, bisa skip jika tidak digunakan
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
      fenix: true,
    );

    // ✅ Repository - Sesuai dengan constructor AuthRepository
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        Get.find<AuthRemoteDataSource>(), // Parameter 1: _remoteDataSource
        Get.find<AuthLocalDataSource>(), // Parameter 2: _localDataSource
      ),
      fenix: true,
    );

    // ✅ AuthController - Sesuai dengan constructor yang ada (4 parameter)
    Get.lazyPut<AuthController>(
      () => AuthController(
        Get.find<AuthRepository>(), // Parameter 1: _authRepository
        // Get.find<NotificationService>(), // Parameter 2: _notificationService
        Get.find<ConnectivityService>(), // Parameter 3: _connectivityService
        Get.find<StorageService>(), // Parameter 4: _storageService
      ),
      fenix: true,
    );

    // ✅ Other Auth Controllers (sesuai dengan constructor masing-masing)
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<AuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<RegisterController>(
      () => RegisterController(Get.find<AuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<ProfileController>(
      () => ProfileController(),
      fenix: true,
    );
  }
}
