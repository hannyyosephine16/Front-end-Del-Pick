// lib/features/customer/controllers/order_controller.dart - NEW FILE
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/app/routes/app_routes.dart';
import 'package:del_pick/data/repositories/order_repository.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/order/order_model_extensions.dart'; // ✅ ADD THIS
import 'package:del_pick/core/errors/error_handler.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository;

  OrderController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  // Observable state
  final RxBool _isLoading = false.obs;
  final Rx<OrderModel?> _currentOrder = Rx<OrderModel?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  OrderModel? get currentOrder => _currentOrder.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['orderId'] != null) {
      loadOrderDetail(arguments['orderId']);
    }
  }

  Future<void> loadOrderDetail(int orderId) async {
    _isLoading.value = true;
    _hasError.value = false;

    try {
      final result = await _orderRepository.getOrderDetail(orderId);

      if (result.isSuccess && result.data != null) {
        _currentOrder.value = result.data!;
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to load order';
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = ErrorHandler.getErrorMessage(
          ErrorHandler.handleException(e as Exception));
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelOrder() async {
    if (currentOrder == null || !currentOrder!.canCancel) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
            'Are you sure you want to cancel order ${currentOrder!.code}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _orderRepository.cancelOrder(currentOrder!.id);

        if (result.isSuccess) {
          _currentOrder.value = result.data!;
          Get.snackbar('Success', 'Order cancelled successfully');
        } else {
          Get.snackbar('Error', result.message ?? 'Failed to cancel order');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to cancel order');
      }
    }
  }

  void navigateToTracking() {
    if (currentOrder != null && currentOrder!.canTrack) {
      Get.toNamed(Routes.ORDER_TRACKING, arguments: {
        'orderId': currentOrder!.id,
      });
    }
  }

  void navigateToReview() {
    if (currentOrder != null && currentOrder!.isDelivered) {
      Get.toNamed(Routes.REVIEW, arguments: {
        'orderId': currentOrder!.id,
      });
    }
  }
}
