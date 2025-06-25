// lib/features/customer/controllers/checkout_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/services/api/order_service.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/app/routes/app_routes.dart';

/// ✅ Checkout Controller yang sesuai dengan backend DelPick API
class CheckoutController extends GetxController {
  final OrderApiService _orderApiService = Get.find<OrderApiService>();
  final CartController _cartController = Get.find<CartController>();

  // Observables
  final RxBool _isLoading = false.obs;
  final RxString _deliveryNotes = ''.obs;
  final RxDouble _estimatedDeliveryFee = 0.0.obs;
  final RxDouble _estimatedTotal = 0.0.obs;

  // Arguments dari cart
  late List<CartItemModel> cartItems;
  late int storeId;
  late String storeName;
  late double subtotal;

  // Getters
  bool get isLoading => _isLoading.value;
  String get deliveryNotes => _deliveryNotes.value;
  double get estimatedDeliveryFee => _estimatedDeliveryFee.value;
  double get estimatedTotal => _estimatedTotal.value;

  // Formatted getters untuk UI
  String get formattedSubtotal => _formatCurrency(subtotal);
  String get formattedDeliveryFee =>
      _formatCurrency(_estimatedDeliveryFee.value);
  String get formattedTotal => _formatCurrency(_estimatedTotal.value);

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _calculateEstimatedTotal();
  }

  /// ✅ Initialize data dari arguments
  void _initializeData() {
    final arguments = Get.arguments as Map<String, dynamic>;
    cartItems = arguments['cartItems'] as List<CartItemModel>;
    storeId = arguments['storeId'] as int;
    storeName = arguments['storeName'] as String;
    subtotal = arguments['subtotal'] as double;
  }

  /// ✅ Calculate estimated total (subtotal + estimated delivery fee)
  void _calculateEstimatedTotal() {
    // Estimasi delivery fee berdasarkan jarak (akan dihitung akurat di backend)
    // Untuk now, gunakan estimasi flat rate atau berdasarkan zona
    _estimatedDeliveryFee.value = _calculateEstimatedDeliveryFee();
    _estimatedTotal.value = subtotal + _estimatedDeliveryFee.value;
  }

  /// ✅ Estimasi delivery fee (placeholder, backend akan hitung yang akurat)
  double _calculateEstimatedDeliveryFee() {
    // Estimasi berdasarkan subtotal atau flat rate
    // Backend akan hitung berdasarkan jarak sebenarnya
    if (subtotal >= 50000) {
      return 5000; // Free delivery untuk order > 50k
    } else if (subtotal >= 25000) {
      return 10000; // Discount delivery
    } else {
      return 15000; // Normal delivery fee
    }
  }

  /// ✅ Format currency helper
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// ✅ Set delivery notes
  void setDeliveryNotes(String notes) {
    _deliveryNotes.value = notes;
  }

  /// ✅ Validate checkout form
  bool validateCheckout() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Cart is empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate menggunakan method dari CartItemModel
    final validation = CartItemModel.validateForOrder(cartItems);
    if (!validation['isValid']) {
      Get.snackbar(
        'Invalid Cart',
        validation['errors'].join(', '),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// ✅ Show order confirmation dialog
  Future<void> showOrderConfirmation() async {
    if (!validateCheckout()) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Order'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Store: $storeName',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Items: ${cartItems.length} item(s)'),
              Text(
                  'Quantity: ${CartItemModel.calculateTotalQuantity(cartItems)}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:'),
                  Text(formattedSubtotal),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery Fee (est.):'),
                  Text(formattedDeliveryFee),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total (est.):',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(formattedTotal,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              if (_deliveryNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: $_deliveryNotes'),
              ],
              const SizedBox(height: 8),
              const Text(
                '* Delivery fee will be calculated based on actual distance from store to destination.',
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                '* Payment: Cash on Delivery',
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Place Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await placeOrder();
    }
  }

  /// ✅ MAIN: Place order sesuai dengan backend API DelPick
  Future<void> placeOrder() async {
    if (_isLoading.value) return;

    try {
      _isLoading.value = true;

      // Show loading dialog
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Placing order...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // ✅ Format data sesuai dengan backend API DelPick
      // Backend expects: { store_id, items: [{ menu_item_id, quantity, notes }] }
      final orderData = {
        'store_id': storeId,
        'items': cartItems.map((item) => item.toApiJson()).toList(),
      };

      // ✅ Call API dengan format yang benar
      final order = await _orderApiService.placeOrder(
        storeId: storeId,
        items: orderData['items'] as List<Map<String, dynamic>>,
      );

      // Close loading dialog
      Get.back();

      // Clear cart setelah order berhasil
      _cartController.clearCart();

      // Show success message
      Get.snackbar(
        'Success',
        'Order placed successfully! Order ID: ${order.id}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate ke order tracking/detail screen
      Get.offAllNamed(
        Routes.ORDER_TRACKING,
        arguments: {
          'orderId': order.id,
          'order': order,
        },
      );
    } catch (e) {
      // Close loading dialog jika masih ada
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to place order: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// ✅ Get order summary untuk display di UI
  Map<String, dynamic> getOrderSummary() {
    return {
      'store_name': storeName,
      'store_id': storeId,
      'item_count': cartItems.length,
      'total_quantity': CartItemModel.calculateTotalQuantity(cartItems),
      'subtotal': subtotal,
      'estimated_delivery_fee': _estimatedDeliveryFee.value,
      'estimated_total': _estimatedTotal.value,
      'formatted_subtotal': formattedSubtotal,
      'formatted_delivery_fee': formattedDeliveryFee,
      'formatted_total': formattedTotal,
      'delivery_notes': _deliveryNotes.value,
      'items': cartItems,
    };
  }

  /// ✅ Get cart items grouped by category untuk display
  Map<String, List<CartItemModel>> getItemsByCategory() {
    return CartItemModel.groupByCategory(cartItems);
  }

  /// ✅ Calculate savings (jika ada discount)
  double calculateSavings() {
    // Implementasi logic discount jika ada
    return 0.0;
  }

  /// ✅ Check jika eligible untuk free delivery
  bool isEligibleForFreeDelivery() {
    return subtotal >= 50000; // Free delivery untuk order > 50k
  }

  /// ✅ Get delivery fee breakdown
  Map<String, dynamic> getDeliveryFeeBreakdown() {
    return {
      'base_fee': 15000.0,
      'discount': isEligibleForFreeDelivery()
          ? 15000.0
          : (subtotal >= 25000 ? 5000.0 : 0.0),
      'final_fee': _estimatedDeliveryFee.value,
      'is_free': _estimatedDeliveryFee.value == 0,
      'is_discounted': subtotal >= 25000 && subtotal < 50000,
    };
  }

  /// ✅ Validate individual item in cart
  bool validateCartItem(CartItemModel item) {
    if (!item.isValid) return false;
    if (!item.isAvailable) return false;
    if (item.quantity <= 0) return false;
    return true;
  }

  /// ✅ Get invalid items in cart
  List<CartItemModel> getInvalidItems() {
    return cartItems.where((item) => !validateCartItem(item)).toList();
  }

  /// ✅ Refresh item availability (jika diperlukan)
  Future<void> refreshItemAvailability() async {
    // TODO: Implement check availability dengan API jika diperlukan
    // Untuk sekarang, assume semua item available
  }

  /// ✅ Calculate tax (jika ada)
  double calculateTax() {
    // Implementasi tax calculation jika diperlukan
    return 0.0;
  }

  /// ✅ Get payment summary
  Map<String, dynamic> getPaymentSummary() {
    final tax = calculateTax();
    final finalTotal = subtotal + _estimatedDeliveryFee.value + tax;

    return {
      'subtotal': subtotal,
      'delivery_fee': _estimatedDeliveryFee.value,
      'tax': tax,
      'total': finalTotal,
      'formatted_subtotal': _formatCurrency(subtotal),
      'formatted_delivery_fee': _formatCurrency(_estimatedDeliveryFee.value),
      'formatted_tax': _formatCurrency(tax),
      'formatted_total': _formatCurrency(finalTotal),
      'payment_method': 'Cash on Delivery',
    };
  }

  /// ✅ Handle back navigation
  void onBackPressed() {
    Get.back();
  }

  /// ✅ Edit cart (navigate back ke cart)
  void editCart() {
    Get.back();
  }
}
