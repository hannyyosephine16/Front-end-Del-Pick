// lib/data/models/order/create_order_request.dart
import 'cart_item_model.dart';

class CreateOrderRequest {
  final int storeId;
  final List<CartItemModel> items;

  CreateOrderRequest({
    required this.storeId,
    required this.items,
  });

  // ✅ FIXED: Backend expects this exact format
  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId, // ✅ Backend expects store_id
      'items':
          items.map((item) => item.toApiJson()).toList(), // ✅ Use toApiJson()
    };
  }

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) {
    return CreateOrderRequest(
      storeId: json['store_id'] as int,
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

// lib/data/models/order/order_item_model.dart - FIXED VERSION
class OrderItemModel {
  final int id;
  final int orderId;
  final int? menuItemId; // ✅ Backend allows null if item deleted
  final String name; // ✅ Backend stores snapshot
  final String? description; // ✅ Added from backend
  final String? imageUrl;
  final String? category; // ✅ Added from backend
  final double price;
  final int quantity;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItemModel({
    required this.id,
    required this.orderId,
    this.menuItemId,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    required this.price,
    required this.quantity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      menuItemId: json['menu_item_id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'price': price,
      'quantity': quantity,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get totalPrice => price * quantity;

  String get formattedPrice =>
      'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  String get formattedTotalPrice =>
      'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderItemModel{id: $id, name: $name, quantity: $quantity, price: $price}';
  }
}
