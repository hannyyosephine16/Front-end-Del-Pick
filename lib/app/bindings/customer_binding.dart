// lib/app/bindings/customer_binding.dart - FIXED VERSION
import 'package:get/get.dart';

// Controllers
import '../../features/auth/controllers/profile_controller.dart';
import '../../features/customer/controllers/home_controller.dart';
import '../../features/customer/controllers/order_controller.dart';
import '../../features/customer/controllers/customer_profile_controller.dart';
import '../../features/customer/controllers/store_detail_controller.dart';
import '../../features/customer/controllers/cart_controller.dart';

// Providers - Data processing layer
import '../../data/providers/store_provider.dart';
import '../../data/providers/menu_provider.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/tracking_provider.dart';

// Repositories - Business logic layer
import '../../data/repositories/store_repository.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/tracking_repository.dart';

// Data Sources
import '../../data/datasources/remote/store_remote_datasource.dart';
import '../../data/datasources/remote/menu_remote_datasource.dart';
import '../../data/datasources/remote/order_remote_datasource.dart';
import '../../data/datasources/remote/tracking_remote_datasource.dart';

// Core services
import '../../core/services/api/api_service.dart';
import '../../core/services/external/location_service.dart';
import '../../core/services/local/storage_service.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // =====================================================
    // DATA SOURCES - Backend API integration layer
    // =====================================================

    // Remote DataSources - Only register if not already global
    if (!Get.isRegistered<StoreRemoteDataSource>()) {
      Get.lazyPut<StoreRemoteDataSource>(
        () => StoreRemoteDataSource(Get.find<ApiService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<MenuRemoteDataSource>()) {
      Get.lazyPut<MenuRemoteDataSource>(
        () => MenuRemoteDataSource(Get.find<ApiService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<OrderRemoteDataSource>()) {
      Get.lazyPut<OrderRemoteDataSource>(
        () => OrderRemoteDataSource(Get.find<ApiService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<TrackingRemoteDataSource>()) {
      Get.lazyPut<TrackingRemoteDataSource>(
        () => TrackingRemoteDataSource(Get.find<ApiService>()),
        fenix: true,
      );
    }

    // =====================================================
    // PROVIDERS - Data processing layer
    // =====================================================

    Get.lazyPut<StoreProvider>(
      () => StoreProvider(Get.find<StoreRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<MenuProvider>(
      () => MenuProvider(Get.find<MenuRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<OrderProvider>(
      () => OrderProvider(Get.find<ApiService>()),
      fenix: true,
    );

    // Get.lazyPut<TrackingProvider>(
    //   () => TrackingProvider(Get.find<ApiService>()),
    //   fenix: true,
    // );

    // =====================================================
    // REPOSITORIES - Business logic layer
    // =====================================================

    Get.lazyPut<StoreRepository>(
      () => StoreRepository(Get.find<StoreProvider>() as StoreRemoteDataSource),
      fenix: true,
    );

    Get.lazyPut<MenuRepository>(
      () => MenuRepository(Get.find<MenuProvider>() as MenuRemoteDataSource),
      fenix: true,
    );

    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<OrderProvider>() as OrderRemoteDataSource),
      fenix: true,
    );

    Get.lazyPut<TrackingRepository>(
      () => TrackingRepository(Get.find<TrackingProvider>()),
      fenix: true,
    );

    // =====================================================
    // CONTROLLERS - UI State management
    // =====================================================

    // Cart Controller - Local cart management (NO BACKEND SERVICE)
    Get.lazyPut<CartController>(
      () => CartController(),
      fenix: true,
    );

    // Home Controller - Dashboard dan nearby stores
    Get.lazyPut<CustomerHomeController>(
      () => CustomerHomeController(
        storeRepository: Get.find<StoreRepository>(),
        orderRepository: Get.find<OrderRepository>(),
        locationService: Get.find<LocationService>(),
      ),
      fenix: true,
    );

    // Store Detail Controller - Store info & menu items
    Get.lazyPut<StoreDetailController>(
      () => StoreDetailController(
        storeRepository: Get.find<StoreRepository>(),
        menuRepository: Get.find<MenuRepository>(),
        cartController: Get.find<CartController>(),
      ),
      fenix: true,
    );

    // Order Controller - Order management & tracking
    Get.lazyPut<OrderController>(
      () => OrderController(
        orderRepository: Get.find<OrderRepository>(),
        // trackingRepository: Get.find<TrackingRepository>(),
        // cartController: Get.find<CartController>(),
      ),
      fenix: true,
    );

    // Profile Controller - User profile management
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
      fenix: true,
    );

    // Global Profile Controller (if needed)
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(
        () => ProfileController(),
        fenix: true,
      );
    }
  }
}
