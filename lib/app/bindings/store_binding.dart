// lib/app/bindings/store_binding.dart - FIXED VERSION
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/store_repository.dart';
import 'package:del_pick/data/repositories/menu_repository.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/providers/store_provider.dart';
import 'package:del_pick/data/providers/menu_provider.dart';
import 'package:del_pick/data/providers/order_provider.dart';
import 'package:del_pick/data/datasources/remote/store_remote_datasource.dart';
import 'package:del_pick/data/datasources/remote/menu_remote_datasource.dart';
import 'package:del_pick/data/datasources/remote/order_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/features/store/controllers/store_dashboard_controller.dart';

class StoreBinding extends Bindings {
  @override
  void dependencies() {
    // ========================================================================
    // DATA SOURCES - dengan parameter yang benar
    // ========================================================================

    // Store Remote DataSource
    Get.lazyPut<StoreRemoteDataSource>(
      () => StoreRemoteDataSource(
        Get.find<ApiService>(),
        // Get.find<AuthLocalDataSource>(),
      ),
    );

    // Menu Remote DataSource
    Get.lazyPut<MenuRemoteDataSource>(
      () => MenuRemoteDataSource(
        Get.find<ApiService>(),
        // authLocalDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );

    // ========================================================================
    // PROVIDERS - tanpa constructor parameters (menggunakan Get.find internally)
    // ========================================================================

    Get.lazyPut<StoreProvider>(() => StoreProvider());
    Get.lazyPut<MenuProvider>(() => MenuProvider());

    // Only register OrderProvider if not already registered
    if (!Get.isRegistered<OrderProvider>()) {
      Get.lazyPut<OrderProvider>(() => OrderProvider());
    }

    // ========================================================================
    // REPOSITORIES - dengan provider dependency
    // ========================================================================

    Get.lazyPut<StoreRepository>(
      () => StoreRepository(Get.find<StoreProvider>()),
    );
    Get.lazyPut<MenuRepository>(
      () => MenuRepository(Get.find<MenuProvider>()),
    );

    // Only register OrderRepository if not already registered
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(
        () => OrderRepository(Get.find<OrderProvider>()),
      );
    }

    // ========================================================================
    // CONTROLLERS - dengan dependency yang benar
    // ========================================================================

    Get.lazyPut<StoreDashboardController>(
      () => StoreDashboardController(
        storeRepository: Get.find<StoreRepository>(),
        orderRepository: Get.find<OrderRepository>(),
        menuRepository: Get.find<MenuRepository>(),
      ),
    );

    // ========================================================================
    // CONTROLLER LAIN - uncomment sesuai kebutuhan
    // ========================================================================

    /*
    Get.lazyPut<MenuManagementController>(
      () => MenuManagementController(Get.find<MenuRepository>()),
    );

    Get.lazyPut<AddMenuItemController>(
      () => AddMenuItemController(Get.find<MenuRepository>()),
    );

    Get.lazyPut<StoreOrdersController>(
      () => StoreOrdersController(Get.find<OrderRepository>()),
    );

    Get.lazyPut<StoreAnalyticsController>(
      () => StoreAnalyticsController(
        storeRepository: Get.find<StoreRepository>(),
        orderRepository: Get.find<OrderRepository>(),
      ),
    );

    Get.lazyPut<StoreSettingsController>(
      () => StoreSettingsController(Get.find<StoreRepository>()),
    );

    Get.lazyPut<StoreProfileController>(
      () => StoreProfileController(Get.find<StoreRepository>()),
    );
    */
  }
}
