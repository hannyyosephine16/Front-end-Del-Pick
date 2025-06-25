// lib/app/bindings/store_binding.dart - CORRECTED VERSION
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
    // Store Remote DataSource
    Get.lazyPut<StoreRemoteDataSource>(
      () => StoreRemoteDataSource(Get.find<ApiService>()),
    );

    // Menu Remote DataSource
    Get.lazyPut<MenuRemoteDataSource>(
      () => MenuRemoteDataSource(Get.find<ApiService>()),
    );

    // Order Remote DataSource
    Get.lazyPut<OrderRemoteDataSource>(
      () => OrderRemoteDataSource(Get.find<ApiService>()),
    );

    // Providers - FIXED: Menggunakan positional parameters, bukan named parameters
    Get.lazyPut<StoreProvider>(
      () => StoreProvider(Get.find<StoreRemoteDataSource>()),
    );

    Get.lazyPut<MenuProvider>(
      () => MenuProvider(Get.find<MenuRemoteDataSource>()),
    );

    Get.lazyPut<OrderProvider>(
      () => OrderProvider(Get.find<ApiService>()),
    );

    // Repositories
    Get.lazyPut<StoreRepository>(
      () => StoreRepository(Get.find<StoreRemoteDataSource>()),
    );

    Get.lazyPut<MenuRepository>(
      () => MenuRepository(Get.find<MenuRemoteDataSource>()),
    );

    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<OrderRemoteDataSource>()),
    );

    // Controllers
    Get.lazyPut<StoreDashboardController>(
      () => StoreDashboardController(
        orderRepository: Get.find<OrderRepository>(),
      ),
    );
  }
}
