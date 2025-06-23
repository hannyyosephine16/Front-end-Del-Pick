// lib/data/models/driver/driver_model.dart - NEW FILE
import 'package:del_pick/data/models/auth/user_model.dart';

class DriverModel {
  final int id;
  final int userId;
  final String licenseNumber;
  final String vehiclePlate;
  final String status;
  final double rating;
  final int reviewsCount;
  final double? latitude;
  final double? longitude;
  final UserModel? user; // Driver's user information
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverModel({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.vehiclePlate,
    required this.status,
    required this.rating,
    required this.reviewsCount,
    this.latitude,
    this.longitude,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      licenseNumber: json['license_number'] as String,
      vehiclePlate: json['vehicle_plate'] as String,
      status: json['status'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'] as int,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'license_number': licenseNumber,
      'vehicle_plate': vehiclePlate,
      'status': status,
      'rating': rating,
      'reviews_count': reviewsCount,
      'latitude': latitude,
      'longitude': longitude,
      'user': user?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ Helper methods
  String get name => user?.name ?? 'Unknown Driver';
  String get phone => user?.phone ?? '';
  String get email => user?.email ?? '';

  bool get isActive => status == 'active';
  bool get isBusy => status == 'busy';
  bool get isInactive => status == 'inactive';

  bool get hasLocation => latitude != null && longitude != null;

  String get formattedRating => rating.toStringAsFixed(1);

  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Active';
      case 'busy':
        return 'Busy';
      case 'inactive':
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

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
