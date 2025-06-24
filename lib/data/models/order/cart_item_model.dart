import 'package:del_pick/core/utils/parsing_helper.dart';

class CartItemModel {
  final int? id;
  final int menuItemId;
  final int storeId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? notes;
  final DateTime? createdAt;

  CartItemModel({
    this.id,
    required this.menuItemId,
    required this.storeId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.notes,
    this.createdAt,
  });

  // ✅ FIXED: Safe parsing using ParsingHelper
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: ParsingHelper.parseInt(json['id']),
      menuItemId: ParsingHelper.parseIntWithDefault(
          json['menu_item_id'] ?? json['menuItemId'], 0),
      storeId: ParsingHelper.parseIntWithDefault(
          json['store_id'] ?? json['storeId'], 0),
      name: json['name'] as String? ?? '',
      price: ParsingHelper.parseDoubleWithDefault(json['price'], 0.0),
      quantity: ParsingHelper.parseIntWithDefault(json['quantity'], 1),
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'store_id': storeId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // ✅ Backend expects this exact format for place order API
  Map<String, dynamic> toApiJson() {
    return {
      'menu_item_id': menuItemId, // ✅ Backend expects menu_item_id
      'quantity': quantity, // ✅ Backend expects quantity
      'notes': notes, // ✅ Backend expects notes (optional)
    };
  }

  CartItemModel copyWith({
    int? id,
    int? menuItemId,
    int? storeId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? notes,
    DateTime? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get totalPrice => price * quantity;

  String get formattedPrice =>
      'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  String get formattedTotalPrice =>
      'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  factory CartItemModel.fromMenuItem({
    required int menuItemId,
    required int storeId,
    required String name,
    required double price,
    required int quantity,
    String? imageUrl,
    String? notes,
  }) {
    return CartItemModel(
      menuItemId: menuItemId,
      storeId: storeId,
      name: name,
      price: price,
      quantity: quantity,
      imageUrl: imageUrl,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          menuItemId == other.menuItemId;

  @override
  int get hashCode => menuItemId.hashCode;

  @override
  String toString() {
    return 'CartItemModel{menuItemId: $menuItemId, name: $name, quantity: $quantity, price: $price}';
  }
}
