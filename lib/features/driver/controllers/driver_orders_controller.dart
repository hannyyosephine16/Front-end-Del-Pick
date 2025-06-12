// lib/features/driver/controllers/driver_orders_controller.dart - FIXED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/base/base_model.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';

class DriverOrdersController extends GetxController {
  final OrderRepository _orderRepository;

  DriverOrdersController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  // Observable state
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxList<OrderModel> _activeOrders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxBool _canLoadMore = true.obs;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Filter options specific to driver
  static const List<Map<String, dynamic>> filterOptions = [
    {'key': 'all', 'label': 'All Orders', 'icon': Icons.list_alt},
    {'key': 'active', 'label': 'Active', 'icon': Icons.schedule},
    {'key': 'preparing', 'label': 'Preparing', 'icon': Icons.restaurant},
    {'key': 'on_delivery', 'label': 'Delivering', 'icon': Icons.local_shipping},
    {'key': 'delivered', 'label': 'Completed', 'icon': Icons.check_circle},
  ];

  // Getters
  List<OrderModel> get orders => _orders;
  List<OrderModel> get activeOrders => _activeOrders;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  String get selectedFilter => _selectedFilter.value;
  bool get canLoadMore => _canLoadMore.value;
  bool get hasOrders => _orders.isNotEmpty;
  bool get hasActiveOrders => _activeOrders.isNotEmpty;
  int get activeOrderCount => _activeOrders.length;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    loadActiveOrders();
  }

  // Load driver orders
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
      // Use new getDriverOrders method that returns List<Map<String, dynamic>>
      final result = await _orderRepository.getDriverOrders(
        page: _currentPage,
        limit: _itemsPerPage,
        status: _selectedFilter.value != 'all' ? _selectedFilter.value : null,
      );

      if (result.isSuccess && result.data != null) {
        // Convert Map to OrderModel
        final newOrders = result.data!
            .map((orderMap) => OrderModel.fromJson(orderMap))
            .toList();

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

  // Load active orders for driver dashboard
  Future<void> loadActiveOrders() async {
    try {
      final result = await _orderRepository.getDriverActiveOrders();

      if (result.isSuccess && result.data != null) {
        // Convert Map to OrderModel
        final activeOrdersList = result.data!
            .map((orderMap) => OrderModel.fromJson(orderMap))
            .toList();

        // Filter truly active orders
        _activeOrders.value = activeOrdersList
            .where((order) =>
                order.orderStatus == OrderStatusConstants.preparing ||
                order.orderStatus == OrderStatusConstants.onDelivery)
            .toList();
      }
    } catch (e) {
      print('Error loading active orders: $e');
    }
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (_isLoadingMore.value || !_canLoadMore.value) return;

    _isLoadingMore.value = true;

    try {
      final result = await _orderRepository.getDriverOrders(
        page: _currentPage,
        limit: _itemsPerPage,
        status: _selectedFilter.value != 'all' ? _selectedFilter.value : null,
      );

      if (result.isSuccess && result.data != null) {
        final newOrders = result.data!
            .map((orderMap) => OrderModel.fromJson(orderMap))
            .toList();

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
      loadActiveOrders(),
    ]);
  }

  // Start delivery
  Future<void> startDelivery(int orderId) async {
    try {
      final result = await _orderRepository.startDelivery(orderId);

      if (result.isSuccess) {
        Get.snackbar(
          'Delivery Started',
          'You have started the delivery for this order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh data
        await refreshData();
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to start delivery',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start delivery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Complete delivery
  Future<void> completeDelivery(int orderId) async {
    try {
      final result = await _orderRepository.completeDelivery(orderId);

      if (result.isSuccess) {
        Get.snackbar(
          'Delivery Completed',
          'Order has been delivered successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh data
        await refreshData();
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to complete delivery',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete delivery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Navigation methods
  void navigateToOrderDetail(int orderId) {
    Get.toNamed('/driver/order_detail', arguments: {'orderId': orderId});
  }

  void navigateToOrderTracking(int orderId) {
    Get.toNamed('/driver/order_tracking', arguments: {'orderId': orderId});
  }

  // Get statistics
  Map<String, dynamic> getOrderStatistics() {
    final totalOrders = _orders.length;
    final activeOrders = _activeOrders.length;
    final completedOrders = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.delivered)
        .length;

    return {
      'totalOrders': totalOrders,
      'activeOrders': activeOrders,
      'completedOrders': completedOrders,
    };
  }
}
