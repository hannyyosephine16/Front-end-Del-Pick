// lib/data/models/driver/driver_status_model.dart

/// Model untuk lokasi driver
class DriverLocationModel {
  final double? latitude;
  final double? longitude;
  final DateTime? updatedAt;
  final bool hasLocation;

  DriverLocationModel({
    this.latitude,
    this.longitude,
    this.updatedAt,
    bool? hasLocation,
  }) : hasLocation = hasLocation ?? (latitude != null && longitude != null);

  factory DriverLocationModel.fromJson(Map<String, dynamic> json) {
    return DriverLocationModel(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      hasLocation: json['hasLocation'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': updatedAt?.toIso8601String(),
      'hasLocation': hasLocation,
    };
  }

  DriverLocationModel copyWith({
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
    bool? hasLocation,
  }) {
    return DriverLocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      hasLocation: hasLocation ?? this.hasLocation,
    );
  }

  @override
  String toString() {
    return 'DriverLocationModel{latitude: $latitude, longitude: $longitude, hasLocation: $hasLocation}';
  }
}
