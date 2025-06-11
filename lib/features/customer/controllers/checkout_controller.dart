// lib/features/customer/controllers/checkout_controller.dart - OPTIMIZED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  // ✅ LAZY: Repositories akan di-inject saat dibutuhkan
  late final _orderRepository = Get.find();
  late final _cartController = Get.find<CartController>();

  // ✅ Simplified state
  final RxBool _isPlacingOrder = false.obs;
  final RxString _notes = ''.obs;
  final RxString _deliveryAddress = 'Institut Teknologi Del'.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Getters
  bool get isPlacingOrder => _isPlacingOrder.value;
  bool get isLoading => _isPlacingOrder.value;
  String get notes => _notes.value;
  String get deliveryAddress => _deliveryAddress.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;

  // ✅ Direct access to cart (no duplicate data)
  List<CartItemModel> get cartItems => _cartController.cartItems;
  int get storeId => _cartController.currentStoreId;
  String get storeName => _cartController.currentStoreName;
  double get subtotal => _cartController.subtotal;
  double get serviceCharge => _cartController.serviceCharge;
  double get total => _cartController.total;
  bool get isEmpty => _cartController.isEmpty;
  bool get canPlaceOrder => !isEmpty && !isLoading && !hasError;

  @override
  void onInit() {
    super.onInit();
    _clearError();
  }

  void updateNotes(String newNotes) {
    _notes.value = newNotes.trim();
    _clearError();
  }

  // ✅ MAIN OPTIMIZED METHOD: Simplified error handling
  Future<void> placeOrder() async {
    if (!_validateOrder()) return;

    _setLoading(true);
    _clearError();

    try {
      final orderData = _prepareOrderData();
      final result = await _orderRepository.createOrder(orderData);

      if (result.isSuccess && result.data != null) {
        await _handleOrderSuccess(result.data!);
      } else {
        _handleOrderFailure(result.message);
      }
    } catch (e) {
      _handleOrderError(e);
    } finally {
      _setLoading(false);
    }
  }

  // ✅ SIMPLIFIED: Essential validation only
  bool _validateOrder() {
    _clearError();

    if (isEmpty) {
      _setError('Your cart is empty');
      _showErrorSnackbar('Cart Empty', 'Please add items to your cart');
      return false;
    }

    if (storeId <= 0) {
      _setError('Invalid store selected');
      return false;
    }

    if (total <= 0) {
      _setError('Invalid order total');
      return false;
    }

    return true;
  }

  Map<String, dynamic> _prepareOrderData() {
    final orderData = <String, dynamic>{
      'storeId': storeId,
      'items': cartItems.map((item) => item.toApiJson()).toList(),
    };

    if (notes.isNotEmpty) {
      orderData['notes'] = notes;
    }

    return orderData;
  }

  Future<void> _handleOrderSuccess(OrderModel order) async {
    _cartController.clearCart();

    Get.snackbar(
      'Order Placed! 🎉',
      'Your order ${order.code} is being processed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    Get.offNamed('/order_tracking', arguments: {
      'orderId': order.id,
      'orderCode': order.code,
    });
  }

  void _handleOrderFailure(String? message) {
    final errorMsg = message ?? 'Failed to place order';
    _setError(errorMsg);
    _showErrorSnackbar('Order Failed', errorMsg);
  }

  void _handleOrderError(dynamic error) {
    _setError('Connection error. Please try again.');
    _showErrorSnackbar('Connection Error', 'Please check your connection');
  }

  // ✅ Helper methods
  void _setLoading(bool loading) => _isPlacingOrder.value = loading;
  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
  }

  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> retryOrder() => placeOrder();

  // Formatting getters
  String get formattedSubtotal => _cartController.formattedSubtotal;
  String get formattedServiceCharge => _cartController.formattedServiceCharge;
  String get formattedTotal => _cartController.formattedTotal;
}
