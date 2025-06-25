// lib/app/bindings/customer_binding.dart - FIXED VERSION
import 'package:get/get.dart';

// Controllers - Feature-based organization sesuai backend
import '../../features/customer/controllers/home_controller.dart';
import '../../features/customer/controllers/order_controller.dart';
import '../../features/customer/controllers/customer_profile_controller.dart';
import '../../features/customer/controllers/store_detail_controller.dart';

// Data layer - Sesuai dengan backend API structure
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
import '../../data/datasources/remote/tracking_remote_datasource.dart';

// Core services
import '../../core/services/api/api_service.dart';
import '../../core/services/external/location_service.dart';
import '../../core/services/cart_service.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // =====================================================
    // DATA SOURCES - Backend API integration layer
    // =====================================================

    // Remote DataSources - Only register if not global
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
      () => OrderProvider(Get.find<OrderRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<TrackingProvider>(
      () => TrackingProvider(Get.find<TrackingRemoteDataSource>()),
      fenix: true,
    );

    // =====================================================
    // REPOSITORIES - Business logic layer
    // =====================================================

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

    Get.lazyPut<TrackingRepository>(
      () => TrackingRepository(Get.find<TrackingRemoteDataSource>()),
      fenix: true,
    );

    // =====================================================
    // CART SERVICE - Ensure cart is available
    // =====================================================

    if (!Get.isRegistered<CartService>()) {
      Get.put<CartService>(CartService(), permanent: true);
    }

    // =====================================================
    // CONTROLLERS - UI State management
    // =====================================================

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
        cartController: Get.find<CartService>(),
      ),
      fenix: true,
    );

    // Order Controller - Order management & tracking
    Get.lazyPut<CustomerOrderController>(
      () => CustomerOrderController(
        orderRepository: Get.find<OrderRepository>(),
        trackingRepository: Get.find<TrackingRepository>(),
      ),
      fenix: true,
    );

    // Profile Controller - User profile management
    Get.lazyPut<CustomerProfileController>(
      () => CustomerProfileController(),
      fenix: true,
    );
  }
}

// =====================================================
// MENGAPA INI VERSI TERBAIK?
// =====================================================

/*
1. ✅ KONSISTEN DENGAN BACKEND:
   - Mengikuti endpoint structure backend
   - Data flow: DataSource → Provider → Repository → Controller
   - Sesuai dengan backend API /stores, /menu, /orders, /auth

2. ✅ ARCHITECTURE PATTERN:
   - Clean Architecture implementation
   - Proper dependency injection
   - Separation of concerns yang jelas

3. ✅ FEATURE ORGANIZATION:
   - CustomerHomeController: Home dashboard, nearby stores
   - CustomerOrderController: Order management, history, tracking
   - CustomerProfileController: Profile & account management
   - StoreDetailController: Store detail & menu browsing

4. ✅ BACKEND ALIGNMENT:
   - StoreRepository → /stores endpoints
   - MenuRepository → /menu endpoints
   - OrderRepository → /orders endpoints
   - TrackingRepository → /orders/{id}/tracking endpoints

5. ✅ SCALABILITY:
   - Easy to add new features
   - Modular controller structure
   - Maintainable code organization

6. ✅ PERFORMANCE:
   - Lazy loading dengan fenix: true
   - Efficient memory management
   - Proper dependency lifecycle

7. ❌ TIDAK TERMASUK CART:
   Cart sebaiknya dipisah atau dijadikan service karena:
   - Cart bersifat temporary state
   - Perlu persist across app lifecycle
   - Bisa dibagikan antar controllers
*/
