import 'package:del_pick/core/utils/parsing_helper.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int? menuItemId; // ✅ Can be null if menu item is deleted
  final String name; // ✅ Backend stores snapshot
  final String? description; // ✅ Backend field
  final String? imageUrl;
  final String category; // ✅ Backend field
  final int quantity;
  final double price;
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
    required this.category,
    required this.quantity,
    required this.price,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // ✅ FIXED: Safe parsing using ParsingHelper
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: ParsingHelper.parseIntWithDefault(json['id'], 0),
      orderId: ParsingHelper.parseIntWithDefault(json['order_id'], 0),
      menuItemId: ParsingHelper.parseInt(json['menu_item_id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String? ?? '',
      quantity: ParsingHelper.parseIntWithDefault(json['quantity'], 1),
      price: ParsingHelper.parseDoubleWithDefault(json['price'], 0.0),
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
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
      'quantity': quantity,
      'price': price,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods for UI
  double get totalPrice => price * quantity;

  String get formattedPrice =>
      'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  String get formattedTotalPrice =>
      'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  String get quantityText => '${quantity}x';
  bool get hasNotes => notes != null && notes!.isNotEmpty;

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