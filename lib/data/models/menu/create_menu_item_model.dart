// lib/data/models/menu/create_menu_item_model.dart
import 'package:equatable/equatable.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';

class CreateMenuItemModel extends Equatable {
  final String name;
  final double price;
  final String? description;
  final String? image; // Base64 image string
  final String category;
  final bool isAvailable;
  final int? quantity;

  const CreateMenuItemModel({
    required this.name,
    required this.price,
    this.description,
    this.image,
    required this.category,
    this.isAvailable = true,
    this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      'category': category,
      'isAvailable': isAvailable,
      if (quantity != null) 'quantity': quantity,
    };
  }

  CreateMenuItemModel copyWith({
    String? name,
    double? price,
    String? description,
    String? image,
    String? category,
    bool? isAvailable,
    int? quantity,
  }) {
    return CreateMenuItemModel(
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [
        name,
        price,
        description,
        image,
        category,
        isAvailable,
        quantity,
      ];
}

// lib/data/models/menu/update_menu_item_model.dart
class UpdateMenuItemModel extends Equatable {
  final String? name;
  final double? price;
  final String? description;
  final String? image; // Base64 image string
  final String? category;
  final bool? isAvailable;
  final int? quantity;

  const UpdateMenuItemModel({
    this.name,
    this.price,
    this.description,
    this.image,
    this.category,
    this.isAvailable,
    this.quantity,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (price != null) data['price'] = price;
    if (description != null) data['description'] = description;
    if (image != null) data['image'] = image;
    if (category != null) data['category'] = category;
    if (isAvailable != null) data['isAvailable'] = isAvailable;
    if (quantity != null) data['quantity'] = quantity;

    return data;
  }

  UpdateMenuItemModel copyWith({
    String? name,
    double? price,
    String? description,
    String? image,
    String? category,
    bool? isAvailable,
    int? quantity,
  }) {
    return UpdateMenuItemModel(
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      quantity: quantity ?? this.quantity,
    );
  }

  bool get hasChanges =>
      name != null ||
      price != null ||
      description != null ||
      image != null ||
      category != null ||
      isAvailable != null ||
      quantity != null;

  @override
  List<Object?> get props => [
        name,
        price,
        description,
        image,
        category,
        isAvailable,
        quantity,
      ];
}

// Model untuk update status menu item
class UpdateMenuItemStatusModel extends Equatable {
  final bool isAvailable;

  const UpdateMenuItemStatusModel({
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_available': isAvailable,
    };
  }

  @override
  List<Object?> get props => [isAvailable];
}

// Model untuk filter menu items
class MenuItemFilterModel extends Equatable {
  final int? storeId;
  final String? category;
  final bool? isAvailable;
  final double? minPrice;
  final double? maxPrice;
  final String? search;
  final int? page;
  final int? limit;
  final String? sortBy;
  final String? sortOrder;

  const MenuItemFilterModel({
    this.storeId,
    this.category,
    this.isAvailable,
    this.minPrice,
    this.maxPrice,
    this.search,
    this.page,
    this.limit,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};

    if (storeId != null) params['storeId'] = storeId.toString();
    if (category != null && category!.isNotEmpty) params['category'] = category;
    if (isAvailable != null) params['isAvailable'] = isAvailable.toString();
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (sortBy != null && sortBy!.isNotEmpty) params['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder!.isNotEmpty)
      params['sortOrder'] = sortOrder;

    return params;
  }

  MenuItemFilterModel copyWith({
    int? storeId,
    String? category,
    bool? isAvailable,
    double? minPrice,
    double? maxPrice,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return MenuItemFilterModel(
      storeId: storeId ?? this.storeId,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        storeId,
        category,
        isAvailable,
        minPrice,
        maxPrice,
        search,
        page,
        limit,
        sortBy,
        sortOrder,
      ];
}

// Model untuk cart item (ketika menambahkan menu item ke cart)
class CartItemModel extends Equatable {
  final int menuItemId;
  final String name;
  final double price;
  final String? imageUrl;
  final String category;
  final int quantity;
  final String? notes;
  final int storeId;
  final String storeName;

  const CartItemModel({
    required this.menuItemId,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.quantity,
    this.notes,
    required this.storeId,
    required this.storeName,
  });

  factory CartItemModel.fromMenuItemModel(
    MenuItemModel menuItem, {
    required int quantity,
    String? notes,
  }) {
    return CartItemModel(
      menuItemId: menuItem.id,
      name: menuItem.name,
      price: menuItem.price,
      imageUrl: menuItem.imageUrl,
      category: menuItem.category,
      quantity: quantity,
      notes: notes,
      storeId: menuItem.storeId,
      storeName: menuItem.storeName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItemId,
      'quantity': quantity,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  CartItemModel copyWith({
    int? menuItemId,
    String? name,
    double? price,
    String? imageUrl,
    String? category,
    int? quantity,
    String? notes,
    int? storeId,
    String? storeName,
  }) {
    return CartItemModel(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
    );
  }

  double get totalPrice => price * quantity;

  String get formattedPrice => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';

  String get formattedTotalPrice =>
      'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  @override
  List<Object?> get props => [
        menuItemId,
        name,
        price,
        imageUrl,
        category,
        quantity,
        notes,
        storeId,
        storeName,
      ];
}
