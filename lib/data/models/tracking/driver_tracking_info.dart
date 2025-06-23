// lib/data/models/tracking/driver_tracking_info.dart - FIXED
class DriverTrackingInfo {
  final int id;
  final String name;
  final String? phone;
  final String? licenseNumber; // ✅ FIXED: Backend field name
  final String? vehiclePlate; // ✅ FIXED: Backend field name
  final double? rating;

  DriverTrackingInfo({
    required this.id,
    required this.name,
    this.phone,
    this.licenseNumber,
    this.vehiclePlate,
    this.rating,
  });

  factory DriverTrackingInfo.fromJson(Map<String, dynamic> json) {
    return DriverTrackingInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      licenseNumber: json['license_number'] as String?, // ✅ FIXED
      vehiclePlate: json['vehicle_plate'] as String?, // ✅ FIXED
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'license_number': licenseNumber, // ✅ FIXED
      'vehicle_plate': vehiclePlate, // ✅ FIXED
      'rating': rating,
    };
  }

  String get displayRating => rating?.toStringAsFixed(1) ?? '0.0';

  @override
  String toString() {
    return 'DriverTrackingInfo{id: $id, name: $name, vehicle: $vehiclePlate}';
  }
}
