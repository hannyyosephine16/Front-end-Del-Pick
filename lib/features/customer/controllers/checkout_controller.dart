import 'package:get/get.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/app/routes/app_routes.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepository;
  final CartController _cartController;

  CheckoutController({
    required OrderRepository orderRepository,
    required CartController cartController,
  })  : _orderRepository = orderRepository,
        _cartController = cartController;

  // Observable state
  final RxBool _isPlacingOrder = false.obs;
  final RxString _notes = ''.obs;
  final RxString _deliveryAddress = 'Institut Teknologi Del'.obs;

  // Getters
  bool get isPlacingOrder => _isPlacingOrder.value;
  String get notes => _notes.value;
  String get deliveryAddress => _deliveryAddress.value;

  // Cart info
  List get cartItems => _cartController.cartItems;
  int get storeId => _cartController.currentStoreId;
  String get storeName => _cartController.currentStoreName;
  double get subtotal => _cartController.subtotal;
  double get serviceCharge => _cartController.serviceCharge;
  double get total => _cartController.total;
  int get itemCount => _cartController.itemCount;

  void updateNotes(String value) {
    _notes.value = value;
  }

  void updateDeliveryAddress(String value) {
    _deliveryAddress.value = value;
  }

  Future<void> placeOrder() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return;
    }

    _isPlacingOrder.value = true;

    try {
      // Prepare order data according to backend API
      final orderData = {
        'storeId': storeId,
        'notes': notes.isEmpty ? null : notes,
        'items': cartItems.map((item) => item.toApiJson()).toList(),
      };

      final result = await _orderRepository.createOrder(orderData);

      if (result.isSuccess && result.data != null) {
        final order = result.data!;

        // Clear cart after successful order
        _cartController.clearCart();

        // Show success message
        Get.snackbar(
          'Order Placed',
          'Your order has been placed successfully!',
          snackPosition: SnackPosition.TOP,
        );

        // Navigate to order detail or order history
        Get.offAllNamed(
          Routes.ORDER_DETAIL,
          arguments: {'orderId': order.id},
        );
      } else {
        Get.snackbar(
          'Order Failed',
          result.message ?? 'Failed to place order',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred';

      if (e is Exception) {
        final failure = ErrorHandler.handleException(e);
        errorMessage = ErrorHandler.getErrorMessage(failure);
      }

      Get.snackbar(
        'Order Failed',
        errorMessage,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isPlacingOrder.value = false;
    }
  }

  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';
  String get formattedServiceCharge => 'Rp ${serviceCharge.toStringAsFixed(0)}';
  String get formattedTotal => 'Rp ${total.toStringAsFixed(0)}';
}
