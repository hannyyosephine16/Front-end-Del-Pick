// lib/features/driver/controllers/driver_orders_controller.dart - FIXED VERSION
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/repositories/tracking_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/utils/custom_snackbar.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class DriverOrdersController extends GetxController {
  final OrderRepository orderRepository;
  final TrackingRepository trackingRepository;

  DriverOrdersController({
    required this.orderRepository,
    required this.trackingRepository,
  });

  // Observable Variables
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxList<OrderModel> _activeOrders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxBool _canLoadMore = true.obs;
  final RxBool _isUpdatingStatus = false.obs;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Timer untuk periodic updates
  Timer? _refreshTimer;

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
  bool get isUpdatingStatus => _isUpdatingStatus.value;
  int get activeOrderCount => _activeOrders.length;

  // Filter options specific to driver
  static const List<Map<String, dynamic>> filterOptions = [
    {'key': 'all', 'label': 'All Orders', 'icon': Icons.list_alt},
    {'key': 'active', 'label': 'Active', 'icon': Icons.schedule},
    {'key': 'preparing', 'label': 'Preparing', 'icon': Icons.restaurant},
    {
      'key': 'ready_for_pickup',
      'label': 'Ready for Pickup',
      'icon': Icons.shopping_bag
    },
    {'key': 'on_delivery', 'label': 'Delivering', 'icon': Icons.local_shipping},
    {'key': 'delivered', 'label': 'Completed', 'icon': Icons.check_circle},
  ];

  // Filtered lists
  List<OrderModel> get preparingOrders => _orders
      .where((order) => order.orderStatus == OrderStatusConstants.preparing)
      .toList();

  List<OrderModel> get readyForPickupOrders => _orders
      .where(
          (order) => order.orderStatus == OrderStatusConstants.readyForPickup)
      .toList();

  List<OrderModel> get onDeliveryOrders => _orders
      .where((order) => order.orderStatus == OrderStatusConstants.onDelivery)
      .toList();

  List<OrderModel> get completedOrders => _orders
      .where((order) => order.orderStatus == OrderStatusConstants.delivered)
      .toList();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    loadActiveOrders();
    _startPeriodicUpdates();
  }

  @override
  void onClose() {
    _stopPeriodicUpdates();
    super.onClose();
  }

  void _startPeriodicUpdates() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (hasActiveOrders) {
        _loadActiveOrdersQuietly();
      }
    });
  }

  void _stopPeriodicUpdates() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Load driver orders - Using order repository getDriverOrders method
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
      print(
          '🔄 Loading driver orders - Page: $_currentPage, Filter: $selectedFilter');

      // Use the new getDriverOrders method that returns List<Map<String, dynamic>>
      final result = await orderRepository.getDriverOrders(
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

        print(
            '✅ Driver orders loaded: ${newOrders.length} new, ${_orders.length} total');
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to load orders';
        print('❌ Failed to load driver orders: ${result.message}');
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to load orders: ${e.toString()}';
      print('💥 Exception in loadOrders: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load active orders for driver dashboard
  Future<void> loadActiveOrders() async {
    try {
      print('📋 Loading active driver orders...');

      final result = await orderRepository.getDriverActiveOrders();

      if (result.isSuccess && result.data != null) {
        // Convert Map to OrderModel
        final activeOrdersList = result.data!
            .map((orderMap) => OrderModel.fromJson(orderMap))
            .toList();

        // Filter truly active orders for driver
        _activeOrders.value = activeOrdersList
            .where((order) =>
                order.orderStatus == OrderStatusConstants.preparing ||
                order.orderStatus == OrderStatusConstants.readyForPickup ||
                order.orderStatus == OrderStatusConstants.onDelivery)
            .toList();

        print('✅ Active driver orders loaded: ${_activeOrders.length}');
      } else {
        print('❌ Failed to load active orders: ${result.message}');
      }
    } catch (e) {
      print('💥 Exception in loadActiveOrders: $e');
    }
  }

  /// Load active orders quietly for background updates
  Future<void> _loadActiveOrdersQuietly() async {
    try {
      final result = await orderRepository.getDriverActiveOrders();

      if (result.isSuccess && result.data != null) {
        final activeOrdersList = result.data!
            .map((orderMap) => OrderModel.fromJson(orderMap))
            .toList();

        final newActiveOrders = activeOrdersList
            .where((order) =>
                order.orderStatus == OrderStatusConstants.preparing ||
                order.orderStatus == OrderStatusConstants.readyForPickup ||
                order.orderStatus == OrderStatusConstants.onDelivery)
            .toList();

        // Check for status changes
        bool hasStatusChanges = false;
        for (final newOrder in newActiveOrders) {
          final existingOrder = _activeOrders.firstWhereOrNull(
            (order) => order.id == newOrder.id,
          );

          if (existingOrder == null ||
              existingOrder.orderStatus != newOrder.orderStatus) {
            hasStatusChanges = true;
            break;
          }
        }

        if (hasStatusChanges) {
          _activeOrders.value = newActiveOrders;

          // Show notification for status changes
          CustomSnackbar.showInfo(
            title: 'Order Update',
            message: 'Some of your orders have been updated',
          );
        }
      }
    } catch (e) {
      print('Background active orders refresh failed: $e');
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (_isLoadingMore.value || !_canLoadMore.value) return;

    _isLoadingMore.value = true;

    try {
      final result = await orderRepository.getDriverOrders(
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
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to load more orders',
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Change filter
  void changeFilter(String filter) {
    if (_selectedFilter.value != filter) {
      _selectedFilter.value = filter;
      loadOrders(refresh: true);
    }
  }

  /// Start delivery - Backend: POST /orders/{id}/tracking/start
  Future<void> startDelivery(int orderId) async {
    if (_isUpdatingStatus.value) return;

    try {
      _isUpdatingStatus.value = true;
      print('🚀 Starting delivery for order: $orderId');

      final result = await trackingRepository.startDelivery(orderId);

      if (result.isSuccess) {
        CustomSnackbar.showSuccess(
          title: 'Delivery Started',
          message: 'You have started the delivery for this order',
        );

        // Update order status locally
        _updateOrderStatusLocally(orderId, OrderStatusConstants.onDelivery);

        // Refresh data
        await refreshData();

        // Navigate to navigation/tracking view
        Get.toNamed(
          Routes.NAVIGATION,
          arguments: {'orderId': orderId},
        );
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to start delivery',
        );
      }
    } catch (e) {
      print('💥 Exception in startDelivery: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to start delivery: ${e.toString()}',
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  /// Complete delivery - Backend: POST /orders/{id}/tracking/complete
  Future<void> completeDelivery(int orderId) async {
    if (_isUpdatingStatus.value) return;

    try {
      _isUpdatingStatus.value = true;
      print('✅ Completing delivery for order: $orderId');

      final result = await trackingRepository.completeDelivery(orderId);

      if (result.isSuccess) {
        CustomSnackbar.showSuccess(
          title: 'Delivery Completed',
          message: 'Order has been delivered successfully',
        );

        // Update order status locally
        _updateOrderStatusLocally(orderId, OrderStatusConstants.delivered);

        // Remove from active orders
        _activeOrders.removeWhere((order) => order.id == orderId);

        // Refresh data
        await refreshData();

        // Navigate back to orders list
        Get.back();
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to complete delivery',
        );
      }
    } catch (e) {
      print('💥 Exception in completeDelivery: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to complete delivery: ${e.toString()}',
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  /// Pickup order from store (ready_for_pickup -> on_delivery)
  Future<void> pickupOrder(int orderId) async {
    if (_isUpdatingStatus.value) return;

    try {
      _isUpdatingStatus.value = true;
      print('📦 Picking up order from store: $orderId');

      // Update order status to on_delivery
      final result = await orderRepository.updateOrderStatus(
        orderId,
        {'order_status': OrderStatusConstants.onDelivery},
      );

      if (result.isSuccess) {
        CustomSnackbar.showSuccess(
          title: 'Order Picked Up',
          message: 'Order picked up from store successfully',
        );

        // Update order status locally
        _updateOrderStatusLocally(orderId, OrderStatusConstants.onDelivery);

        // Refresh data
        await refreshData();
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to pickup order',
        );
      }
    } catch (e) {
      print('💥 Exception in pickupOrder: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to pickup order: ${e.toString()}',
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  /// Update order status locally for immediate UI feedback
  void _updateOrderStatusLocally(int orderId, String newStatus) {
    // Update in main orders list
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] =
          _orders[orderIndex].copyWith(orderStatus: newStatus);
    }

    // Update in active orders list
    final activeOrderIndex =
        _activeOrders.indexWhere((order) => order.id == orderId);
    if (activeOrderIndex != -1) {
      _activeOrders[activeOrderIndex] =
          _activeOrders[activeOrderIndex].copyWith(orderStatus: newStatus);
    }
  }

  /// Cancel delivery (if something goes wrong)
  Future<void> cancelDelivery(int orderId, {String? reason}) async {
    if (_isUpdatingStatus.value) return;

    try {
      _isUpdatingStatus.value = true;
      print('❌ Cancelling delivery for order: $orderId');

      // Update order status back to ready_for_pickup or preparing
      final result = await orderRepository.updateOrderStatus(
        orderId,
        {
          'order_status': OrderStatusConstants.readyForPickup,
          'cancellation_reason': reason ?? 'Delivery cancelled by driver',
        },
      );

      if (result.isSuccess) {
        CustomSnackbar.showSuccess(
          title: 'Delivery Cancelled',
          message: 'Delivery has been cancelled successfully',
        );

        // Update order status locally
        _updateOrderStatusLocally(orderId, OrderStatusConstants.readyForPickup);

        // Refresh data
        await refreshData();
      } else {
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to cancel delivery',
        );
      }
    } catch (e) {
      print('💥 Exception in cancelDelivery: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to cancel delivery: ${e.toString()}',
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  /// Get order detail
  Future<OrderModel?> getOrderDetail(int orderId) async {
    try {
      print('📋 Getting order detail for ID: $orderId');

      final result = await orderRepository.getOrderDetail(orderId);

      if (result.isSuccess && result.data != null) {
        print('✅ Order detail loaded successfully');
        return result.data!;
      } else {
        print('❌ Failed to get order detail: ${result.message}');
        CustomSnackbar.showError(
          title: 'Error',
          message: result.message ?? 'Failed to get order detail',
        );
        return null;
      }
    } catch (e) {
      print('💥 Exception in getOrderDetail: $e');
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Failed to get order detail: ${e.toString()}',
      );
      return null;
    }
  }

  /// Navigation methods
  void navigateToOrderDetail(int orderId) {
    Get.toNamed(
      Routes.DRIVER_REQUEST_DETAIL,
      arguments: {'orderId': orderId},
    );
  }

  void navigateToOrderTracking(int orderId) {
    Get.toNamed(
      Routes.ORDER_TRACKING,
      arguments: {'orderId': orderId},
    );
  }

  void navigateToNavigation(int orderId) {
    Get.toNamed(
      Routes.NAVIGATION,
      arguments: {'orderId': orderId},
    );
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadOrders(refresh: true),
      loadActiveOrders(),
    ]);
  }

  /// Get order action buttons based on status
  List<String> getOrderActions(OrderModel order) {
    final actions = <String>[];

    switch (order.orderStatus) {
      case OrderStatusConstants.preparing:
        actions.addAll(['view_detail', 'track']);
        break;
      case OrderStatusConstants.readyForPickup:
        actions.addAll(['pickup', 'view_detail', 'track']);
        break;
      case OrderStatusConstants.onDelivery:
        actions.addAll(['complete_delivery', 'navigation', 'track']);
        break;
      case OrderStatusConstants.delivered:
        actions.addAll(['view_detail']);
        break;
      default:
        actions.add('view_detail');
    }

    return actions;
  }

  /// Check if order can be started for delivery
  bool canStartDelivery(OrderModel order) {
    return order.orderStatus == OrderStatusConstants.readyForPickup &&
        !_isUpdatingStatus.value;
  }

  /// Check if order can be completed
  bool canCompleteDelivery(OrderModel order) {
    return order.orderStatus == OrderStatusConstants.onDelivery &&
        !_isUpdatingStatus.value;
  }

  /// Check if order can be picked up
  bool canPickupOrder(OrderModel order) {
    return order.orderStatus == OrderStatusConstants.readyForPickup &&
        !_isUpdatingStatus.value;
  }

  /// Get order status display info
  Map<String, dynamic> getOrderStatusDisplayInfo(OrderModel order) {
    switch (order.orderStatus) {
      case OrderStatusConstants.preparing:
        return {
          'text': 'Being Prepared',
          'color': Colors.orange,
          'icon': Icons.restaurant,
          'description': 'Store is preparing your assigned order',
        };
      case OrderStatusConstants.readyForPickup:
        return {
          'text': 'Ready for Pickup',
          'color': Colors.blue,
          'icon': Icons.shopping_bag,
          'description': 'Order is ready to be picked up from store',
        };
      case OrderStatusConstants.onDelivery:
        return {
          'text': 'On Delivery',
          'color': Colors.green,
          'icon': Icons.local_shipping,
          'description': 'You are delivering this order',
        };
      case OrderStatusConstants.delivered:
        return {
          'text': 'Delivered',
          'color': Colors.green,
          'icon': Icons.check_circle,
          'description': 'Order has been delivered successfully',
        };
      default:
        return {
          'text': 'Unknown',
          'color': Colors.grey,
          'icon': Icons.help_outline,
          'description': 'Order status is unknown',
        };
    }
  }

  /// Get statistics
  Map<String, dynamic> getOrderStatistics() {
    final totalOrders = _orders.length;
    final activeOrders = _activeOrders.length;
    final completedOrders = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.delivered)
        .length;
    final preparingOrders = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.preparing)
        .length;
    final readyForPickupOrdersCount = _orders
        .where(
            (order) => order.orderStatus == OrderStatusConstants.readyForPickup)
        .length;
    final onDeliveryOrdersCount = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.onDelivery)
        .length;

    return {
      'totalOrders': totalOrders,
      'activeOrders': activeOrders,
      'completedOrders': completedOrders,
      'preparingOrders': preparingOrders,
      'readyForPickupOrders': readyForPickupOrdersCount,
      'onDeliveryOrders': onDeliveryOrdersCount,
    };
  }

  /// Get next action for order
  String? getNextAction(OrderModel order) {
    switch (order.orderStatus) {
      case OrderStatusConstants.preparing:
        return 'Wait for store to finish preparation';
      case OrderStatusConstants.readyForPickup:
        return 'Go to store and pickup order';
      case OrderStatusConstants.onDelivery:
        return 'Deliver order to customer';
      case OrderStatusConstants.delivered:
        return null;
      default:
        return null;
    }
  }

  /// Get order priority
  String getOrderPriority(OrderModel order) {
    // if (order.isLate) return 'high';
    if (order.orderStatus == OrderStatusConstants.onDelivery) return 'high';
    if (order.orderStatus == OrderStatusConstants.readyForPickup)
      return 'medium';
    return 'normal';
  }

  /// Sort orders by priority
  void sortOrdersByPriority() {
    _orders.sort((a, b) {
      final aPriority = getOrderPriority(a);
      final bPriority = getOrderPriority(b);

      final priorityValues = {'high': 3, 'medium': 2, 'normal': 1};
      final aValue = priorityValues[aPriority] ?? 1;
      final bValue = priorityValues[bPriority] ?? 1;

      return bValue.compareTo(aValue); // Descending order
    });
  }

  /// Get orders that need immediate attention
  // List<OrderModel> get urgentOrders {
  //   return _activeOrders.where((order) {
  //     return order.isLate ||
  //         order.orderStatus == OrderStatusConstants.readyForPickup ||
  //         order.orderStatus == OrderStatusConstants.onDelivery;
  //   }).toList();
  // }

  /// Get total earnings from completed orders (if available)
  double get totalEarnings {
    return completedOrders.fold(0.0, (sum, order) => sum + order.deliveryFee);
  }

  /// Get today's delivery count
  int get todayDeliveryCount {
    final today = DateTime.now();
    return completedOrders.where((order) {
      return order.actualDeliveryTime != null &&
          order.actualDeliveryTime!.day == today.day &&
          order.actualDeliveryTime!.month == today.month &&
          order.actualDeliveryTime!.year == today.year;
    }).length;
  }

  /// Check if driver has any active delivery
  bool get hasActiveDelivery {
    return _activeOrders
        .any((order) => order.orderStatus == OrderStatusConstants.onDelivery);
  }

  /// Get current active delivery
  OrderModel? get currentActiveDelivery {
    try {
      return _activeOrders.firstWhere(
          (order) => order.orderStatus == OrderStatusConstants.onDelivery);
    } catch (e) {
      return null;
    }
  }

  /// Auto-refresh orders when status changes are detected
  void enableAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (hasActiveOrders) {
        _loadActiveOrdersQuietly();
      }
    });
  }

  /// Disable auto-refresh
  void disableAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}
