// lib/data/models/order/create_order_request.dart - UPDATED VERSION
import 'cart_item_model.dart';

class CreateOrderRequest {
  final int storeId;
  final List<OrderItemRequest> items;

  CreateOrderRequest({
    required this.storeId,
    required this.items,
  });

  // ✅ ADD: Factory method untuk convert dari cart items
  factory CreateOrderRequest.fromCartItems({
    required int storeId,
    required List<CartItemModel> cartItems,
  }) {
    final orderItems = cartItems
        .map((cartItem) => OrderItemRequest(
              menuItemId: cartItem.menuItemId,
              quantity: cartItem.quantity,
              notes: cartItem.notes ?? '',
            ))
        .toList();

    return CreateOrderRequest(
      storeId: storeId,
      items: orderItems,
    );
  }

  // ✅ FIXED: Backend expects this exact format
  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId, // ✅ Backend expects store_id
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) {
    return CreateOrderRequest(
      storeId: json['store_id'] as int,
      items: (json['items'] as List)
          .map(
              (item) => OrderItemRequest.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + (item.price ?? 0) * item.quantity);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

// ✅ ORDER ITEM REQUEST - Backend Compatible
class OrderItemRequest {
  final int menuItemId;
  final int quantity;
  final String notes;
  final double? price; // Optional for calculations

  OrderItemRequest({
    required this.menuItemId,
    required this.quantity,
    required this.notes,
    this.price,
  });

  // ✅ Backend expects: { menu_item_id, quantity, notes }
  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory OrderItemRequest.fromJson(Map<String, dynamic> json) {
    return OrderItemRequest(
      menuItemId: json['menu_item_id'] as int,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  // ✅ From cart item
  factory OrderItemRequest.fromCartItem(CartItemModel cartItem) {
    return OrderItemRequest(
      menuItemId: cartItem.menuItemId,
      quantity: cartItem.quantity,
      notes: cartItem.notes ?? '',
      price: cartItem.price,
    );
  }
}
