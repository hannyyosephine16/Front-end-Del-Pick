// lib/app/bindings/customer_binding.dart - FIXED VERSION
import 'package:get/get.dart';
import 'package:del_pick/features/customer/controllers/store_controller.dart';
import 'package:del_pick/features/customer/controllers/home_controller.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/features/customer/controllers/store_detail_controller.dart';
import 'package:del_pick/features/customer/controllers/checkout_controller.dart';
import 'package:del_pick/features/customer/controllers/order_history_controller.dart';

import '../../data/providers/menu_provider.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/store_provider.dart';
import '../../data/providers/tracking_provider.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/repositories/tracking_repository.dart';
import '../../data/datasources/remote/store_remote_datasource.dart';
import '../../data/datasources/remote/menu_remote_datasource.dart';
import '../../data/datasources/remote/order_remote_datasource.dart';
import '../../core/services/api/api_service.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Remote DataSources (if not already registered globally)
    if (!Get.isRegistered<StoreRemoteDataSource>()) {
      Get.lazyPut(() => StoreRemoteDataSource(Get.find<ApiService>()),
          fenix: true);
    }
    if (!Get.isRegistered<MenuRemoteDataSource>()) {
      Get.lazyPut(() => MenuRemoteDataSource(Get.find<ApiService>()),
          fenix: true);
    }
    if (!Get.isRegistered<OrderRemoteDataSource>()) {
      Get.lazyPut(() => OrderRemoteDataSource(Get.find<ApiService>()),
          fenix: true);
    }

    // ✅ FIXED: Providers dengan parameter yang benar
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

    // FIXED: TrackingProvider kemungkinan tanpa parameter
    Get.lazyPut<TrackingProvider>(
      () => TrackingProvider(),
      fenix: true,
    );

    // ✅ Repositories
    Get.lazyPut<StoreRepository>(
      () => StoreRepository(Get.find<StoreRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<MenuRepository>(
      () => MenuRepository(Get.find<MenuRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<OrderRemoteDataSource>()),
      fenix: true,
    );

    // FIXED: TrackingRepository membutuhkan TrackingProvider (bukan TrackingRemoteDataSource)
    Get.lazyPut<TrackingRepository>(
      () => TrackingRepository(Get.find<TrackingProvider>()),
      fenix: true,
    );

    // ✅ IMPORTANT: Cart controller tetap permanent untuk persist data
    Get.put(CartController(), permanent: true);

    // ✅ Controllers
    Get.lazyPut<HomeController>(
      () => HomeController(
        storeRepository: Get.find(),
        orderRepository: Get.find(),
        locationService: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<StoreController>(
      () => StoreController(
        storeRepository: Get.find(),
        locationService: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<StoreDetailController>(
      () => StoreDetailController(
        storeRepository: Get.find(),
        menuRepository: Get.find(),
        cartController: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);

    Get.lazyPut<OrderHistoryController>(
      () => OrderHistoryController(
        orderRepository: Get.find(),
      ),
      fenix: true,
    );
  }
}
