import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/order/order_model_extensions.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';

class OrderHistoryController extends GetxController {
  final OrderRepository _orderRepository;

  OrderHistoryController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  // Observable state
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxBool _canLoadMore = true.obs;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Filter options
  static const List<Map<String, dynamic>> filterOptions = [
    {'key': 'all', 'label': 'All', 'icon': Icons.list_alt},
    {'key': 'active', 'label': 'Active', 'icon': Icons.schedule},
    {'key': 'completed', 'label': 'Completed', 'icon': Icons.check_circle},
    {'key': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel},
  ];

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  String get selectedFilter => _selectedFilter.value;
  bool get canLoadMore => _canLoadMore.value;
  bool get hasOrders => _orders.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // ✅ FIXED: Map filter to backend status
  String? _mapFilterToBackendStatus(String filter) {
    switch (filter) {
      case 'active':
        return 'pending,preparing,on_delivery';
      case 'completed':
        return 'delivered';
      case 'cancelled':
        return 'cancelled';
      default:
        return null; // untuk 'all'
    }
  }

  // Load orders based on current filter
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
      // ✅ FIXED: Use mapped status filter
      final params = <String, dynamic>{
        'page': _currentPage,
        'limit': _itemsPerPage,
      };

      final backendStatus = _mapFilterToBackendStatus(_selectedFilter.value);
      if (backendStatus != null) {
        params['status'] = backendStatus;
      }

      final result = await _orderRepository.getOrdersByUser(params: params);

      if (result.isSuccess && result.data != null) {
        // ✅ Use .orders instead of .items for OrderListResponse
        final newOrders = result.data!.orders;

        if (refresh) {
          _orders.assignAll(newOrders);
        } else {
          _orders.addAll(newOrders);
        }

        // Check if we can load more
        _canLoadMore.value = newOrders.length >= _itemsPerPage;

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

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (_isLoadingMore.value || !_canLoadMore.value) return;

    _isLoadingMore.value = true;

    try {
      // ✅ FIXED: Use mapped status filter
      final params = <String, dynamic>{
        'page': _currentPage,
        'limit': _itemsPerPage,
      };

      final backendStatus = _mapFilterToBackendStatus(_selectedFilter.value);
      if (backendStatus != null) {
        params['status'] = backendStatus;
      }

      final result = await _orderRepository.getOrdersByUser(params: params);

      if (result.isSuccess && result.data != null) {
        // ✅ Use .orders instead of .items for OrderListResponse
        final newOrders = result.data!.orders;
        _orders.addAll(newOrders);

        // Check if we can load more
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

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
  }

  // Change filter
  void changeFilter(String filter) {
    if (_selectedFilter.value != filter) {
      _selectedFilter.value = filter;
      loadOrders(refresh: true);
    }
  }

  // ✅ FIXED: Updated status checking based on backend constants
  int getOrderCountByStatus(String status) {
    switch (status) {
      case 'active':
        return _orders
            .where((order) =>
                order.orderStatus == OrderStatusConstants.pending ||
                order.orderStatus == OrderStatusConstants.preparing ||
                order.orderStatus == OrderStatusConstants.onDelivery)
            .length;
      case 'completed':
        return _orders
            .where(
                (order) => order.orderStatus == OrderStatusConstants.delivered)
            .length;
      case 'cancelled':
        return _orders
            .where(
                (order) => order.orderStatus == OrderStatusConstants.cancelled)
            .length;
      default:
        return _orders.length;
    }
  }

  // ✅ FIXED: Updated to use correct order properties
  Map<String, dynamic> getOrderStatistics() {
    final totalOrders = _orders.length;
    final activeOrders = getOrderCountByStatus('active');
    final completedOrders = getOrderCountByStatus('completed');
    final cancelledOrders = getOrderCountByStatus('cancelled');

    // ✅ FIXED: Use totalAmount instead of total
    final totalSpent = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.delivered)
        .fold(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));

    return {
      'totalOrders': totalOrders,
      'activeOrders': activeOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'totalSpent': totalSpent,
    };
  }

  // Navigation methods
  void navigateToOrderDetail(int orderId) {
    Get.toNamed('/order_detail', arguments: {'orderId': orderId});
  }

  void navigateToOrderTracking(int orderId) {
    Get.toNamed('/order_tracking', arguments: {'orderId': orderId});
  }

  void navigateToReview(int orderId) {
    Get.toNamed('/order_review', arguments: {'orderId': orderId});
  }

  // ✅ FIXED: Added userRole parameter for customer cancellation
  Future<void> cancelOrder(OrderModel order) async {
    // ✅ FIXED: Use order.id instead of order.code
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // ✅ FIXED: Add userRole parameter for customer
        final result = await _orderRepository.cancelOrder(
          order.id,
          userRole: 'customer',
        );

        if (result.isSuccess) {
          Get.snackbar(
            'Success',
            'Order cancelled successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Refresh orders
          await refreshOrders();
        } else {
          Get.snackbar(
            'Error',
            result.message ?? 'Failed to cancel order',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to cancel order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> reorderItems(OrderModel order) async {
    try {
      // ✅ FIXED: Use correct order properties
      Get.toNamed(Routes.STORE_DETAIL, arguments: {
        'storeId': order.storeId,
        'reorderItems': order.items
            ?.map((item) => {
                  'itemId': item.menuItemId,
                  'quantity': item.quantity,
                })
            .toList(),
      });

      Get.snackbar(
        'Reorder',
        'Items added to cart from ${order.store?.name ?? 'Store'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reorder items',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
