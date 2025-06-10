// lib/features/customer/controllers/checkout_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/core/services/external/location_service.dart';
import 'package:del_pick/core/utils/result.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  final CartController _cartController = Get.find<CartController>();
  final LocationService _locationService = Get.find<LocationService>();

  // Observable state
  final RxBool _isPlacingOrder = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _notes = ''.obs;
  final RxString _deliveryAddress = 'Institut Teknologi Del'.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Getters
  bool get isPlacingOrder => _isPlacingOrder.value;
  bool get isLoading => _isLoading.value;
  String get notes => _notes.value;
  String get deliveryAddress => _deliveryAddress.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;

  // Cart data getters
  List<CartItemModel> get cartItems => _cartController.cartItems;
  int get storeId => _cartController.currentStoreId;
  String get storeName => _cartController.currentStoreName;
  double get subtotal => _cartController.subtotal;
  double get serviceCharge => _cartController.serviceCharge;
  double get total => _cartController.total;
  bool get isEmpty => _cartController.isEmpty;

  @override
  void onInit() {
    super.onInit();
    _clearError();
    print('CheckoutController: Initialized');
  }

  // Update methods
  void updateNotes(String newNotes) {
    _notes.value = newNotes.trim();
    _clearError(); // Clear error when user makes changes
    print('CheckoutController: Notes updated: "${_notes.value}"');
  }

  void updateDeliveryAddress(String address) {
    _deliveryAddress.value = address.trim();
    _clearError();
    print(
        'CheckoutController: Delivery address updated: "${_deliveryAddress.value}"');
  }

  // Main order placement method
  // Future<void> placeOrder() async {
  //   print('CheckoutController: Starting order placement...');
  //
  //   // Validate order before processing
  //   if (!_validateOrder()) {
  //     return;
  //   }
  //
  //   _setLoading(true);
  //   _clearError();
  //
  //   try {
  //     // Get current location (for logging purposes)
  //     try {
  //       final position = await _locationService.getCurrentLocation();
  //       print(
  //           'CheckoutController: Current location obtained: ${position?.latitude}, ${position?.longitude}');
  //     } catch (e) {
  //       print(
  //           'CheckoutController: Could not get location, continuing anyway: $e');
  //     }
  //
  //     // Prepare order data - only send what backend needs
  //     final orderData = _prepareOrderData();
  //
  //     print('CheckoutController: Placing order with data: $orderData');
  //
  //     // Create order via API
  //     final result = await _orderRepository.createOrder(orderData);
  //
  //     await _handleOrderResult(result);
  //   } catch (e) {
  //     await _handleOrderError(e);
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Validation method
  bool _validateOrder() {
    _clearError();

    // Check if cart is empty
    if (isEmpty) {
      _setError('Your cart is empty. Please add items before checkout.');
      _showErrorSnackbar(
          'Cart Empty', 'Please add items to your cart before checkout.');
      return false;
    }

    // Check if store ID is valid
    if (storeId <= 0) {
      _setError('Invalid store selected. Please try again.');
      _showErrorSnackbar('Invalid Store', 'Please select a valid store.');
      return false;
    }

    // Check if all cart items are valid
    for (final item in cartItems) {
      if (item.quantity <= 0) {
        _setError('Invalid item quantity detected.');
        _showErrorSnackbar('Invalid Quantity',
            'All items must have a quantity greater than 0.');
        return false;
      }

      // Check if menuItemId is valid (for API itemId field)
      if (item.menuItemId <= 0) {
        _setError('Invalid menu item detected.');
        _showErrorSnackbar('Invalid Item', 'One or more items are invalid.');
        return false;
      }
    }

    // Validate total amount
    if (total <= 0) {
      _setError('Invalid order total amount.');
      _showErrorSnackbar(
          'Invalid Total', 'Order total must be greater than 0.');
      return false;
    }

    print('CheckoutController: Order validation passed');
    print('- Items count: ${cartItems.length}');
    print('- Store ID: $storeId');
    print('- Total: Rp ${total.toStringAsFixed(0)}');
    print('- Notes: "${notes.isEmpty ? 'No notes' : notes}"');
    print(
        '- Sample item format: {itemId: ${cartItems.first.menuItemId}, quantity: ${cartItems.first.quantity}}');

    return true;
  }

  // Prepare order data for API (only what backend needs)
  Map<String, dynamic> _prepareOrderData() {
    print('CheckoutController: DEBUG - Raw cart items:');
    for (int i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      print(
          '  Item $i: {menuItemId: ${item.menuItemId}, name: "${item.name}", quantity: ${item.quantity}}');

      final apiJson = item.toApiJson();
      print('  Item $i toApiJson(): $apiJson');
    }

    final orderData = <String, dynamic>{
      'storeId': storeId,
      'items': cartItems.map((item) => item.toApiJson()).toList(),
    };

    if (notes.isNotEmpty) {
      orderData['notes'] = notes;
    }

    print('CheckoutController: DEBUG - Final order data:');
    print('- Store ID: ${orderData['storeId']}');
    print('- Items JSON: ${orderData['items']}');
    print('- Items type: ${orderData['items'].runtimeType}');
    print(
        '- Notes: ${orderData.containsKey('notes') ? orderData['notes'] : 'not included'}');
    print('- Full orderData: $orderData');

    return orderData;
  }

// Also add this debug method to your placeOrder method, right before calling _orderRepository.createOrder:
  Future<void> placeOrder() async {
    print('CheckoutController: Starting order placement...');

    if (!_validateOrder()) {
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final orderData = _prepareOrderData();

      print('CheckoutController: 🔍 FINAL DEBUG BEFORE API CALL:');
      print('- Type: ${orderData.runtimeType}');
      print('- Keys: ${orderData.keys.toList()}');
      print(
          '- StoreId value: ${orderData['storeId']} (${orderData['storeId'].runtimeType})');
      print(
          '- Items value: ${orderData['items']} (${orderData['items'].runtimeType})');
      if (orderData.containsKey('notes')) {
        print(
            '- Notes value: ${orderData['notes']} (${orderData['notes'].runtimeType})');
      }

      // ✅ Make the API call
      final result = await _orderRepository.createOrder(orderData);

      print('CheckoutController: 📥 API RESULT:');
      print('- Success: ${result.isSuccess}');
      print('- Message: ${result.message}');
      print('- Data: ${result.data}');

      if (result.isSuccess && result.data != null) {
        await _handleOrderSuccess(result.data!);
      } else {
        print(
            'CheckoutController: ❌ ORDER FAILED WITH MESSAGE: ${result.message}');
        await _handleOrderFailure(result.message);
      }
    } catch (e, stackTrace) {
      print('CheckoutController: 💥 EXCEPTION CAUGHT: $e');
      print('CheckoutController: 📍 STACK TRACE: $stackTrace');
      await _handleOrderError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Handle successful/failed order result
  Future<void> _handleOrderResult(Result<OrderModel> result) async {
    print('CheckoutController: API call completed');
    print('CheckoutController: Result success: ${result.isSuccess}');
    print('CheckoutController: Result message: ${result.message}');

    if (result.isSuccess && result.data != null) {
      await _handleOrderSuccess(result.data!);
    } else {
      await _handleOrderFailure(result.message);
    }
  }

  // Handle successful order
  Future<void> _handleOrderSuccess(OrderModel order) async {
    print('CheckoutController: Order created successfully');
    print('- Order ID: ${order.id}');
    print('- Order Code: ${order.code}');

    // Clear cart after successful order
    _cartController.clearCart();
    print('CheckoutController: Cart cleared');

    // Show success message
    Get.snackbar(
      'Order Placed Successfully! 🎉',
      'Your order ${order.code} has been placed and is being processed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );

    // Navigate to order tracking with a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    Get.offNamed('/order_tracking', arguments: {
      'orderId': order.id,
      'orderCode': order.code,
    });
  }

  // Handle order failure
  Future<void> _handleOrderFailure(String? message) async {
    final errorMsg = message ?? 'Failed to place order. Please try again.';
    _setError(errorMsg);

    print('CheckoutController: Order placement failed: $errorMsg');

    _showErrorSnackbar(
      'Order Failed',
      errorMsg,
      duration: const Duration(seconds: 5),
    );
  }

  // Handle unexpected errors
  Future<void> _handleOrderError(dynamic error) async {
    final errorMsg =
        'An unexpected error occurred. Please check your connection and try again.';
    _setError(errorMsg);

    print('CheckoutController: Exception during order placement: $error');

    _showErrorSnackbar(
      'Connection Error',
      errorMsg,
      backgroundColor: Colors.orange,
    );
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isPlacingOrder.value = loading;
    _isLoading.value = loading;
  }

  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
  }

  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  // Helper method for showing error snackbars
  void _showErrorSnackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.red,
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(
        backgroundColor == Colors.orange ? Icons.warning : Icons.error,
        color: Colors.white,
      ),
    );
  }

  // Retry order placement
  Future<void> retryOrder() async {
    print('CheckoutController: Retrying order placement...');
    await placeOrder();
  }

  // Format currency for display
  String get formattedSubtotal => _cartController.formattedSubtotal;
  String get formattedServiceCharge => _cartController.formattedServiceCharge;
  String get formattedTotal => _cartController.formattedTotal;

  // Additional helper getters
  bool get canPlaceOrder => !isEmpty && !isLoading && !hasError;
  String get orderSummary =>
      'Items: ${cartItems.length}, Total: $formattedTotal';

  @override
  void onClose() {
    print('CheckoutController: Disposing...');
    super.onClose();
  }
}
