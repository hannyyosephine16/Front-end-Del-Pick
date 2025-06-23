class MenuItemModel {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final int storeId;
  final String category;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.storeId,
    required this.category,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?, // ✅ Backend: image_url
      storeId: json['store_id'] as int, // ✅ Backend: store_id
      category: json['category'] as String,
      isAvailable:
          json['is_available'] as bool? ?? true, // ✅ Backend: is_available
      createdAt:
          DateTime.parse(json['created_at'] as String), // ✅ Backend: created_at
      updatedAt:
          DateTime.parse(json['updated_at'] as String), // ✅ Backend: updated_at
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl, // ✅ Backend: image_url
      'store_id': storeId, // ✅ Backend: store_id
      'category': category,
      'is_available': isAvailable, // ✅ Backend: is_available
      'created_at': createdAt.toIso8601String(), // ✅ Backend: created_at
      'updated_at': updatedAt.toIso8601String(), // ✅ Backend: updated_at
    };
  }

  MenuItemModel copyWith({
    int? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    int? storeId,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      storeId: storeId ?? this.storeId,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice =>
      'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  bool get canOrder => isAvailable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MenuItemModel{id: $id, name: $name, price: $price, storeId: $storeId}';
  }
}
