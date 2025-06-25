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
