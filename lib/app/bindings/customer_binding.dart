// lib/app/bindings/customer_binding.dart - OPTIMIZED VERSION
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

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ LAZY: Providers hanya dibuat saat dibutuhkan
    Get.lazyPut(() => StoreProvider(), fenix: true);
    Get.lazyPut(() => MenuProvider(), fenix: true);
    Get.lazyPut(() => OrderProvider(), fenix: true);
    Get.lazyPut(() => TrackingProvider(), fenix: true);

    // ✅ LAZY: Repositories
    Get.lazyPut(() => StoreRepository(Get.find()), fenix: true);
    Get.lazyPut(() => MenuRepository(Get.find()), fenix: true);
    Get.lazyPut(() => OrderRepository(Get.find()), fenix: true);
    Get.lazyPut(() => TrackingRepository(Get.find()), fenix: true);

    // ✅ IMPORTANT: Cart controller tetap permanent untuk persist data
    Get.put(CartController(), permanent: true);

    // ✅ LAZY: Controllers lain
    Get.lazyPut(
        () => HomeController(
              storeRepository: Get.find(),
              orderRepository: Get.find(),
              locationService: Get.find(),
            ),
        fenix: true);

    Get.lazyPut(
        () => StoreController(
              storeRepository: Get.find(),
              locationService: Get.find(),
            ),
        fenix: true);

    Get.lazyPut(
        () => StoreDetailController(
              storeRepository: Get.find(),
              menuRepository: Get.find(),
              cartController: Get.find(),
            ),
        fenix: true);

    Get.lazyPut(() => CheckoutController(), fenix: true);

    Get.lazyPut(
        () => OrderHistoryController(
              orderRepository: Get.find(),
            ),
        fenix: true);
  }
}
