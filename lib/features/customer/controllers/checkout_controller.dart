// // lib/features/customer/controllers/checkout_controller.dart - FIXED VERSION
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:del_pick/data/models/order/cart_item_model.dart';
// import 'package:del_pick/data/models/order/order_model.dart';
// import 'package:del_pick/data/repositories/order_repository.dart';
// import 'package:del_pick/features/customer/controllers/cart_controller.dart';
//
// class CheckoutController extends GetxController {
//   final OrderRepository _orderRepository = Get.find<OrderRepository>();
//   final CartController _cartController = Get.find<CartController>();
//
//   final RxBool _isPlacingOrder = false.obs;
//   final RxString _notes = ''.obs;
//   final RxString _deliveryAddress = 'Institut Teknologi Del'.obs;
//   final RxString _errorMessage = ''.obs;
//   final RxBool _hasError = false.obs;
//
//   // Getters
//   bool get isPlacingOrder => _isPlacingOrder.value;
//   bool get isLoading => _isPlacingOrder.value;
//   String get notes => _notes.value;
//   String get deliveryAddress => _deliveryAddress.value;
//   String get errorMessage => _errorMessage.value;
//   bool get hasError => _hasError.value;
//
//   List<CartItemModel> get cartItems => _cartController.cartItems;
//   int get storeId => _cartController.currentStoreId;
//   String get storeName => _cartController.currentStoreName;
//   double get subtotal => _cartController.subtotal;
//   double get total => _cartController.total;
//   bool get isEmpty => _cartController.isEmpty;
//   bool get canPlaceOrder => !isEmpty && !isLoading && !hasError;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _clearError();
//   }
//
//   void updateNotes(String newNotes) {
//     _notes.value = newNotes.trim();
//     _clearError();
//   }
//
//   Future<void> placeOrder() async {
//     if (!_validateOrder()) return;
//
//     _setLoading(true);
//     _clearError();
//
//     try {
//       final orderData = _prepareOrderData();
//       print('CheckoutController: Placing order with data: $orderData');
//
//       final result = await _orderRepository.createOrder(orderData);
//
//       if (result.isSuccess && result.data != null) {
//         await _handleOrderSuccess(result.data!);
//       } else {
//         _handleOrderFailure(result.errorMessage);
//       }
//     } catch (e) {
//       print('CheckoutController: Exception: $e');
//       _handleOrderError(e);
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   bool _validateOrder() {
//     _clearError();
//
//     if (isEmpty) {
//       _setError('Your cart is empty');
//       _showErrorSnackbar('Cart Empty', 'Please add items to your cart');
//       return false;
//     }
//
//     if (storeId <= 0) {
//       _setError('Invalid store selected');
//       return false;
//     }
//
//     if (total <= 0) {
//       _setError('Invalid order total');
//       return false;
//     }
//
//     return true;
//   }
//
//   Map<String, dynamic> _prepareOrderData() {
//     // ✅ FIXED: Backend expects store_id not storeId
//     final orderData = <String, dynamic>{
//       'store_id': storeId, // ✅ Backend field name
//       'items': cartItems.map((item) => item.toApiJson()).toList(),
//     };
//
//     // ✅ Optional notes can be added to individual items via toApiJson()
//     if (notes.isNotEmpty) {
//       // Add global notes to first item if exists
//       if (orderData['items'].isNotEmpty) {
//         final firstItem = orderData['items'][0] as Map<String, dynamic>;
//         final existingNotes = firstItem['notes'] as String?;
//         firstItem['notes'] = existingNotes != null
//             ? '$existingNotes. Additional: $notes'
//             : notes;
//       }
//     }
//
//     return orderData;
//   }
//
//   Future<void> _handleOrderSuccess(OrderModel order) async {
//     _cartController.clearCart();
//
//     Get.snackbar(
//       'Order Placed! 🎉',
//       'Your order #${order.id} is being processed',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//     );
//
//     await Future.delayed(const Duration(milliseconds: 300));
//
//     // Navigation arguments
//     Get.offNamed('/order_tracking', arguments: {
//       'orderId': order.id,
//       'order': order, // Pass full order object
//     });
//   }
//
//   void _handleOrderFailure(String? message) {
//     final errorMsg = message ?? 'Failed to place order';
//     _setError(errorMsg);
//     _showErrorSnackbar('Order Failed', errorMsg);
//   }
//
//   void _handleOrderError(dynamic error) {
//     _setError('Connection error. Please try again.');
//     _showErrorSnackbar('Connection Error', 'Please check your connection');
//   }
//
//   void _setLoading(bool loading) => _isPlacingOrder.value = loading;
//
//   void _setError(String message) {
//     _hasError.value = true;
//     _errorMessage.value = message;
//   }
//
//   void _clearError() {
//     _hasError.value = false;
//     _errorMessage.value = '';
//   }
//
//   void _showErrorSnackbar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//     );
//   }
//
//   Future<void> retryOrder() => placeOrder();
//
//   String get formattedSubtotal =>
//       'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
//
//   String get formattedTotal =>
//       'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
// }
// lib/features/customer/controllers/checkout_controller.dart
// lib/features/customer/screens/checkout_screen.dart

// lib/features/customer/controllers/checkout_controller.dart
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
