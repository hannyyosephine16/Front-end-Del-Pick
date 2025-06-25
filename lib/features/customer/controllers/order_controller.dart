// lib/features/customer/controllers/order_controller.dart - BACKEND COMPATIBLE FIXED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/order/order_model_extensions.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository;
  final AuthController _authController = Get.find<AuthController>();

  OrderController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  // Observable state
  final RxBool _isLoading = false.obs;
  final Rx<OrderModel?> _currentOrder = Rx<OrderModel?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxBool _isCancelling = false.obs;
  final RxBool _isRefreshing = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  OrderModel? get currentOrder => _currentOrder.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get isCancelling => _isCancelling.value;
  bool get isRefreshing => _isRefreshing.value;

  // ✅ Get current user role dynamically
  String get currentUserRole =>
      _authController.currentUser?.value?.role ?? 'customer';

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['orderId'] != null) {
      final orderId = arguments['orderId'];
      if (orderId is int) {
        loadOrderDetail(orderId);
      } else if (orderId is String) {
        final parsedId = int.tryParse(orderId);
        if (parsedId != null) {
          loadOrderDetail(parsedId);
        }
      }
    }
  }

  // ✅ LOAD ORDER DETAIL - Backend Compatible
  Future<void> loadOrderDetail(int orderId) async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      final result = await _orderRepository.getOrderDetail(orderId);

      if (result.isSuccess && result.data != null) {
        _currentOrder.value = result.data!;
        _hasError.value = false;
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to load order';
        _currentOrder.value = null;
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to load order: ${e.toString()}';
      _currentOrder.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  // ✅ REFRESH ORDER DETAIL
  Future<void> refreshOrderDetail() async {
    if (_currentOrder.value == null) return;

    _isRefreshing.value = true;
    try {
      await loadOrderDetail(_currentOrder.value!.id);
    } finally {
      _isRefreshing.value = false;
    }
  }

  // ✅ CANCEL ORDER - Backend Compatible with Dynamic Role
  Future<void> cancelOrder({String? reason}) async {
    if (currentOrder == null || !canCancelOrder) return;

    final confirmed = await _showCancelConfirmationDialog();
    if (confirmed != true) return;

    _isCancelling.value = true;
    try {
      // ✅ Use dynamic role instead of hardcoded
      final result = await _orderRepository.cancelOrder(
        currentOrder!.id,
        reason: reason,
        userRole: currentUserRole, // Dynamic role detection
      );

      if (result.isSuccess && result.data != null) {
        _currentOrder.value = result.data!;
        showSuccessMessage('Order cancelled successfully');
      } else {
        showErrorMessage(result.message ?? 'Failed to cancel order');
      }
    } catch (e) {
      showErrorMessage('Failed to cancel order: ${e.toString()}');
    } finally {
      _isCancelling.value = false;
    }
  }

  // ✅ CANCEL ORDER WITH REASON SELECTION - Updated reasons based on role
  Future<void> cancelOrderWithReasonSelection() async {
    if (currentOrder == null || !canCancelOrder) return;

    final reason = await _showCancelReasonDialog();
    if (reason != null) {
      await cancelOrder(reason: reason);
    }
  }

  // ✅ NAVIGATION METHODS

  void navigateToTracking() {
    if (currentOrder != null && canTrackOrder) {
      Get.toNamed(Routes.ORDER_TRACKING, arguments: {
        'orderId': currentOrder!.id,
      });
    }
  }

  void navigateToReview() {
    if (currentOrder != null && canReviewOrder) {
      Get.toNamed(Routes.REVIEW, arguments: {
        'orderId': currentOrder!.id,
        'orderData': currentOrder!.toJson(),
      });
    }
  }

  void navigateToStoreDetail() {
    if (currentOrder?.storeId != null) {
      Get.toNamed(Routes.STORE_DETAIL, arguments: {
        'storeId': currentOrder!.storeId,
      });
    }
  }

  // ✅ BUSINESS LOGIC HELPERS - Fixed to match backend

  /// Check if order can be cancelled by current user role
  bool get canCancelOrder {
    if (currentOrder == null) return false;

    final status = currentOrder!.orderStatus?.toLowerCase() ?? '';

    switch (currentUserRole.toLowerCase()) {
      case 'customer':
        // ✅ Backend: Customer can cancel 'pending' orders only
        return status == 'pending';
      case 'store':
        // ✅ Backend: Store can reject 'pending' orders only
        return status == 'pending';
      case 'driver':
        // ✅ Backend: Driver can cancel assigned orders
        return ['ready_for_pickup', 'on_delivery'].contains(status) &&
            currentOrder!.driverId != null;
      default:
        return false;
    }
  }

  /// Check if order can be tracked
  bool get canTrackOrder {
    if (currentOrder == null) return false;

    final status = currentOrder!.orderStatus?.toLowerCase() ?? '';

    // ✅ Orders can be tracked when they are in delivery phase
    return ['preparing', 'ready_for_pickup', 'on_delivery'].contains(status) ||
        (currentOrder!.driverId != null && status != 'pending');
  }

  /// Check if order can be reviewed
  bool get canReviewOrder {
    if (currentOrder == null) return false;

    // ✅ Orders can be reviewed when delivered (only by customer)
    return currentOrder!.orderStatus?.toLowerCase() == 'delivered' &&
        currentUserRole.toLowerCase() == 'customer';
  }

  /// Get order status display text with colors - ✅ Backend Compatible
  Map<String, dynamic> get orderStatusDisplay {
    if (currentOrder == null) {
      return {
        'text': 'Unknown',
        'color': Colors.grey,
        'icon': Icons.help_outline,
      };
    }

    final status = currentOrder!.orderStatus?.toLowerCase() ?? '';

    switch (status) {
      case 'pending':
        return {
          'text': 'Waiting for Store Confirmation',
          'color': Colors.orange,
          'icon': Icons.access_time,
        };
      // ❌ Removed 'confirmed' - not in backend
      case 'preparing':
        return {
          'text': 'Being Prepared',
          'color': Colors.blue,
          'icon': Icons.restaurant,
        };
      case 'ready_for_pickup':
        return {
          'text': 'Ready for Pickup',
          'color': Colors.green,
          'icon': Icons.shopping_bag,
        };
      case 'on_delivery':
        return {
          'text': 'On Delivery',
          'color': Colors.purple,
          'icon': Icons.delivery_dining,
        };
      case 'delivered':
        return {
          'text': 'Delivered',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'cancelled':
        return {
          'text': 'Cancelled',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      case 'rejected':
        return {
          'text': 'Rejected by Store',
          'color': Colors.red,
          'icon': Icons.block,
        };
      default:
        return {
          'text': status.toUpperCase(),
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }

  /// Get delivery status display - ✅ Backend Compatible
  Map<String, dynamic> get deliveryStatusDisplay {
    if (currentOrder == null) {
      return {
        'text': 'Unknown',
        'color': Colors.grey,
        'icon': Icons.help_outline,
      };
    }

    final status = currentOrder!.deliveryStatus?.toLowerCase() ?? '';

    switch (status) {
      case 'pending':
        return {
          'text': 'Waiting for Driver',
          'color': Colors.orange,
          'icon': Icons.person_search,
        };
      case 'picked_up':
        return {
          'text': 'Driver Assigned',
          'color': Colors.blue,
          'icon': Icons.person_pin_circle,
        };
      case 'on_way':
        return {
          'text': 'Driver on the Way',
          'color': Colors.purple,
          'icon': Icons.directions_car,
        };
      case 'delivered':
        return {
          'text': 'Delivered',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'rejected':
        return {
          'text': 'Delivery Rejected',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      default:
        return {
          'text': status.toUpperCase(),
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }

  /// Parse tracking updates safely from backend response - ✅ Backend Compatible
  List<Map<String, dynamic>> get trackingUpdates {
    if (currentOrder?.trackingUpdates == null) return [];

    try {
      final trackingData = currentOrder!.trackingUpdates;

      // Handle if it's already parsed as List
      if (trackingData is List) {
        return trackingData.cast<Map<String, dynamic>>();
      }

      // Return empty list for malformed data
      return [];
    } catch (e) {
      // If parsing fails, return basic tracking info
      return [
        {
          'timestamp': currentOrder!.createdAt.toIso8601String(),
          'status': 'pending',
          'message': 'Order created',
        }
      ];
    }
  }

  /// Get formatted order summary - ✅ Backend Compatible
  Map<String, dynamic> get orderSummary {
    if (currentOrder == null) return {};

    final order = currentOrder!;

    return {
      'orderId': order.id,
      'orderCode': 'ORD-${order.id.toString().padLeft(6, '0')}',
      'storeId': order.storeId,
      'totalAmount': order.totalAmount,
      'deliveryFee': order.deliveryFee,
      'grandTotal': (order.totalAmount) + (order.deliveryFee),
      'orderStatus': orderStatusDisplay,
      'deliveryStatus': deliveryStatusDisplay,
      'createdAt': order.createdAt,
      'estimatedPickupTime': order.estimatedPickupTime,
      'estimatedDeliveryTime': order.estimatedDeliveryTime,
      'actualPickupTime': order.actualPickupTime,
      'actualDeliveryTime': order.actualDeliveryTime,
      'canCancel': canCancelOrder,
      'canTrack': canTrackOrder,
      'canReview': canReviewOrder,
      'hasDriver': order.driverId != null,
      'trackingUpdates': trackingUpdates,
      'userRole': currentUserRole,
    };
  }

  // ✅ DIALOG HELPERS

  Future<bool?> _showCancelConfirmationDialog() async {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 8),
            Text(
              'Order ID: ORD-${currentOrder!.id.toString().padLeft(6, '0')}',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Total: ${formatCurrency((currentOrder!.totalAmount) + (currentOrder!.deliveryFee))}',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showCancelReasonDialog() async {
    String? selectedReason;

    // ✅ Get cancellation reasons from repository based on current user role
    final reasons = _orderRepository.getCancellationReasons(currentUserRole);

    return Get.dialog<String>(
      AlertDialog(
        title: const Text('Cancel Reason'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please select a reason for cancellation:'),
            const SizedBox(height: 16),
            ...reasons.map(
              (reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) {
                  selectedReason = value;
                  Get.back(result: value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ✅ UTILITY METHODS

  /// Format currency display
  String formatCurrency(double? amount) {
    if (amount == null) return 'Rp 0';
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// Format date time display
  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
    }
  }

  /// Show success message
  void showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show error message
  void showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
