// lib/app/bindings/driver_binding.dart - CORRECTED VERSION
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/tracking_repository.dart';
import 'package:del_pick/data/repositories/driver_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/providers/tracking_provider.dart';
import 'package:del_pick/data/providers/driver_provider.dart';
import 'package:del_pick/data/providers/order_provider.dart';
import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/data/datasources/remote/order_remote_datasource.dart';
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
    // DATA SOURCES - dengan named parameters sesuai constructor
    // ========================================================================

    // Driver Remote DataSource - menggunakan named parameters
    Get.lazyPut<DriverRemoteDataSource>(
      () => DriverRemoteDataSource(
        apiService: Get.find<ApiService>(),
        authLocalDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );

    // Order Remote DataSource - menggunakan positional parameter
    Get.lazyPut<OrderRemoteDataSource>(
      () => OrderRemoteDataSource(Get.find<ApiService>()),
    );

    // ========================================================================
    // PROVIDERS - dengan positional parameters sesuai constructor
    // ========================================================================

    // DriverProvider(this._remoteDataSource)
    Get.lazyPut<DriverProvider>(
      () => DriverProvider(Get.find<DriverRemoteDataSource>()),
    );

    // OrderProvider(this._apiService)
    Get.lazyPut<OrderProvider>(
      () => OrderProvider(Get.find<ApiService>()),
    );

    // TrackingProvider() - tanpa parameter
    Get.lazyPut<TrackingProvider>(
      () => TrackingProvider(),
    );

    // ========================================================================
    // REPOSITORIES - dengan parameter yang benar sesuai constructor
    // ========================================================================

    // DriverRepository(this._remoteDataSource, this._localDataSource)
    Get.lazyPut<DriverRepository>(
      () => DriverRepository(
        Get.find<DriverRemoteDataSource>(),
        Get.find<AuthLocalDataSource>(),
      ),
    );

    // OrderRepository(this._remoteDataSource)
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<OrderRemoteDataSource>()),
    );

    // TrackingRepository(this._trackingProvider)
    Get.lazyPut<TrackingRepository>(
      () => TrackingRepository(Get.find<TrackingProvider>()),
    );

    // ========================================================================
    // CONTROLLERS
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
      () => DriverOrdersController(
          orderRepository: Get.find<OrderRepository>(),
          trackingRepository: Get.find<TrackingRepository>()),
    );

    // ProfileController() - tanpa parameter berdasarkan error
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );

    /*
    // Uncomment jika controller ini dibutuhkan
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
