import 'package:equatable/equatable.dart';

class MenuItemModel extends Equatable {
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
  final MenuItemStore? store;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.storeId,
    required this.category,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    this.store,
  });

  // Factory constructor untuk membuat object dari JSON
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      storeId: json['store_id'] as int,
      category: json['category'] as String,
      isAvailable: json['is_available'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      store: json['store'] != null
          ? MenuItemStore.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }

  // Method untuk convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price.toString(),
      'description': description,
      'image_url': imageUrl,
      'store_id': storeId,
      'category': category,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (store != null) 'store': store!.toJson(),
    };
  }

  // Method untuk membuat copy dengan perubahan
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
    MenuItemStore? store,
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
      store: store ?? this.store,
    );
  }

  // Getters untuk business logic
  bool get canOrder => isAvailable;

  String get formattedPrice => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';

  String get displayImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return ''; // Return empty or default image URL
    }
    // If imageUrl starts with '/uploads', prepend base URL
    if (imageUrl!.startsWith('/uploads')) {
      return 'https://your-backend-url.com$imageUrl'; // Replace with actual base URL
    }
    return imageUrl!;
  }

  String get storeName => store?.name ?? '';
  String get storeImageUrl => store?.imageUrl ?? '';

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        description,
        imageUrl,
        storeId,
        category,
        isAvailable,
        createdAt,
        updatedAt,
        store,
      ];

  @override
  String toString() {
    return 'MenuItemModel(id: $id, name: $name, price: $price, category: $category, isAvailable: $isAvailable)';
  }
}

// Model untuk nested store object dalam response menu item
class MenuItemStore extends Equatable {
  final String name;
  final String? imageUrl;

  const MenuItemStore({
    required this.name,
    this.imageUrl,
  });

  factory MenuItemStore.fromJson(Map<String, dynamic> json) {
    return MenuItemStore(
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  MenuItemStore copyWith({
    String? name,
    String? imageUrl,
  }) {
    return MenuItemStore(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  String get displayImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return '';
    }
    if (imageUrl!.startsWith('/uploads')) {
      return 'https://your-backend-url.com$imageUrl'; // Replace with actual base URL
    }
    return imageUrl!;
  }

  @override
  List<Object?> get props => [name, imageUrl];

  @override
  String toString() => 'MenuItemStore(name: $name, imageUrl: $imageUrl)';
}

// Response wrapper untuk API
class MenuItemResponse {
  final String message;
  final List<MenuItemModel> data;

  MenuItemResponse({
    required this.message,
    required this.data,
  });

  factory MenuItemResponse.fromJson(Map<String, dynamic> json) {
    return MenuItemResponse(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

// Response untuk single menu item
class SingleMenuItemResponse {
  final String message;
  final MenuItemModel data;

  SingleMenuItemResponse({
    required this.message,
    required this.data,
  });

  factory SingleMenuItemResponse.fromJson(Map<String, dynamic> json) {
    return SingleMenuItemResponse(
      message: json['message'] as String,
      data: MenuItemModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

// Extensions untuk helper methods
extension MenuItemModelExtensions on MenuItemModel {
  // Check if item is in specific price range
  bool isInPriceRange(double min, double max) {
    return price >= min && price <= max;
  }

  // Check if item matches search query
  bool matchesSearchQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        (description?.toLowerCase().contains(lowerQuery) ?? false) ||
        category.toLowerCase().contains(lowerQuery);
  }

  // Get category display name (capitalize first letter)
  String get categoryDisplayName {
    if (category.isEmpty) return 'Other';
    return category[0].toUpperCase() + category.substring(1);
  }

  // Check if item has image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Get relative date string
  String get createdAtRelative {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}
