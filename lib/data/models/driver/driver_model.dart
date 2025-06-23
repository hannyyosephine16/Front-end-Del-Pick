// lib/data/models/driver/driver_model.dart - FIXED VERSION
import 'package:del_pick/data/models/auth/user_model.dart';

class DriverModel {
  final int id;
  final int userId;
  final String licenseNumber;
  final String vehiclePlate;
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
    required this.licenseNumber,
    required this.vehiclePlate,
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
      userId: json['user_id'] as int? ?? json['userId'] as int,
      licenseNumber:
          json['license_number'] as String? ?? json['licenseNumber'] as String,
      vehiclePlate:
          json['vehicle_plate'] as String? ?? json['vehiclePlate'] as String,
      rating: _parseDouble(json['rating']) ?? 0.0,
      reviewsCount: _parseInt(json['reviews_count']) ??
          _parseInt(json['reviewsCount']) ??
          0,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      status: json['status'] as String? ?? 'inactive',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'license_number': licenseNumber,
      'vehicle_plate': vehiclePlate,
      'rating': rating,
      'reviews_count': reviewsCount,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'user': user?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get name => user?.name ?? 'Unknown';
  String get phone => user?.phone ?? '';
  String get email => user?.email ?? '';
  String? get avatar => user?.avatar;

  // Rest of the class remains the same...
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isBusy => status == 'busy';
  bool get hasLocation => latitude != null && longitude != null;

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
