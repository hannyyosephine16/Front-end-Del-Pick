// lib/features/customer/controllers/checkout_controller.dart (Debug Version)
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  final CartController _cartController = Get.find<CartController>();

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Order data
  late List<CartItemModel> cartItems;
  late int storeId;
  late String storeName;
  late double subtotal;
  late double serviceCharge;
  late double total;

  // Getters
  bool get isLoading => _isLoading.value;

  String get errorMessage => _errorMessage.value;

  bool get hasError => _hasError.value;

  @override
  void onInit() {
    super.onInit();
    _initializeOrderData();
  }

  void _initializeOrderData() {
    print('CheckoutController: Initializing order data...');

    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      print('CheckoutController: Using arguments data');
      cartItems = arguments['cartItems'] as List<CartItemModel>;
      storeId = arguments['storeId'] as int;
      storeName = arguments['storeName'] as String;
      subtotal = arguments['subtotal'] as double;
      serviceCharge = arguments['serviceCharge'] as double;
      total = arguments['total'] as double;
    } else {
      print('CheckoutController: Using cart controller data');
      cartItems = _cartController.cartItems;
      storeId = _cartController.currentStoreId;
      storeName = _cartController.currentStoreName;
      subtotal = _cartController.subtotal;
      serviceCharge = _cartController.serviceCharge;
      total = _cartController.total;
    }

    print('CheckoutController: Cart items count: ${cartItems.length}');
    print('CheckoutController: Store ID: $storeId');
    print('CheckoutController: Store name: $storeName');
    print('CheckoutController: Total: $total');
  }

  Future<void> placeOrderWithNotes({String? notes}) async {
    if (cartItems.isEmpty) {
      print('CheckoutController: Cart is empty, cannot place order');
      Get.snackbar('Error', 'Cart is empty');
      return;
    }

    print('CheckoutController: Starting order placement...');
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      // Prepare order data according to backend API
      final orderData = {
        'storeId': storeId,
        'notes': notes,
        'items': cartItems.map((item) => item.toApiJson()).toList(),
      };

      print('CheckoutController: Order data prepared:');
      print('  - Store ID: ${orderData['storeId']}');
      print('  - Items count: ${(orderData['items'] as List).length}');
      print('  - Notes: ${orderData['notes']}');
      print('  - Full data: $orderData');

      final result = await _orderRepository.createOrder(orderData);
      print('CheckoutController: API call completed');
      print('CheckoutController: Result success: ${result.isSuccess}');
      print('CheckoutController: Result message: ${result.message}');

      if (result.isSuccess && result.data != null) {
        final order = result.data!;
        print('CheckoutController: Order created successfully');
        print('CheckoutController: Order ID: ${order.id}');
        print('CheckoutController: Order code: ${order.code}');

        // Clear cart
        _cartController.clearCart();
        print('CheckoutController: Cart cleared');

        // Show success message
        Get.snackbar(
          'Success!',
          'Order placed successfully! Order #${order.code}',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Navigate to order tracking or order detail
        print('CheckoutController: Navigating to order detail...');
        Get.offAllNamed('/customer/order_detail', arguments: {
          'orderId': order.id,
          'orderCode': order.code,
        });
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to place order';

        print(
            'CheckoutController: Order placement failed: ${_errorMessage.value}');

        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'An error occurred: ${e.toString()}';

      print('CheckoutController: Exception occurred: $e');
      print('CheckoutController: Stack trace: ${StackTrace.current}');

      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isLoading.value = false;
      print('CheckoutController: Order placement process completed');
    }
  }

  // Missing getters and methods
  String get deliveryAddress => 'Institut Teknologi Del';

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool get isPlacingOrder => _isLoading.value;

  // Notes handling
  final RxString _notes = ''.obs;

  String get notes => _notes.value;

  void updateNotes(String newNotes) {
    _notes.value = newNotes;
  }

  // Formatting methods
  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';

  String get formattedServiceCharge => 'Rp ${serviceCharge.toStringAsFixed(0)}';

  String get formattedTotal => 'Rp ${total.toStringAsFixed(0)}';

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Updated placeOrder method to use notes
  Future<void> placeOrder() async {
    await placeOrderWithNotes(
        notes: _notes.value.isEmpty ? null : _notes.value);
  }

// Rename the original placeOrder method
// Future<void> placeOrderWithNotes({String? notes}) async {
// }
}
