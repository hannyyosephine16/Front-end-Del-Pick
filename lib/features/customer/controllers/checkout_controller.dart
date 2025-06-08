// lib/features/customer/controllers/checkout_controller.dart
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/core/errors/error_handler.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepository;
  final CartController cartController;

  CheckoutController({
    required OrderRepository orderRepository,
    required this.cartController,
  }) : _orderRepository = orderRepository;

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
  bool get canPlaceOrder => cartController.isNotEmpty && !_isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _validateCartItems();
  }

  void _validateCartItems() {
    if (cartController.isEmpty) {
      Get.back();
      Get.snackbar(
        'Error',
        'Your cart is empty',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateDeliveryAddress(String address) {
    _deliveryAddress.value = address;
  }

  void updateNotes(String newNotes) {
    _notes.value = newNotes;
  }

  Future<void> placeOrder() async {
    if (!canPlaceOrder) return;

    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      // Prepare order data according to backend API
      final orderData = {
        'storeId': cartController.currentStoreId,
        'notes': _notes.value.isNotEmpty ? _notes.value : null,
        'items':
            cartController.cartItems.map((item) => item.toApiJson()).toList(),
      };

      // Create order through repository
      final result = await _orderRepository.createOrder(orderData);

      if (result.isSuccess && result.data != null) {
        // Order created successfully
        final order = result.data!;

        // Clear cart
        cartController.clearCart();

        // Show success message
        Get.snackbar(
          'Success',
          'Order placed successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to order detail or order tracking
        Get.offAllNamed('/customer/home');
        Get.toNamed(
          '/order_detail',
          arguments: {'orderId': order.id},
        );
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to place order';

        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _hasError.value = true;

      if (e is Exception) {
        final failure = ErrorHandler.handleException(e);
        _errorMessage.value = ErrorHandler.getErrorMessage(failure);
      } else {
        _errorMessage.value = 'An unexpected error occurred';
      }

      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void retryPlaceOrder() {
    if (_hasError.value) {
      _hasError.value = false;
      _errorMessage.value = '';
      placeOrder();
    }
  }

  // Helper methods for order summary
  String get formattedSubtotal => cartController.formattedSubtotal;
  String get formattedServiceCharge => cartController.formattedServiceCharge;
  String get formattedTotal => cartController.formattedTotal;
  int get totalItems => cartController.itemCount;

  // Validation methods
  bool get isValidDeliveryAddress => _deliveryAddress.value.isNotEmpty;
  bool get hasValidItems => cartController.isNotEmpty;

  String? validateOrder() {
    if (!hasValidItems) {
      return 'No items in cart';
    }
    if (!isValidDeliveryAddress) {
      return 'Please select delivery address';
    }
    return null;
  }
}
