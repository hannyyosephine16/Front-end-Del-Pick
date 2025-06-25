import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/services/api/order_service.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class CheckoutController extends GetxController {
  final OrderApiService _orderApiService = Get.find<OrderApiService>();
  final CartController _cartController = Get.find<CartController>();

  // Observables
  final RxBool _isLoading = false.obs;
  final RxString _deliveryNotes = ''.obs;

  // Arguments from cart
  late List<CartItemModel> cartItems;
  late int storeId;
  late String storeName;
  late double subtotal;

  // Getters
  bool get isLoading => _isLoading.value;
  String get deliveryNotes => _deliveryNotes.value;

  // Formatted getters
  String get formattedSubtotal =>
      'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  void _initializeData() {
    final arguments = Get.arguments as Map<String, dynamic>;
    cartItems = arguments['cartItems'] as List<CartItemModel>;
    storeId = arguments['storeId'] as int;
    storeName = arguments['storeName'] as String;
    subtotal = arguments['subtotal'] as double;
  }

  void setDeliveryNotes(String notes) {
    _deliveryNotes.value = notes;
  }

  // ✅ MAIN: Place order dengan format backend API
  Future<void> placeOrder() async {
    if (_isLoading.value) return;

    try {
      _isLoading.value = true;

      // ✅ Prepare data dalam format yang diharapkan backend
      final orderItems = cartItems
          .map((item) =>
              item.toApiJson()) // Gunakan toApiJson() yang sudah sesuai backend
          .toList();

      // ✅ Call API dengan format yang benar
      final order = await _orderApiService.placeOrder(
        storeId: storeId,
        items: orderItems,
      );

      // Clear cart after successful order
      _cartController.clearCart();

      // Show success message
      Get.snackbar(
        'Success',
        'Order placed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to order tracking/detail screen
      Get.offAllNamed(
        Routes.ORDER_TRACKING,
        arguments: {'orderId': order.id},
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Validate checkout form
  bool validateCheckout() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Cart is empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  // Show order confirmation dialog
  Future<void> showOrderConfirmation() async {
    if (!validateCheckout()) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Store: $storeName'),
            Text('Items: ${cartItems.length}'),
            Text('Subtotal: $formattedSubtotal'),
            Text('Payment: Cash on Delivery'),
            if (_deliveryNotes.isNotEmpty) Text('Notes: $_deliveryNotes'),
            const SizedBox(height: 8),
            const Text(
              'Delivery fee will be calculated based on distance.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await placeOrder();
    }
  }

  // Get order summary for display
  Map<String, dynamic> getOrderSummary() {
    return {
      'store_name': storeName,
      'item_count': cartItems.length,
      'subtotal': subtotal,
      'formatted_subtotal': formattedSubtotal,
      'delivery_notes': _deliveryNotes.value,
      'items': cartItems,
    };
  }
}
