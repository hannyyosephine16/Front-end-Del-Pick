import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:del_pick/core/utils/result.dart';

import '../../../data/models/store/store_model.dart';
import '../../../data/repositories/store_repository.dart';

class StoreDashboardController extends GetxController {
  final OrderRepository _orderRepository;
  final StoreRepository _storeRepository = Get.find<StoreRepository>();

  StoreDashboardController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  // Observable state
  final Rx<StoreModel?> _currentStore = Rx<StoreModel?>(null);
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxList<OrderModel> _pendingOrders = <OrderModel>[].obs;
  final RxList<OrderModel> _preparingOrders = <OrderModel>[].obs;
  final RxList<OrderModel> _readyForPickupOrders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxBool _canLoadMore = true.obs;
  final RxBool _isProcessingOrder = false.obs;
  final RxBool _isStoreOpen = true.obs;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Filter options based on backend order statuses
  static const List<Map<String, dynamic>> filterOptions = [
    {'key': 'all', 'label': 'All Orders', 'icon': Icons.list_alt},
    {'key': 'pending', 'label': 'Pending', 'icon': Icons.schedule},
    {'key': 'preparing', 'label': 'Preparing', 'icon': Icons.restaurant},
    {
      'key': 'ready_for_pickup',
      'label': 'Ready for Pickup',
      'icon': Icons.inventory
    },
    {
      'key': 'on_delivery',
      'label': 'On Delivery',
      'icon': Icons.local_shipping
    },
    {'key': 'delivered', 'label': 'Completed', 'icon': Icons.check_circle},
    {'key': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel},
    {'key': 'rejected', 'label': 'Rejected', 'icon': Icons.block},
  ];

  // Getters
  StoreModel? get currentStore => _currentStore.value;
  List<OrderModel> get orders => _orders;
  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get preparingOrders => _preparingOrders;
  List<OrderModel> get readyForPickupOrders => _readyForPickupOrders;
  bool get isStoreOpen => _isStoreOpen.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  String get selectedFilter => _selectedFilter.value;
  bool get canLoadMore => _canLoadMore.value;
  bool get hasOrders => _orders.isNotEmpty;
  bool get isProcessingOrder => _isProcessingOrder.value;

  // Dashboard counters
  int get pendingOrderCount => _pendingOrders.length;
  int get preparingOrderCount => _preparingOrders.length;
  int get readyForPickupCount => _readyForPickupOrders.length;
  int get completedOrderCount =>
      orders.where((order) => order.orderStatus == 'delivered').length;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    ever(_isStoreOpen, (bool isOpen) {
      if (isOpen) {
        refreshData();
      }
    });
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadOrders(refresh: true),
      loadDashboardCounters(),
    ]);
  }

  // ✅ FIXED: Load store orders with proper pagination handling
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _canLoadMore.value = true;
      _orders.clear();
    }

    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      final Map<String, dynamic> params = {
        'page': _currentPage,
        'limit': _itemsPerPage,
      };

      // Add status filter if not 'all'
      if (_selectedFilter.value != 'all') {
        params['status'] = _selectedFilter.value;
      }

      // ✅ FIXED: Use proper backend response structure
      final Result<PaginatedResponse<OrderModel>> result =
          await _orderRepository.getStoreOrders(
        params: params,
      );

      if (result.isSuccess && result.data != null) {
        final paginatedResponse = result.data!;
        final newOrders = paginatedResponse.items;

        if (refresh) {
          _orders.assignAll(newOrders);
        } else {
          _orders.addAll(newOrders);
        }

        // ✅ FIXED: Check pagination properly using PaginatedResponse methods
        _canLoadMore.value = paginatedResponse.hasNextPage;

        if (newOrders.isNotEmpty) {
          _currentPage++;
        }
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to load orders';
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = ErrorHandler.getErrorMessage(
          ErrorHandler.handleException(e as Exception));
    } finally {
      _isLoading.value = false;
    }
  }

  // ✅ FIXED: Load specific order counts for dashboard widgets
  Future<void> loadDashboardCounters() async {
    try {
      // Load pending orders
      final pendingResult = await _orderRepository.getStoreOrders(
        params: {'status': 'pending', 'limit': 50},
      );

      if (pendingResult.isSuccess && pendingResult.data != null) {
        _pendingOrders.value = pendingResult.data!.items;
      }

      // Load preparing orders
      final preparingResult = await _orderRepository.getStoreOrders(
        params: {'status': 'preparing', 'limit': 50},
      );

      if (preparingResult.isSuccess && preparingResult.data != null) {
        _preparingOrders.value = preparingResult.data!.items;
      }

      // Load ready for pickup orders
      final readyResult = await _orderRepository.getStoreOrders(
        params: {'status': 'ready_for_pickup', 'limit': 50},
      );

      if (readyResult.isSuccess && readyResult.data != null) {
        _readyForPickupOrders.value = readyResult.data!.items;
      }
    } catch (e) {
      print('Error loading dashboard counters: $e');
    }
  }

  // ✅ FIXED: Load more orders for pagination
  Future<void> loadMoreOrders() async {
    if (_isLoadingMore.value || !_canLoadMore.value) return;

    _isLoadingMore.value = true;

    try {
      final Map<String, dynamic> params = {
        'page': _currentPage,
        'limit': _itemsPerPage,
      };

      if (_selectedFilter.value != 'all') {
        params['status'] = _selectedFilter.value;
      }

      final Result<PaginatedResponse<OrderModel>> result =
          await _orderRepository.getStoreOrders(
        params: params,
      );

      if (result.isSuccess && result.data != null) {
        final paginatedResponse = result.data!;
        final newOrders = paginatedResponse.items;
        _orders.addAll(newOrders);

        _canLoadMore.value = paginatedResponse.hasNextPage;

        if (newOrders.isNotEmpty) {
          _currentPage++;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load more orders',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }

  // Change filter and reload data
  void changeFilter(String filter) {
    if (_selectedFilter.value != filter) {
      _selectedFilter.value = filter;
      loadOrders(refresh: true);
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadOrders(refresh: true),
      loadDashboardCounters(),
    ]);
  }

  // ✅ Process order - approve or reject (sesuai backend endpoint /orders/:id/process)
  Future<void> processOrder(int orderId, String action) async {
    if (_isProcessingOrder.value) return;

    _isProcessingOrder.value = true;

    try {
      final result = await _orderRepository.processOrder(orderId, action);

      if (result.isSuccess) {
        final actionText = action == 'approve' ? 'approved' : 'rejected';
        final statusText = action == 'approve' ? 'preparing' : 'rejected';

        Get.snackbar(
          'Order ${actionText.capitalize!}',
          'Order has been $actionText and status changed to $statusText',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: action == 'approve' ? Colors.green : Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Update local order status without full refresh
        _updateLocalOrderStatus(
            orderId, action == 'approve' ? 'preparing' : 'rejected');

        // Refresh dashboard counters
        await loadDashboardCounters();
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to process order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process order: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isProcessingOrder.value = false;
    }
  }

  // ✅ Update order status to ready for pickup (sesuai backend endpoint /orders/:id/status)
  Future<void> updateOrderToReadyForPickup(int orderId) async {
    if (_isProcessingOrder.value) return;

    _isProcessingOrder.value = true;

    try {
      final result = await _orderRepository.updateOrderStatus(orderId, {
        'order_status': 'ready_for_pickup',
      });

      if (result.isSuccess) {
        Get.snackbar(
          'Order Updated',
          'Order is now ready for pickup by driver',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Update local order status
        _updateLocalOrderStatus(orderId, 'ready_for_pickup');

        // Refresh dashboard counters
        await loadDashboardCounters();
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to update order status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isProcessingOrder.value = false;
    }
  }

  // Approve order with confirmation dialog
  Future<void> approveOrder(OrderModel order) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Approve Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${order.id}'),
            Text('Total: Rp ${order.grandTotal.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            const Text(
                'This will approve the order and change status to "preparing". Are you sure?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await processOrder(order.id, 'approve');
    }
  }

  // Reject order with confirmation dialog
  Future<void> rejectOrder(OrderModel order) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${order.id}'),
            Text('Total: Rp ${order.grandTotal.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            const Text('This will reject the order permanently. Are you sure?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await processOrder(order.id, 'reject');
    }
  }

  // Mark order as ready for pickup with confirmation
  Future<void> markOrderReadyForPickup(OrderModel order) async {
    if (order.orderStatus != 'preparing') {
      Get.snackbar(
        'Error',
        'Only preparing orders can be marked as ready for pickup',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Ready for Pickup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${order.id}'),
            const SizedBox(height: 8),
            const Text('Mark this order as ready for pickup by driver?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Mark Ready'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await updateOrderToReadyForPickup(order.id);
    }
  }

  // Update local order status for immediate UI update
  void _updateLocalOrderStatus(int orderId, String newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final updatedOrder = _orders[orderIndex].copyWith(orderStatus: newStatus);
      _orders[orderIndex] = updatedOrder;
    }

    // Update filtered lists
    _pendingOrders.removeWhere((order) => order.id == orderId);
    _preparingOrders.removeWhere((order) => order.id == orderId);
    _readyForPickupOrders.removeWhere((order) => order.id == orderId);
  }

  // Navigation methods
  void navigateToOrderDetail(int orderId) {
    Get.toNamed('/store/order_detail', arguments: {'orderId': orderId});
  }

  void navigateToMenuManagement() {
    Get.toNamed('/store/menu_management');
  }

  void navigateToStoreProfile() {
    Get.toNamed('/store/profile');
  }

  void navigateToStoreAnalytics() {
    Get.toNamed('/store/analytics');
  }

  // ✅ FIXED: Get dashboard statistics with proper null checking
  Map<String, dynamic> getDashboardStatistics() {
    final totalOrders = _orders.length;
    final pendingCount = _pendingOrders.length;
    final preparingCount = _preparingOrders.length;
    final readyForPickupCount = _readyForPickupOrders.length;

    final completedOrders =
        _orders.where((order) => order.orderStatus == 'delivered').length;

    final cancelledOrders = _orders
        .where((order) => ['cancelled', 'rejected'].contains(order.orderStatus))
        .length;

    final totalRevenue = _orders
        .where((order) => order.orderStatus == 'delivered')
        .fold(0.0, (sum, order) => sum + order.grandTotal);

    final now = DateTime.now();
    final todayOrders = _orders.where((order) {
      final orderDate = order.createdAt;
      return orderDate.year == now.year &&
          orderDate.month == now.month &&
          orderDate.day == now.day;
    }).length;

    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingCount,
      'preparingOrders': preparingCount,
      'readyForPickupOrders': readyForPickupCount,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'totalRevenue': totalRevenue,
      'todayOrders': todayOrders,
    };
  }

  // Check if order can be processed based on current status
  bool canApproveOrder(OrderModel order) {
    return order.orderStatus == 'pending';
  }

  bool canRejectOrder(OrderModel order) {
    return order.orderStatus == 'pending';
  }

  bool canMarkReadyForPickup(OrderModel order) {
    return order.orderStatus == 'preparing';
  }

  // Get order actions based on status
  List<Map<String, dynamic>> getOrderActions(OrderModel order) {
    final actions = <Map<String, dynamic>>[];

    if (canApproveOrder(order)) {
      actions.add({
        'label': 'Approve',
        'icon': Icons.check,
        'color': Colors.green,
        'action': () => approveOrder(order),
      });
    }

    if (canRejectOrder(order)) {
      actions.add({
        'label': 'Reject',
        'icon': Icons.close,
        'color': Colors.red,
        'action': () => rejectOrder(order),
      });
    }

    if (canMarkReadyForPickup(order)) {
      actions.add({
        'label': 'Ready for Pickup',
        'icon': Icons.inventory,
        'color': Colors.blue,
        'action': () => markOrderReadyForPickup(order),
      });
    }

    // Always allow viewing details
    actions.add({
      'label': 'View Details',
      'icon': Icons.visibility,
      'color': Colors.grey[600],
      'action': () => navigateToOrderDetail(order.id),
    });

    return actions;
  }
}
