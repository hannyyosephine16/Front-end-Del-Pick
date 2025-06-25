import 'package:del_pick/core/utils/parsing_helper.dart';

/// ✅ CartItemModel yang sesuai dengan backend DelPick - COMPLETE FIXED
class CartItemModel {
  final int? id;
  final int menuItemId;
  final int storeId;
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final String category;
  final String? imageUrl;
  final String? notes;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItemModel({
    this.id,
    required this.menuItemId,
    required this.storeId,
    required this.name,
    this.description,
    required this.price,
    required this.quantity,
    required this.category,
    this.imageUrl,
    this.notes,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  /// ✅ From JSON - Support both cart format and menu item format
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: ParsingHelper.parseInt(json['id']),
      menuItemId: ParsingHelper.parseIntWithDefault(
          json['menu_item_id'] ?? json['menuItemId'], 0),
      storeId: ParsingHelper.parseIntWithDefault(
          json['store_id'] ?? json['storeId'], 0),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: ParsingHelper.parseDoubleWithDefault(json['price'], 0.0),
      quantity: ParsingHelper.parseIntWithDefault(json['quantity'], 1),
      category: json['category'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      isAvailable:
          json['is_available'] as bool? ?? json['isAvailable'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'] as String)
              : null,
    );
  }

  /// ✅ From MenuItem - Convert menu item to cart item
  factory CartItemModel.fromMenuItem(
    Map<String, dynamic> menuItem, {
    required int quantity,
    String? notes,
  }) {
    return CartItemModel(
      menuItemId: ParsingHelper.parseIntWithDefault(menuItem['id'], 0),
      storeId: ParsingHelper.parseIntWithDefault(menuItem['store_id'], 0),
      name: menuItem['name'] as String? ?? '',
      description: menuItem['description'] as String?,
      price: ParsingHelper.parseDoubleWithDefault(menuItem['price'], 0.0),
      quantity: quantity,
      category: menuItem['category'] as String? ?? '',
      imageUrl: menuItem['image_url'] as String?,
      notes: notes,
      isAvailable: menuItem['is_available'] as bool? ?? true,
      createdAt: DateTime.now(),
    );
  }

  /// ✅ From Order Item - Convert order item response to cart item
  factory CartItemModel.fromOrderItem(Map<String, dynamic> orderItem) {
    return CartItemModel(
      id: ParsingHelper.parseInt(orderItem['id']),
      menuItemId:
          ParsingHelper.parseIntWithDefault(orderItem['menu_item_id'], 0),
      storeId: 0, // Order item doesn't have store_id, will be set from order
      name: orderItem['name'] as String? ?? '',
      description: orderItem['description'] as String?,
      price: ParsingHelper.parseDoubleWithDefault(orderItem['price'], 0.0),
      quantity: ParsingHelper.parseIntWithDefault(orderItem['quantity'], 1),
      category: orderItem['category'] as String? ?? '',
      imageUrl: orderItem['image_url'] as String?,
      notes: orderItem['notes'] as String?,
      isAvailable: true, // Assume available if in order
      createdAt: orderItem['created_at'] != null
          ? DateTime.tryParse(orderItem['created_at'] as String)
          : null,
      updatedAt: orderItem['updated_at'] != null
          ? DateTime.tryParse(orderItem['updated_at'] as String)
          : null,
    );
  }

  /// ✅ To JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
      'image_url': imageUrl,
      'notes': notes,
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// ✅ To API JSON - Format untuk place order API (sesuai backend DelPick)
  /// Backend expects: { menu_item_id, quantity, notes }
  Map<String, dynamic> toApiJson() {
    return {
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'notes': notes ?? '',
    };
  }

  /// ✅ Copy with method
  CartItemModel copyWith({
    int? id,
    int? menuItemId,
    int? storeId,
    String? name,
    String? description,
    double? price,
    int? quantity,
    String? category,
    String? imageUrl,
    String? notes,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ✅ Calculated properties
  double get totalPrice => price * quantity;

  String get formattedPrice => _formatCurrency(price);
  String get formattedTotalPrice => _formatCurrency(totalPrice);

  /// ✅ Format currency helper
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// ✅ Validation methods
  bool get isValid =>
      menuItemId > 0 &&
      storeId > 0 &&
      name.isNotEmpty &&
      quantity > 0 &&
      price >= 0;

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasDescription => description != null && description!.isNotEmpty;

  /// ✅ Business logic methods
  bool canAddQuantity({int maxQuantity = 99}) => quantity < maxQuantity;

  bool canRemoveQuantity() => quantity > 1;

  CartItemModel incrementQuantity({int maxQuantity = 99}) {
    if (!canAddQuantity(maxQuantity: maxQuantity)) return this;
    return copyWith(
      quantity: quantity + 1,
      updatedAt: DateTime.now(),
    );
  }

  CartItemModel decrementQuantity() {
    if (!canRemoveQuantity()) return this;
    return copyWith(
      quantity: quantity - 1,
      updatedAt: DateTime.now(),
    );
  }

  CartItemModel updateQuantity(int newQuantity, {int maxQuantity = 99}) {
    final clampedQuantity = newQuantity.clamp(1, maxQuantity);
    return copyWith(
      quantity: clampedQuantity,
      updatedAt: DateTime.now(),
    );
  }

  CartItemModel updateNotes(String? newNotes) {
    return copyWith(
      notes: newNotes,
      updatedAt: DateTime.now(),
    );
  }

  CartItemModel updateAvailability(bool available) {
    return copyWith(
      isAvailable: available,
      updatedAt: DateTime.now(),
    );
  }

  /// ✅ Comparison methods
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          menuItemId == other.menuItemId &&
          storeId == other.storeId;

  @override
  int get hashCode => Object.hash(menuItemId, storeId);

  @override
  String toString() {
    return 'CartItemModel{'
        'id: $id, '
        'menuItemId: $menuItemId, '
        'storeId: $storeId, '
        'name: $name, '
        'quantity: $quantity, '
        'price: $price, '
        'totalPrice: $totalPrice, '
        'category: $category, '
        'isAvailable: $isAvailable'
        '}';
  }

  /// ✅ Static helper methods
  static List<CartItemModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<CartItemModel> items) {
    return items.map((item) => item.toJson()).toList();
  }

  static List<Map<String, dynamic>> toApiJsonList(List<CartItemModel> items) {
    return items.map((item) => item.toApiJson()).toList();
  }

  /// ✅ Calculate total for list of items
  static double calculateTotal(List<CartItemModel> items) {
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// ✅ Calculate total quantity for list of items
  static int calculateTotalQuantity(List<CartItemModel> items) {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// ✅ Group items by category
  static Map<String, List<CartItemModel>> groupByCategory(
      List<CartItemModel> items) {
    final grouped = <String, List<CartItemModel>>{};
    for (final item in items) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    return grouped;
  }

  /// ✅ Filter available items
  static List<CartItemModel> filterAvailable(List<CartItemModel> items) {
    return items.where((item) => item.isAvailable).toList();
  }

  /// ✅ Filter unavailable items
  static List<CartItemModel> filterUnavailable(List<CartItemModel> items) {
    return items.where((item) => !item.isAvailable).toList();
  }

  /// ✅ Find item by menu item id
  static CartItemModel? findByMenuItemId(
      List<CartItemModel> items, int menuItemId) {
    try {
      return items.firstWhere((item) => item.menuItemId == menuItemId);
    } catch (e) {
      return null;
    }
  }

  /// ✅ Check if store is consistent across all items
  static bool hasConsistentStore(List<CartItemModel> items) {
    if (items.isEmpty) return true;
    final firstStoreId = items.first.storeId;
    return items.every((item) => item.storeId == firstStoreId);
  }

  /// ✅ Get unique store ID from items (returns null if inconsistent)
  static int? getStoreId(List<CartItemModel> items) {
    if (items.isEmpty) return null;
    if (!hasConsistentStore(items)) return null;
    return items.first.storeId;
  }

  /// ✅ Merge duplicate items (same menuItemId)
  static List<CartItemModel> mergeDuplicates(List<CartItemModel> items) {
    final merged = <int, CartItemModel>{};

    for (final item in items) {
      if (merged.containsKey(item.menuItemId)) {
        final existing = merged[item.menuItemId]!;
        merged[item.menuItemId] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
          updatedAt: DateTime.now(),
        );
      } else {
        merged[item.menuItemId] = item;
      }
    }

    return merged.values.toList();
  }

  /// ✅ Validate cart items for order placement
  static Map<String, dynamic> validateForOrder(List<CartItemModel> items) {
    final errors = <String>[];

    if (items.isEmpty) {
      errors.add('Keranjang kosong');
    }

    if (!hasConsistentStore(items)) {
      errors.add('Semua item harus dari toko yang sama');
    }

    final unavailableItems = filterUnavailable(items);
    if (unavailableItems.isNotEmpty) {
      errors.add(
          'Beberapa item tidak tersedia: ${unavailableItems.map((e) => e.name).join(', ')}');
    }

    final invalidItems = items.where((item) => !item.isValid).toList();
    if (invalidItems.isNotEmpty) {
      errors.add('Beberapa item tidak valid');
    }

    final total = calculateTotal(items);
    if (total < 5000) {
      // Minimum order amount
      errors.add('Minimum order Rp 5.000');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'itemCount': items.length,
      'totalQuantity': calculateTotalQuantity(items),
      'total': total,
      'storeId': getStoreId(items),
      'unavailableItems': unavailableItems.map((e) => e.name).toList(),
    };
  }
}
