import 'package:flutter/material.dart';
import '../auth/user_model.dart';
import '../menu/menu_item_model.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';

class StoreModel {
  final int id;
  final int userId;
  final String name;
  final String address;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final double? rating;
  final int? totalProducts;
  final String? imageUrl;
  final String? phone;
  final int? reviewCount;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final String status;
  final UserModel? owner;
  final List<MenuItemModel>? menuItems;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    this.description,
    this.openTime,
    this.closeTime,
    this.rating,
    this.totalProducts,
    this.imageUrl,
    this.phone,
    this.reviewCount,
    this.latitude,
    this.longitude,
    this.distance,
    this.status = 'active',
    this.owner,
    this.menuItems,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ FIXED: Safe parsing using ParsingHelper
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: ParsingHelper.parseIntWithDefault(json['id'], 0),
      userId: ParsingHelper.parseIntWithDefault(json['user_id'], 0),
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      description: json['description'] as String?,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      rating: ParsingHelper.parseDouble(json['rating']),
      totalProducts: ParsingHelper.parseInt(json['total_products']),
      imageUrl: json['image_url'] as String?,
      phone: json['phone'] as String?,
      reviewCount: ParsingHelper.parseInt(json['review_count']),
      latitude: ParsingHelper.parseDouble(json['latitude']),
      longitude: ParsingHelper.parseDouble(json['longitude']),
      distance: ParsingHelper.parseDouble(json['distance']),
      status: json['status'] as String? ?? 'active',
      owner: json['owner'] != null
          ? UserModel.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      menuItems: json['menu_items'] != null
          ? (json['menu_items'] as List)
              .map((item) =>
                  MenuItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address': address,
      'description': description,
      'open_time': openTime,
      'close_time': closeTime,
      'rating': rating,
      'total_products': totalProducts,
      'image_url': imageUrl,
      'phone': phone,
      'review_count': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'status': status,
      'owner': owner?.toJson(),
      'menu_items': menuItems?.map((item) => item.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  StoreModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? address,
    String? description,
    String? openTime,
    String? closeTime,
    double? rating,
    int? totalProducts,
    String? imageUrl,
    String? phone,
    int? reviewCount,
    double? latitude,
    double? longitude,
    double? distance,
    String? status,
    UserModel? owner,
    List<MenuItemModel>? menuItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      rating: rating ?? this.rating,
      totalProducts: totalProducts ?? this.totalProducts,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      reviewCount: reviewCount ?? this.reviewCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      menuItems: menuItems ?? this.menuItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active';
  bool get isOpen => status == 'active';
  bool get isClosed => status == 'inactive';

  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  bool isOpenNow() {
    if (openTime == null || closeTime == null) return false;

    final now = TimeOfDay.now();
    final openTimeParts = openTime!.split(':');
    final closeTimeParts = closeTime!.split(':');

    final openTimeOfDay = TimeOfDay(
      hour: int.parse(openTimeParts[0]),
      minute: int.parse(openTimeParts[1]),
    );

    final closeTimeOfDay = TimeOfDay(
      hour: int.parse(closeTimeParts[0]),
      minute: int.parse(closeTimeParts[1]),
    );

    final currentMinutes = now.hour * 60 + now.minute;
    final openMinutes = openTimeOfDay.hour * 60 + openTimeOfDay.minute;
    final closeMinutes = closeTimeOfDay.hour * 60 + closeTimeOfDay.minute;

    if (closeMinutes < openMinutes) {
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    } else {
      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    }
  }

  String get operationalHours {
    if (openTime != null && closeTime != null) {
      return '$openTime - $closeTime';
    }
    return 'Tidak tersedia';
  }

  String get displayRating => rating?.toStringAsFixed(1) ?? '0.0';
  String get displayDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toInt()}m';
    }
    return '${distance!.toStringAsFixed(1)}km';
  }

  int get totalMenuItems => menuItems?.length ?? totalProducts ?? 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StoreModel{id: $id, name: $name, status: $status, rating: $rating}';
  }
}
