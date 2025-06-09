// lib/data/models/order/cart_item_model.dart - FINAL FIXED VERSION

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

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int?,
      menuItemId: json['menu_item_id'] as int? ?? json['menuItemId'] as int,
      storeId: json['store_id'] as int? ?? json['storeId'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
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

  // ✅ FIXED: For API requests - HANYA KIRIM YANG DIPERLUKAN BACKEND
  Map<String, dynamic> toApiJson() {
    return {
      'itemId': menuItemId, // ✅ FIXED: itemId bukan menuItemId
      'quantity': quantity, // ✅ FIXED: Hanya quantity
      // ❌ REMOVED: price, notes tidak diperlukan di API
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

  // Create from MenuItemModel
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
// class CartItemModel {
//   final int menuItemId;
//   final int storeId;
//   final String name;
//   final double price;
//   final int quantity;
//   final String? imageUrl;
//   final String? notes;
//
//   CartItemModel({
//     required this.menuItemId,
//     required this.storeId,
//     required this.name,
//     required this.price,
//     required this.quantity,
//     this.imageUrl,
//     this.notes,
//   });
//
//   // Factory constructor from MenuItemModel
//   factory CartItemModel.fromMenuItem({
//     required int menuItemId,
//     required int storeId,
//     required String name,
//     required double price,
//     required int quantity,
//     String? imageUrl,
//     String? notes,
//   }) {
//     return CartItemModel(
//       menuItemId: menuItemId,
//       storeId: storeId,
//       name: name,
//       price: price,
//       quantity: quantity,
//       imageUrl: imageUrl,
//       notes: notes,
//     );
//   }
//
//   factory CartItemModel.fromJson(Map<String, dynamic> json) {
//     return CartItemModel(
//       menuItemId: json['menuItemId'] as int,
//       storeId: json['storeId'] as int,
//       name: json['name'] as String,
//       price: (json['price'] as num).toDouble(),
//       quantity: json['quantity'] as int,
//       imageUrl: json['imageUrl'] as String?,
//       notes: json['notes'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'menuItemId': menuItemId,
//       'storeId': storeId,
//       'name': name,
//       'price': price,
//       'quantity': quantity,
//       'imageUrl': imageUrl,
//       'notes': notes,
//     };
//   }
//
//   // Method untuk API JSON (sesuai dengan struktur yang diharapkan backend)
//   Map<String, dynamic> toApiJson() {
//     return {
//       'menuItemId': menuItemId,
//       'quantity': quantity,
//       'price': price,
//       'notes': notes,
//     };
//   }
//
//   CartItemModel copyWith({
//     int? menuItemId,
//     int? storeId,
//     String? name,
//     double? price,
//     int? quantity,
//     String? imageUrl,
//     String? notes,
//   }) {
//     return CartItemModel(
//       menuItemId: menuItemId ?? this.menuItemId,
//       storeId: storeId ?? this.storeId,
//       name: name ?? this.name,
//       price: price ?? this.price,
//       quantity: quantity ?? this.quantity,
//       imageUrl: imageUrl ?? this.imageUrl,
//       notes: notes ?? this.notes,
//     );
//   }
//
//   // Formatting methods
//   String get formattedPrice =>
//       'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
//
//   String get formattedTotalPrice =>
//       'Rp ${(price * quantity).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
//
//   double get totalPrice => price * quantity;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is CartItemModel &&
//           runtimeType == other.runtimeType &&
//           menuItemId == other.menuItemId &&
//           storeId == other.storeId;
//
//   @override
//   int get hashCode => menuItemId.hashCode ^ storeId.hashCode;
//
//   @override
//   String toString() {
//     return 'CartItemModel{menuItemId: $menuItemId, name: $name, quantity: $quantity, price: $price}';
//   }
// }
