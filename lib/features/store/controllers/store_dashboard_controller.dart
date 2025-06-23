import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';

class StoreDashboardController extends GetxController {
  final OrderRepository _orderRepository;

  StoreDashboardController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  // Observable state
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxList<OrderModel> _pendingOrders = <OrderModel>[].obs;
  final RxList<OrderModel> _preparingOrders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxBool _canLoadMore = true.obs;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Filter options for store
  static const List<Map<String, dynamic>> filterOptions = [
    {'key': 'all', 'label': 'All Orders', 'icon': Icons.list_alt},
    {'key': 'pending', 'label': 'Pending', 'icon': Icons.schedule},
    {'key': 'preparing', 'label': 'Preparing', 'icon': Icons.restaurant},
    {
      'key': 'on_delivery',
      'label': 'On Delivery',
      'icon': Icons.local_shipping
    },
    {'key': 'delivered', 'label': 'Completed', 'icon': Icons.check_circle},
    {'key': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel},
  ];

  // Getters
  List<OrderModel> get orders => _orders;
  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get preparingOrders => _preparingOrders;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  String get selectedFilter => _selectedFilter.value;
  bool get canLoadMore => _canLoadMore.value;
  bool get hasOrders => _orders.isNotEmpty;
  int get pendingOrderCount => _pendingOrders.length;
  int get preparingOrderCount => _preparingOrders.length;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    loadOrdersByStatus();
  }

  // Load store orders
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
      final result = await _orderRepository.getOrdersByStore(
        params: {
          'page': _currentPage,
          'limit': _itemsPerPage,
          if (_selectedFilter.value != 'all') 'status': _selectedFilter.value,
        },
      );

      if (result.isSuccess && result.data != null) {
        // ✅ FIXED: Use .items from PaginatedResponse
        final newOrders = result.data!.items;

        if (refresh) {
          _orders.assignAll(newOrders);
        } else {
          _orders.addAll(newOrders);
        }

        _canLoadMore.value = newOrders.length >= _itemsPerPage;

        if (newOrders.isNotEmpty) {
          _currentPage++;
        }
      } else {
        _hasError.value = true;
        _errorMessage.value = result.errorMessage;
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = ErrorHandler.getErrorMessage(
          ErrorHandler.handleException(e as Exception));
    } finally {
      _isLoading.value = false;
    }
  }

  // Load orders by specific status for dashboard widgets
  Future<void> loadOrdersByStatus() async {
    try {
      // Load pending orders
      final pendingResult = await _orderRepository.getOrdersByStore(
        params: {'status': 'pending', 'limit': 20},
      );

      if (pendingResult.isSuccess && pendingResult.data != null) {
        // ✅ FIXED: Use .items from PaginatedResponse
        _pendingOrders.value = pendingResult.data!.items;
      }

      // Load preparing orders
      final preparingResult = await _orderRepository.getOrdersByStore(
        params: {'status': 'preparing', 'limit': 20},
      );

      if (preparingResult.isSuccess && preparingResult.data != null) {
        // ✅ FIXED: Use .items from PaginatedResponse
        _preparingOrders.value = preparingResult.data!.items;
      }
    } catch (e) {
      print('Error loading orders by status: $e');
    }
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (_isLoadingMore.value || !_canLoadMore.value) return;

    _isLoadingMore.value = true;

    try {
      final result = await _orderRepository.getOrdersByStore(
        params: {
          'page': _currentPage,
          'limit': _itemsPerPage,
          if (_selectedFilter.value != 'all') 'status': _selectedFilter.value,
        },
      );

      if (result.isSuccess && result.data != null) {
        // ✅ FIXED: Use .items from PaginatedResponse
        final newOrders = result.data!.items;
        _orders.addAll(newOrders);

        _canLoadMore.value = newOrders.length >= _itemsPerPage;

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

  // Change filter
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
      loadOrdersByStatus(),
    ]);
  }

  // Process order (approve/reject)
  Future<void> processOrder(int orderId, String action) async {
    try {
      final result = await _orderRepository.processOrder(orderId, {
        'action': action, // 'approve' or 'reject'
      });

      if (result.isSuccess) {
        final actionText = action == 'approve' ? 'approved' : 'rejected';
        Get.snackbar(
          'Order ${actionText.capitalize!}',
          'Order has been $actionText successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: action == 'approve' ? Colors.green : Colors.orange,
          colorText: Colors.white,
        );

        // Refresh data
        await refreshData();
      } else {
        Get.snackbar(
          'Error',
          result.errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process order',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Approve order
  Future<void> approveOrder(OrderModel order) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Approve Order'),
        content: Text('Are you sure you want to approve order ${order.code}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await processOrder(order.id, 'approve');
    }
  }

  // Reject order
  Future<void> rejectOrder(OrderModel order) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject Order'),
        content: Text('Are you sure you want to reject order ${order.code}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reject'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await processOrder(order.id, 'reject');
    }
  }

  // Navigation methods
  void navigateToOrderDetail(int orderId) {
    Get.toNamed('/store/order_detail', arguments: {'orderId': orderId});
  }

  void navigateToMenuManagement() {
    Get.toNamed('/store/menu_management');
  }

  void navigateToStoreSettings() {
    Get.toNamed('/store/settings');
  }

  // Get dashboard statistics
  Map<String, dynamic> getDashboardStatistics() {
    final totalOrders = _orders.length;
    final pendingCount = _pendingOrders.length;
    final preparingCount = _preparingOrders.length;
    final completedOrders = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.delivered)
        .length;
    final cancelledOrders = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.cancelled)
        .length;

    // ✅ FIXED: Use grandTotal instead of total
    final totalRevenue = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.delivered)
        .fold(0.0, (sum, order) => sum + order.grandTotal);

    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingCount,
      'preparingOrders': preparingCount,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'totalRevenue': totalRevenue,
    };
  }
}
