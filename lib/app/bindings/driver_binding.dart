// lib/app/bindings/driver_binding.dart
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

// Import the controller files - UNCOMMENT INI
import 'package:del_pick/features/driver/controllers/driver_home_controller.dart';

import '../../data/repositories/auth_repository.dart';
import '../../features/auth/controllers/profile_controller.dart';
// import 'package:del_pick/features/driver/controllers/driver_request_controller.dart';
// import 'package:del_pick/features/driver/controllers/delivery_controller.dart';
// import 'package:del_pick/features/driver/controllers/driver_location_controller.dart';
// import 'package:del_pick/features/driver/controllers/driver_orders_controller.dart';
// import 'package:del_pick/features/driver/controllers/driver_earnings_controller.dart';
// import 'package:del_pick/features/driver/controllers/driver_profile_controller.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources
    Get.lazyPut<DriverRemoteDataSource>(
      () => DriverRemoteDataSource(Get.find()),
    );
    Get.lazyPut<OrderRemoteDataSource>(() => OrderRemoteDataSource(Get.find()));
    Get.lazyPut<TrackingRemoteDataSource>(
      () => TrackingRemoteDataSource(Get.find()),
    );

    // Providers
    Get.lazyPut<DriverProvider>(
      () => DriverProvider(remoteDataSource: Get.find()),
    );
    Get.lazyPut<OrderProvider>(
      () => OrderProvider(),
    );
    Get.lazyPut<TrackingProvider>(
      () => TrackingProvider(),
    );

    // Repositories
    Get.lazyPut<DriverRepository>(() => DriverRepository(Get.find()));
    Get.lazyPut<OrderRepository>(() => OrderRepository(Get.find()));
    Get.lazyPut<TrackingRepository>(() => TrackingRepository(Get.find()));

    // Controllers - UNCOMMENT DAN PERBAIKI INI
    Get.lazyPut<DriverHomeController>(
      () => DriverHomeController(),
    );

    // Uncomment controller lain sesuai kebutuhan
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
    Get.lazyPut<DriverOrdersController>(
      () => DriverOrdersController(Get.find<OrderRepository>()),
    );
    Get.lazyPut<DriverEarningsController>(
      () => DriverEarningsController(Get.find<DriverRepository>()),
    );
    */

    Get.lazyPut<ProfileController>(
      () => ProfileController(
          // authRepository: Get.find<AuthRepository>(),
          // driverRepository: Get.find<DriverRepository>(),
          ),
    );
  }
}
