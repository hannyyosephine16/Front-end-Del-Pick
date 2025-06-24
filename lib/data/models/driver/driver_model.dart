import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';

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
  final UserModel? user;
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

  // ✅ FIXED: Safe parsing using ParsingHelper
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: ParsingHelper.parseIntWithDefault(json['id'], 0),
      userId: ParsingHelper.parseIntWithDefault(json['user_id'], 0),
      licenseNumber: json['license_number'] as String? ?? '',
      vehiclePlate: json['vehicle_plate'] as String? ?? '',
      status: json['status'] as String? ?? 'inactive',
      rating: ParsingHelper.parseDoubleWithDefault(json['rating'], 5.0),
      reviewsCount: ParsingHelper.parseIntWithDefault(json['reviews_count'], 0),
      latitude: ParsingHelper.parseDouble(json['latitude']),
      longitude: ParsingHelper.parseDouble(json['longitude']),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
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

  DriverModel copyWith({
    int? id,
    int? userId,
    String? licenseNumber,
    String? vehiclePlate,
    String? status,
    double? rating,
    int? reviewsCount,
    double? latitude,
    double? longitude,
    UserModel? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Aliases for compatibility
  String get vehicleNumber => vehiclePlate;
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
