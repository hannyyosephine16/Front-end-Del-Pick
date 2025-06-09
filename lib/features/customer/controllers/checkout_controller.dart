// lib/features/customer/controllers/checkout_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  final CartController _cartController = Get.find<CartController>();

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxString _deliveryAddress = 'Institut Teknologi Del'.obs;
  final RxString _notes = ''.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get deliveryAddress => _deliveryAddress.value;
  String get notes => _notes.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;

  // Customer location (default IT Del coordinates)
  double get customerLatitude => AppConstants.defaultLatitude;
  double get customerLongitude => AppConstants.defaultLongitude;

  // Get cart data
  List<CartItemModel> get cartItems => _cartController.cartItems;
  int get storeId => _cartController.currentStoreId;
  String get storeName => _cartController.currentStoreName;
  double get subtotal => _cartController.subtotal;
  double get serviceCharge => _cartController.serviceCharge;
  double get total => _cartController.total;

  @override
  void onInit() {
    super.onInit();
    _initializeCheckout();
  }

  void _initializeCheckout() {
    // Set default delivery address to IT Del
    _deliveryAddress.value = 'Institut Teknologi Del';
    print(
        'CheckoutController: Initialized with default address: ${_deliveryAddress.value}');
    print(
        'CheckoutController: Customer coordinates: $customerLatitude, $customerLongitude');
  }

  void updateNotes(String newNotes) {
    _notes.value = newNotes;
  }

  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress.value = newAddress;
  }

  Future<void> placeOrder() async {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Cart is empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      // Prepare order data according to API requirements
      final orderData = _prepareOrderData();

      print('CheckoutController: Order data prepared:');
      print('- Store ID: ${orderData['storeId']}');
      print('- Items count: ${orderData['items'].length}');
      print('- Notes: ${orderData['notes']}');
      print('- Delivery Address: ${orderData['deliveryAddress']}');
      print('- Customer Latitude: ${orderData['customerLatitude']}');
      print('- Customer Longitude: ${orderData['customerLongitude']}');
      print('- Full data: $orderData');

      // Create order
      final result = await _orderRepository.createOrder(orderData);

      print('CheckoutController: API call completed');
      print('CheckoutController: Result success: ${result.isSuccess}');
      print('CheckoutController: Result message: ${result.message}');

      if (result.isSuccess && result.data != null) {
        final order = result.data!;
        print(
            'CheckoutController: Order created successfully with ID: ${order.id}');

        // Clear cart after successful order
        _cartController.clearCart();

        // Show success message
        Get.snackbar(
          'Order Placed',
          'Your order has been placed successfully! Order ID: ${order.code}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // Navigate to order tracking or order detail
        Get.offNamed(
          '/order_detail',
          arguments: {'orderId': order.id, 'orderCode': order.code},
        );
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to place order';
        print(
            'CheckoutController: Order placement failed: ${_errorMessage.value}');

        Get.snackbar(
          'Order Failed',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'An error occurred while placing order';
      print('CheckoutController: Exception during order placement: $e');

      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Map<String, dynamic> _prepareOrderData() {
    // Convert cart items to API format
    final items = cartItems.map((item) => item.toApiJson()).toList();

    final orderData = {
      'storeId': storeId,
      'deliveryAddress': _deliveryAddress.value,
      'customerLatitude': customerLatitude,
      'customerLongitude': customerLongitude,
      'notes': _notes.value.isEmpty
          ? ''
          : _notes.value, // Always send as string, never null
      'items': items,
    };

    return orderData;
  }

  // Validate order before placing
  bool _validateOrder() {
    if (cartItems.isEmpty) {
      _errorMessage.value = 'Cart is empty';
      return false;
    }

    if (storeId == 0) {
      _errorMessage.value = 'Invalid store selected';
      return false;
    }

    if (_deliveryAddress.value.isEmpty) {
      _errorMessage.value = 'Delivery address is required';
      return false;
    }

    return true;
  }

  // Format currency for display
  String get formattedSubtotal =>
      'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get formattedServiceCharge =>
      'Rp ${serviceCharge.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get formattedTotal =>
      'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}
