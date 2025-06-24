import 'package:del_pick/core/utils/parsing_helper.dart';

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

  // ✅ FIXED: Safe parsing and correct field names
  factory DriverTrackingInfo.fromJson(Map<String, dynamic> json) {
    return DriverTrackingInfo(
      id: ParsingHelper.parseIntWithDefault(json['id'], 0),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      licenseNumber: json['license_number'] as String?, // ✅ FIXED
      vehiclePlate: json['vehicle_plate'] as String?, // ✅ FIXED
      rating: ParsingHelper.parseDouble(json['rating']),
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
