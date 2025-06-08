import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/errors/error_handler.dart';

class OrderHistoryController extends GetxController {
  final OrderRepository _orderRepository;

  OrderHistoryController({
    required OrderRepository orderRepository,
  }) : _orderRepository = orderRepository;

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMoreData = true.obs;
  final RxString _selectedStatus = 'all'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<OrderModel> get orders => _orders;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasOrders => _orders.isNotEmpty;
  bool get hasMoreData => _hasMoreData.value;
  String get selectedStatus => _selectedStatus.value;

  // Order status filters
  final List<String> statusFilters = [
    'all',
    'pending',
    'preparing',
    'on_delivery',
    'delivered',
    'cancelled'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMoreData.value = true;
      _orders.clear();
    }

    if (_isLoading.value || !_hasMoreData.value) return;

    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': 10,
      };

      // Add status filter if not 'all'
      if (_selectedStatus.value != 'all') {
        params['status'] = _selectedStatus.value;
      }

      final result = await _orderRepository.getOrdersByUser(params: params);

      if (result.isSuccess && result.data != null) {
        final paginatedResponse = result.data!;
        final newOrders = paginatedResponse.data;

        if (refresh) {
          _orders.value = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        // Check if there's more data
        _hasMoreData.value = _currentPage.value < paginatedResponse.totalPages;

        if (_hasMoreData.value) {
          _currentPage.value++;
        }
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to fetch orders';
      }
    } catch (e) {
      _hasError.value = true;
      if (e is Exception) {
        final failure = ErrorHandler.handleException(e);
        _errorMessage.value = ErrorHandler.getErrorMessage(failure);
      } else {
        _errorMessage.value = 'An unexpected error occurred';
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrders(refresh: true);
  }

  void filterByStatus(String status) {
    if (_selectedStatus.value != status) {
      _selectedStatus.value = status;
      refreshOrders();
    }
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      final result = await _orderRepository.cancelOrder(orderId);

      if (result.isSuccess) {
        // Update the order in the list
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(orderStatus: 'cancelled');
        }

        Get.snackbar(
          'Order Cancelled',
          'Your order has been cancelled successfully',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Cancel Failed',
          result.message ?? 'Failed to cancel order',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred';

      if (e is Exception) {
        final failure = ErrorHandler.handleException(e);
        errorMessage = ErrorHandler.getErrorMessage(failure);
      }

      Get.snackbar(
        'Cancel Failed',
        errorMessage,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void showCancelOrderDialog(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order ${order.code}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              cancelOrder(order.id);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String getStatusDisplayName(String status) {
    switch (status) {
      case 'all':
        return 'All Orders';
      case 'pending':
        return 'Waiting';
      case 'preparing':
        return 'Preparing';
      case 'on_delivery':
        return 'On Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  List<OrderModel> get activeOrders =>
      _orders.where((order) => order.isActive).toList();

  List<OrderModel> get completedOrders =>
      _orders.where((order) => order.isCompleted).toList();
}
