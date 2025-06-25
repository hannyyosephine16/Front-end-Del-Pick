// lib/data/models/order/single_order_response.dart
import 'package:del_pick/data/models/order/order_model.dart';

class SingleOrderResponse {
  final OrderModel order;
  final String message;

  SingleOrderResponse({
    required this.order,
    required this.message,
  });

  factory SingleOrderResponse.fromJson(Map<String, dynamic> json) {
    return SingleOrderResponse(
      order: OrderModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String? ?? 'Success',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': order.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'SingleOrderResponse(message: $message, orderId: ${order.id})';
  }
}
