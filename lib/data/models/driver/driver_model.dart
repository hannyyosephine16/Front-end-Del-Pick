// lib/data/models/driver/driver_model.dart - FIXED with avatar
import 'package:del_pick/data/models/auth/user_model.dart';

class DriverModel {
  final int id;
  final int userId;
  final String vehicleNumber;
  final double rating;
  final int reviewsCount;
  final double? latitude;
  final double? longitude;
  final String status;
  final UserModel? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DriverModel({
    required this.id,
    required this.userId,
    required this.vehicleNumber,
    required this.rating,
    required this.reviewsCount,
    this.latitude,
    this.longitude,
    required this.status,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      vehicleNumber:
          json['vehicle_number'] as String? ?? json['vehicleNumber'] as String,
      // FIX: Handle both String and num for rating
      rating: _parseDouble(json['rating']) ?? 0.0,
      // FIX: Handle both String and num for reviewsCount
      reviewsCount: _parseInt(json['reviews_count']) ??
          _parseInt(json['reviewsCount']) ??
          0,
      // FIX: Handle both String and num for latitude/longitude
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      status: json['status'] as String? ?? 'inactive',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Helper method to safely parse double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper method to safely parse int from dynamic value
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicle_number': vehicleNumber,
      'rating': rating,
      'reviews_count': reviewsCount,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'user': user?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DriverModel copyWith({
    int? id,
    int? userId,
    String? vehicleNumber,
    double? rating,
    int? reviewsCount,
    double? latitude,
    double? longitude,
    String? status,
    UserModel? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Status checks
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isBusy => status == 'busy';
  bool get isOffline => status == 'offline';

  bool get isAvailable => isActive;
  bool get canAcceptOrders => isActive;

  // Location checks
  bool get hasLocation => latitude != null && longitude != null;

  String get displayRating => rating.toStringAsFixed(1);
  String get displayReviewsCount => '$reviewsCount reviews';

  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'busy':
        return 'Sibuk';
      case 'offline':
        return 'Offline';
      default:
        return status;
    }
  }

  String get name => user?.name ?? 'Unknown';
  String get phone => user?.phone ?? '';
  String get email => user?.email ?? '';

  // ✅ FIXED: Added avatar property
  String? get avatar => user?.avatar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DriverModel{id: $id, name: $name, status: $status, rating: $rating}';
  }
}
