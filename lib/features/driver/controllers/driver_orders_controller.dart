// lib/features/driver/controllers/driver_orders_controller.dart
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/core/utils/custom_snackbar.dart';

import '../../../app/routes/app_routes.dart';

class DriverOrdersController extends GetxController {
  final OrderRepository orderRepository;

  DriverOrdersController(this.orderRepository);

  // Observable variables
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMoreData = true.obs;
  final RxInt _totalOrders = 0.obs;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  String get selectedFilter => _selectedFilter.value;
  int get currentPage => _currentPage.value;
  bool get hasMoreData => _hasMoreData.value;
  int get totalOrders => _totalOrders.value;

  // Filter options
  final List<Map<String, String>> filterOptions = [
    {'key': 'all', 'label': 'Semua Pesanan'},
    {'key': 'pending', 'label': 'Menunggu'},
    {'key': 'preparing', 'label': 'Disiapkan'},
    {'key': 'on_delivery', 'label': 'Dalam Pengiriman'},
    {'key': 'delivered', 'label': 'Selesai'},
    {'key': 'cancelled', 'label': 'Dibatalkan'},
  ];

  // Computed properties
  List<OrderModel> get activeOrders => _orders
      .where((order) =>
          order.orderStatus == 'preparing' ||
          order.orderStatus == 'on_delivery')
      .toList();

  List<OrderModel> get completedOrders =>
      _orders.where((order) => order.orderStatus == 'delivered').toList();

  List<OrderModel> get cancelledOrders =>
      _orders.where((order) => order.orderStatus == 'cancelled').toList();

  int get activeOrderCount => activeOrders.length;
  int get completedOrderCount => completedOrders.length;
  int get cancelledOrderCount => cancelledOrders.length;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // Load orders with pagination
  Future<void> loadOrders({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _isRefreshing.value = true;
        _currentPage.value = 1;
        _hasMoreData.value = true;
      } else {
        _isLoading.value = true;
      }

      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': 10,
      };

      // Add status filter if not 'all'
      if (_selectedFilter.value != 'all') {
        params['status'] = _selectedFilter.value;
      }

      // Use driver-specific endpoint (assuming we have one)
      final result = await orderRepository.getOrdersByUser(params: params);

      if (result.isSuccess && result.data != null) {
        final paginatedResponse = result.data!;

        if (isRefresh) {
          _orders.clear();
        }

        _orders.addAll(paginatedResponse.data);
        _totalOrders.value = paginatedResponse.totalItems;

        // Check if has more data
        _hasMoreData.value = _currentPage.value < paginatedResponse.totalPages;

        // Increment page for next load
        if (_hasMoreData.value) {
          _currentPage.value++;
        }
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to load orders',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to load orders: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (!_hasMoreData.value || _isLoading.value) return;

    await loadOrders();
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(isRefresh: true);
  }

  // Change filter
  void changeFilter(String filter) {
    if (_selectedFilter.value != filter) {
      _selectedFilter.value = filter;
      refreshOrders();
    }
  }

  // Get order by ID
  OrderModel? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Update order status (for driver actions)
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      _isLoading.value = true;

      final result = await orderRepository.updateOrderStatus({
        'id': orderId,
        'status': newStatus,
      });

      if (result.isSuccess && result.data != null) {
        // Update local order
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = result.data!;
        }

        CustomSnackbar.showSuccess(
          title: 'Success',
          message: 'Order status updated successfully',
        );

        // Refresh to get updated data
        await refreshOrders();
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to update order status',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to update order: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Start delivery
  Future<void> startDelivery(int orderId) async {
    await updateOrderStatus(orderId, 'on_delivery');
  }

  // Complete delivery
  Future<void> completeDelivery(int orderId) async {
    await updateOrderStatus(orderId, 'delivered');
  }

  // Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    if (status == 'all') return _orders;
    return _orders.where((order) => order.orderStatus == status).toList();
  }

  // Get order statistics
  Map<String, dynamic> getOrderStatistics() {
    return {
      'total': _totalOrders.value,
      'active': activeOrderCount,
      'completed': completedOrderCount,
      'cancelled': cancelledOrderCount,
      'todayDeliveries': _orders
          .where((order) =>
              order.orderStatus == 'delivered' && _isToday(order.orderDate))
          .length,
      'todayEarnings': _calculateTodayEarnings(),
    };
  }

  // Helper methods
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  double _calculateTodayEarnings() {
    final todayOrders = _orders.where((order) =>
        order.orderStatus == 'delivered' && _isToday(order.orderDate));

    double earnings = 0.0;
    for (final order in todayOrders) {
      // Assume driver gets a percentage of the service charge
      earnings += order.serviceCharge * 0.8; // 80% of service charge
    }
    return earnings;
  }

  // Format currency
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  // Navigation methods
  void goToOrderDetail(OrderModel order) {
    Get.toNamed('/driver/order-detail', arguments: {'order': order});
    // Get.toNamed(Routes.DRIVER_ORDERS, arguments: {'order': order});
  }

  void goToOrderTracking(OrderModel order) {
    Get.toNamed('/order-tracking', arguments: {'orderId': order.id});
  }

  void goToNavigation(OrderModel order) {
    Get.toNamed('/driver/navigation', arguments: {'order': order});
  }
}
