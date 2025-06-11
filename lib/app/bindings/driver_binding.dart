// lib/app/bindings/driver_binding.dart - FIXED VERSION
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/tracking_repository.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/providers/tracking_provider.dart';
import 'package:del_pick/data/providers/driver_provider.dart';
import 'package:del_pick/data/providers/order_provider.dart';
import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/data/datasources/remote/order_remote_datasource.dart';
import 'package:del_pick/data/datasources/remote/tracking_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/features/driver/controllers/driver_home_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../features/auth/controllers/profile_controller.dart';
import 'package:del_pick/features/driver/controllers/driver_orders_controller.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    // ========================================================================
    // DATA SOURCES - dengan parameter yang benar
    // ========================================================================

    // Driver Remote DataSource
    Get.lazyPut<DriverRemoteDataSource>(
      () => DriverRemoteDataSource(
        apiService: Get.find<ApiService>(),
        authLocalDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );

    // Order Remote DataSource
    Get.lazyPut<OrderRemoteDataSource>(
      () => OrderRemoteDataSource(
        apiService: Get.find<ApiService>(),
        authLocalDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );

    // Tracking Remote DataSource (jika diperlukan)
    // Get.lazyPut<TrackingRemoteDataSource>(
    //   () => TrackingRemoteDataSource(
    //     apiService: Get.find<ApiService>(),
    //     authLocalDataSource: Get.find<AuthLocalDataSource>(),
    //   ),
    // );
    Get.lazyPut<TrackingRepository>(
      () => TrackingRepository(Get.find<TrackingProvider>()),
    );

    // ========================================================================
    // PROVIDERS - tanpa constructor parameters (menggunakan Get.find internally)
    // ========================================================================

    Get.lazyPut<DriverProvider>(() => DriverProvider(
          remoteDataSource: Get.find<DriverRemoteDataSource>(),
        ));

    Get.lazyPut<OrderProvider>(() => OrderProvider());
    Get.lazyPut<TrackingProvider>(() => TrackingProvider());

    // ========================================================================
    // REPOSITORIES - dengan provider dependency
    // ========================================================================

    Get.lazyPut<DriverRepository>(
      () => DriverRepository(Get.find<DriverProvider>()),
    );
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<OrderProvider>()),
    );
    Get.lazyPut<TrackingRepository>(
      () => TrackingRepository(Get.find<TrackingProvider>()),
    );

    // ========================================================================
    // CONTROLLERS - dengan dependency yang benar
    // ========================================================================

    Get.lazyPut<DriverHomeController>(
      () => DriverHomeController(
        driverRepository: Get.find<DriverRepository>(),
        orderRepository: Get.find<OrderRepository>(),
        locationService:
            Get.find(), // LocationService should be registered in app binding
      ),
    );

    Get.lazyPut<DriverOrdersController>(
      () => DriverOrdersController(Get.find<OrderRepository>()),
    );

    // Profile Controller dengan dependency yang benar
    Get.lazyPut<ProfileController>(
      () => ProfileController(
          // authRepository: Get.find<AuthRepository>(), // uncomment when available
          // driverRepository: Get.find<DriverRepository>(), // uncomment when needed
          ),
    );

    // ========================================================================
    // CONTROLLER LAIN - uncomment sesuai kebutuhan
    // ========================================================================

    /*
    Get.lazyPut<DriverRequestController>(
      () => DriverRequestController(
        driverRepository: Get.find<DriverRepository>(),
        orderRepository: Get.find<OrderRepository>(),
      ),
    );

    Get.lazyPut<DeliveryController>(
      () => DeliveryController(
        trackingRepository: Get.find<TrackingRepository>(),
        orderRepository: Get.find<OrderRepository>(),
        locationService: Get.find(),
      ),
    );

    Get.lazyPut<DriverLocationController>(
      () => DriverLocationController(
        driverRepository: Get.find<DriverRepository>(),
        locationService: Get.find(),
      ),
    );

    Get.lazyPut<DriverEarningsController>(
      () => DriverEarningsController(Get.find<DriverRepository>()),
    );
    */
  }
}
