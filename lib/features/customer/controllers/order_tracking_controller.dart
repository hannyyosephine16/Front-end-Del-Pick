// lib/features/customer/controllers/order_history_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
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
      final result = await _orderRepository.getUserOrders(
        page: _currentPage,
        limit: _itemsPerPage,
        status: _selectedFilter.value == 'all' ? null : _selectedFilter.value,
      );

      if (result.isSuccess && result.data != null) {
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
      final result = await _orderRepository.getUserOrders(
        page: _currentPage,
        limit: _itemsPerPage,
        status: _selectedFilter.value == 'all' ? null : _selectedFilter.value,
      );

      if (result.isSuccess && result.data != null) {
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

  // Get order count by status
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

  // Get order statistics
  Map<String, dynamic> getOrderStatistics() {
    final totalOrders = _orders.length;
    final activeOrders = getOrderCountByStatus('active');
    final completedOrders = getOrderCountByStatus('completed');
    final cancelledOrders = getOrderCountByStatus('cancelled');

    final totalSpent = _orders
        .where((order) => order.orderStatus == OrderStatusConstants.delivered)
        .fold(0.0, (sum, order) => sum + order.total);

    return {
      'totalOrders': totalOrders,
      'activeOrders': activeOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'totalSpent': totalSpent,
    };
  }

  // Navigate to order detail
  void navigateToOrderDetail(int orderId) {
    Get.toNamed('/order_detail', arguments: {'orderId': orderId});
  }

  // Navigate to order tracking
  void navigateToOrderTracking(int orderId) {
    Get.toNamed('/order_tracking', arguments: {'orderId': orderId});
  }

  // Navigate to review
  void navigateToReview(int orderId) {
    Get.toNamed('/order_review', arguments: {'orderId': orderId});
  }

  // Cancel order
  Future<void> cancelOrder(OrderModel order) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order ${order.code}?'),
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
        final result = await _orderRepository.cancelOrder(order.id);

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

  // Reorder items
  Future<void> reorderItems(OrderModel order) async {
    try {
      // Navigate to store with order items
      Get.toNamed('/store_detail', arguments: {
        'storeId': order.storeId,
        'reorderItems': order.items
            ?.map((item) => {
                  'itemId': item.id,
                  'quantity': item.quantity,
                })
            .toList(),
      });

      Get.snackbar(
        'Reorder',
        'Items added to cart from ${order.storeName}',
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

// // lib/features/customer/controllers/order_tracking_controller.dart
// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/data/repositories/tracking_repository.dart';
// import 'package:del_pick/data/repositories/order_repository.dart';
// import 'package:del_pick/data/models/tracking/tracking_info_model.dart';
// import 'package:del_pick/data/models/order/order_model.dart';
// import 'package:del_pick/core/errors/error_handler.dart';
// import 'package:del_pick/core/constants/order_status_constants.dart';
//
// class OrderTrackingController extends GetxController {
//   final TrackingRepository _trackingRepository;
//   final OrderRepository _orderRepository;
//
//   OrderTrackingController({
//     required TrackingRepository trackingRepository,
//     required OrderRepository orderRepository,
//   })  : _trackingRepository = trackingRepository,
//         _orderRepository = orderRepository;
//
//   // Observable state
//   final RxBool _isLoading = false.obs;
//   final RxBool _hasError = false.obs;
//   final RxString _errorMessage = ''.obs;
//   final Rx<OrderModel?> _order = Rx<OrderModel?>(null);
//   final Rx<TrackingInfoModel?> _trackingInfo = Rx<TrackingInfoModel?>(null);
//   final RxBool _isTrackingActive = false.obs;
//   final RxInt _refreshCounter = 0.obs;
//
//   // Real-time tracking
//   Timer? _trackingTimer;
//   static const int _trackingInterval = 15; // seconds
//
//   // Getters
//   bool get isLoading => _isLoading.value;
//   bool get hasError => _hasError.value;
//   String get errorMessage => _errorMessage.value;
//   OrderModel? get order => _order.value;
//   TrackingInfoModel? get trackingInfo => _trackingInfo.value;
//   bool get isTrackingActive => _isTrackingActive.value;
//   int get refreshCounter => _refreshCounter.value;
//
//   // Computed properties
//   bool get canTrack => order?.canTrack ?? false;
//   bool get hasDriver => trackingInfo?.hasDriver ?? false;
//   bool get hasDriverLocation => trackingInfo?.hasDriverLocation ?? false;
//   String get currentStatus => order?.statusDisplayName ?? '';
//
//   double? get storeLatitude => trackingInfo?.storeLocation?.latitude;
//   double? get storeLongitude => trackingInfo?.storeLocation?.longitude;
//   double? get driverLatitude => trackingInfo?.driverLocation?.latitude;
//   double? get driverLongitude => trackingInfo?.driverLocation?.longitude;
//
//   // Default customer location (Institut Teknologi Del)
//   double get customerLatitude => 2.38349390603264;
//   double get customerLongitude => 99.14866498216043;
//
//   @override
//   void onInit() {
//     super.onInit();
//     final arguments = Get.arguments as Map<String, dynamic>?;
//     if (arguments != null && arguments['orderId'] != null) {
//       loadOrderTracking(arguments['orderId']);
//     }
//   }
//
//   @override
//   void onClose() {
//     _stopTracking();
//     super.onClose();
//   }
//
//   Future<void> loadOrderTracking(int orderId) async {
//     _isLoading.value = true;
//     _hasError.value = false;
//     _errorMessage.value = '';
//
//     try {
//       // Load order details
//       final orderResult = await _orderRepository.getOrderDetail(orderId);
//       if (orderResult.isSuccess && orderResult.data != null) {
//         _order.value = orderResult.data!;
//
//         // Start tracking if order can be tracked
//         if (canTrack) {
//           await _loadTrackingInfo(orderId);
//           _startTracking(orderId);
//         }
//       } else {
//         _hasError.value = true;
//         _errorMessage.value = orderResult.message ?? 'Failed to load order';
//       }
//     } catch (e) {
//       _hasError.value = true;
//       _errorMessage.value = ErrorHandler.getErrorMessage(
//           ErrorHandler.handleException(e as Exception));
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> _loadTrackingInfo(int orderId) async {
//     try {
//       final result = await _trackingRepository.getTrackingInfo(orderId);
//       if (result.isSuccess && result.data != null) {
//         _trackingInfo.value = result.data!;
//         _refreshCounter.value++;
//       }
//     } catch (e) {
//       print('Error loading tracking info: $e');
//     }
//   }
//
//   void _startTracking(int orderId) {
//     if (_isTrackingActive.value) return;
//
//     _isTrackingActive.value = true;
//     _trackingTimer = Timer.periodic(
//       Duration(seconds: _trackingInterval),
//       (timer) async {
//         if (!canTrack) {
//           _stopTracking();
//           return;
//         }
//
//         await _loadTrackingInfo(orderId);
//
//         // Also refresh order status
//         await _refreshOrderStatus(orderId);
//       },
//     );
//   }
//
//   void _stopTracking() {
//     _trackingTimer?.cancel();
//     _trackingTimer = null;
//     _isTrackingActive.value = false;
//   }
//
//   Future<void> _refreshOrderStatus(int orderId) async {
//     try {
//       final orderResult = await _orderRepository.getOrderDetail(orderId);
//       if (orderResult.isSuccess && orderResult.data != null) {
//         _order.value = orderResult.data!;
//
//         // Stop tracking if order is completed
//         if (!canTrack) {
//           _stopTracking();
//         }
//       }
//     } catch (e) {
//       print('Error refreshing order status: $e');
//     }
//   }
//
//   Future<void> refreshTracking() async {
//     if (order != null) {
//       await _loadTrackingInfo(order!.id);
//       await _refreshOrderStatus(order!.id);
//     }
//   }
//
//   Future<void> contactDriver() async {
//     if (trackingInfo?.driver?.phone != null) {
//       // Implement call functionality
//       Get.snackbar(
//         'Contact Driver',
//         'Calling ${trackingInfo!.driver!.phone}...',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   void navigateToOrderDetail() {
//     if (order != null) {
//       Get.toNamed('/order_detail', arguments: {'orderId': order!.id});
//     }
//   }
//
//   void goBack() {
//     _stopTracking();
//     Get.back();
//   }
//
//   // Helper methods for UI
//   String getEstimatedDeliveryTime() {
//     if (trackingInfo?.estimatedDeliveryTime != null) {
//       return trackingInfo!.estimatedTimeString;
//     }
//     return 'Calculating...';
//   }
//
//   String getDriverInfo() {
//     if (hasDriver) {
//       return trackingInfo!.driver!.name;
//     }
//     return 'Searching for driver...';
//   }
//
//   String getOrderStatusDescription() {
//     switch (order?.orderStatus) {
//       case OrderStatusConstants.preparing:
//         return 'Your order is being prepared by the restaurant';
//       case OrderStatusConstants.onDelivery:
//         return hasDriver
//             ? 'Your order is on the way with ${trackingInfo!.driver!.name}'
//             : 'Your order is being delivered';
//       case OrderStatusConstants.delivered:
//         return 'Your order has been delivered successfully';
//       default:
//         return 'Order status: ${order?.statusDisplayName ?? "Unknown"}';
//     }
//   }
//
//   List<TrackingStep> getTrackingSteps() {
//     if (order == null) return [];
//
//     return [
//       TrackingStep(
//         title: 'Order Confirmed',
//         subtitle: 'Restaurant is preparing your order',
//         isCompleted:
//             order!.isPreparing || order!.isOnDelivery || order!.isDelivered,
//         isActive: order!.isPreparing,
//         icon: Icons.restaurant,
//       ),
//       TrackingStep(
//         title: 'Driver Assigned',
//         subtitle: hasDriver
//             ? 'Driver: ${trackingInfo!.driver!.name}'
//             : 'Finding driver...',
//         isCompleted: hasDriver && (order!.isOnDelivery || order!.isDelivered),
//         isActive: hasDriver && order!.isPreparing,
//         icon: Icons.person,
//       ),
//       TrackingStep(
//         title: 'On The Way',
//         subtitle: 'Your order is being delivered',
//         isCompleted: order!.isDelivered,
//         isActive: order!.isOnDelivery,
//         icon: Icons.delivery_dining,
//       ),
//       TrackingStep(
//         title: 'Delivered',
//         subtitle: 'Enjoy your meal!',
//         isCompleted: order!.isDelivered,
//         isActive: false,
//         icon: Icons.check_circle,
//       ),
//     ];
//   }
// }
//
// class TrackingStep {
//   final String title;
//   final String subtitle;
//   final bool isCompleted;
//   final bool isActive;
//   final IconData icon;
//
//   TrackingStep({
//     required this.title,
//     required this.subtitle,
//     required this.isCompleted,
//     required this.isActive,
//     required this.icon,
//   });
// }
