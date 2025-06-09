// lib/data/models/order/cart_item_model.dart
class CartItemModel {
  final int menuItemId;
  final int storeId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? notes;

  CartItemModel({
    required this.menuItemId,
    required this.storeId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.notes,
  });

  // Factory constructor from MenuItemModel
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
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      menuItemId: json['menuItemId'] as int,
      storeId: json['storeId'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'storeId': storeId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  // Method untuk API JSON (sesuai dengan struktur yang diharapkan backend)
  Map<String, dynamic> toApiJson() {
    return {
      'menuItemId': menuItemId,
      'quantity': quantity,
      'price': price,
      'notes': notes,
    };
  }

  CartItemModel copyWith({
    int? menuItemId,
    int? storeId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? notes,
  }) {
    return CartItemModel(
      menuItemId: menuItemId ?? this.menuItemId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }

  // Formatting methods
  String get formattedPrice =>
      'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  String get formattedTotalPrice =>
      'Rp ${(price * quantity).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  double get totalPrice => price * quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          menuItemId == other.menuItemId &&
          storeId == other.storeId;

  @override
  int get hashCode => menuItemId.hashCode ^ storeId.hashCode;

  @override
  String toString() {
    return 'CartItemModel{menuItemId: $menuItemId, name: $name, quantity: $quantity, price: $price}';
  }
}
