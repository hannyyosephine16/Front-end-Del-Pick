// lib/data/models/order/order_item_model.dart - FIXED VERSION
class OrderItemModel {
  final int id;
  final int orderId;
  final int? menuItemId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? category;
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
}
