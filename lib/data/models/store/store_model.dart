// import 'package:flutter/material.dart';
//
// import '../auth/user_model.dart';
// import '../menu/menu_item_model.dart';
//
// class StoreModel {
//   final int id;
//   final int userId;
//   final String name;
//   final String address;
//   final String? description;
//   final String? openTime;
//   final String? closeTime;
//   final double? rating;
//   final int? totalProducts;
//   final String? imageUrl;
//   final String? phone;
//   final int? reviewCount;
//   final double? latitude;
//   final double? longitude;
//   final double? distance;
//   final String status;
//   final UserModel? user;
//   final List<MenuItemModel>? menuItems;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   StoreModel({
//     required this.id,
//     required this.userId,
//     required this.name,
//     required this.address,
//     this.description,
//     this.openTime,
//     this.closeTime,
//     this.rating,
//     this.totalProducts,
//     this.imageUrl,
//     this.phone,
//     this.reviewCount,
//     this.latitude,
//     this.longitude,
//     this.distance,
//     // required this.status,
//     this.status = 'active',
//     this.user,
//     this.menuItems,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory StoreModel.fromJson(Map<String, dynamic> json) {
//     return StoreModel(
//       id: json['id'] as int,
//       userId: json['userId'] as int,
//       name: json['name'] as String,
//       address: json['address'] as String,
//       description: json['description'] as String?,
//       openTime: json['openTime'] as String?,
//       closeTime: json['closeTime'] as String?,
//       rating: (json['rating'] as num?)?.toDouble(),
//       totalProducts: json['totalProducts'] as int?,
//       imageUrl: json['imageUrl'] as String?,
//       phone: json['phone'] as String?,
//       reviewCount: json['reviewCount'] as int?,
//       latitude: (json['latitude'] as num?)?.toDouble(),
//       longitude: (json['longitude'] as num?)?.toDouble(),
//       distance: (json['distance'] as num?)?.toDouble(),
//       status: json['status'] as String? ?? 'active',
//       user: json['user'] != null
//           ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
//           : null,
//       menuItems: json['menuItems'] != null
//           ? (json['menuItems'] as List)
//               .map((item) =>
//                   MenuItemModel.fromJson(item as Map<String, dynamic>))
//               .toList()
//           : null,
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'] as String)
//           : null,
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.parse(json['updatedAt'] as String)
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'name': name,
//       'address': address,
//       'description': description,
//       'openTime': openTime,
//       'closeTime': closeTime,
//       'rating': rating,
//       'totalProducts': totalProducts,
//       'imageUrl': imageUrl,
//       'phone': phone,
//       'reviewCount': reviewCount,
//       'latitude': latitude,
//       'longitude': longitude,
//       'distance': distance,
//       'status': status,
//       'user': user?.toJson(),
//       'menuItems': menuItems?.map((item) => item.toJson()).toList(),
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }
//
//   StoreModel copyWith({
//     int? id,
//     int? userId,
//     String? name,
//     String? address,
//     String? description,
//     String? openTime,
//     String? closeTime,
//     double? rating,
//     int? totalProducts,
//     String? imageUrl,
//     String? phone,
//     int? reviewCount,
//     double? latitude,
//     double? longitude,
//     double? distance,
//     String? status,
//     UserModel? user,
//     List<MenuItemModel>? menuItems,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return StoreModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       name: name ?? this.name,
//       address: address ?? this.address,
//       description: description ?? this.description,
//       openTime: openTime ?? this.openTime,
//       closeTime: closeTime ?? this.closeTime,
//       rating: rating ?? this.rating,
//       totalProducts: totalProducts ?? this.totalProducts,
//       imageUrl: imageUrl ?? this.imageUrl,
//       phone: phone ?? this.phone,
//       reviewCount: reviewCount ?? this.reviewCount,
//       latitude: latitude ?? this.latitude,
//       longitude: longitude ?? this.longitude,
//       distance: distance ?? this.distance,
//       status: status ?? this.status,
//       user: user ?? this.user,
//       menuItems: menuItems ?? this.menuItems,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
//
//   bool get isActive => status == 'active';
//   bool get isOpen => status == 'active';
//   bool get isClosed => status == 'inactive';
//
//   // Add the missing statusDisplayName getter
//   String get statusDisplayName {
//     switch (status) {
//       case 'active':
//         return 'Active';
//       case 'inactive':
//         return 'Inactive';
//       case 'closed':
//         return 'Closed';
//       case 'maintenance':
//         return 'Under Maintenance';
//       case 'suspended':
//         return 'Suspended';
//       default:
//         return status;
//     }
//   }
//
//   bool isOpenNow() {
//     if (openTime == null || closeTime == null) return false;
//
//     final now = TimeOfDay.now();
//     final openTimeParts = openTime!.split(':');
//     final closeTimeParts = closeTime!.split(':');
//
//     final openTimeOfDay = TimeOfDay(
//       hour: int.parse(openTimeParts[0]),
//       minute: int.parse(openTimeParts[1]),
//     );
//
//     final closeTimeOfDay = TimeOfDay(
//       hour: int.parse(closeTimeParts[0]),
//       minute: int.parse(closeTimeParts[1]),
//     );
//
//     final currentMinutes = now.hour * 60 + now.minute;
//     final openMinutes = openTimeOfDay.hour * 60 + openTimeOfDay.minute;
//     final closeMinutes = closeTimeOfDay.hour * 60 + closeTimeOfDay.minute;
//
//     if (closeMinutes < openMinutes) {
//       // Store closes after midnight
//       return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
//     } else {
//       // Store closes same day
//       return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
//     }
//   }
//
//   String get operationalHours {
//     if (openTime != null && closeTime != null) {
//       return '$openTime - $closeTime';
//     }
//     return 'Tidak tersedia';
//   }
//
//   String get displayRating => rating?.toStringAsFixed(1) ?? '0.0';
//   String get displayDistance {
//     if (distance == null) return '';
//     if (distance! < 1) {
//       return '${(distance! * 1000).toInt()}m';
//     }
//     return '${distance!.toStringAsFixed(1)}km';
//   }
//
//   // bool isOpenNow() {
//   //   if (openTime == null || closeTime == null) return true;
//   //
//   //   try {
//   //     final now = DateTime.now();
//   //     final currentTime =
//   //         '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
//   //
//   //     // Simple time comparison (assumes same day open/close)
//   //     return currentTime.compareTo(openTime!) >= 0 &&
//   //         currentTime.compareTo(closeTime!) <= 0;
//   //   } catch (e) {
//   //     return true; // Default to open if can't parse times
//   //   }
//   // }
//
//   String get operatingHours {
//     if (openTime == null || closeTime == null)
//       return 'Operating hours not available';
//     return '$openTime - $closeTime';
//   }
//
//   int get totalMenuItems => menuItems?.length ?? totalProducts ?? 0;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is StoreModel && runtimeType == other.runtimeType && id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
//
//   @override
//   String toString() {
//     return 'StoreModel{id: $id, name: $name, status: $status, rating: $rating}';
//   }
// }
import 'package:flutter/material.dart';
import '../auth/user_model.dart';
import '../menu/menu_item_model.dart';

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

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String?,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalProducts: json['total_products'] as int?,
      imageUrl: json['image_url'] as String?,
      phone: json['phone'] as String?,
      reviewCount: json['review_count'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
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
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
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
