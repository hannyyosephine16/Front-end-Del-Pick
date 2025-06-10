class DriverTrackingInfo {
  final int id;
  final String name;
  final String? phone;
  final String? vehicleType;
  final String? vehicleNumber;
  final double? rating;

  DriverTrackingInfo({
    required this.id,
    required this.name,
    this.phone,
    this.vehicleType,
    this.vehicleNumber,
    this.rating,
  });

  factory DriverTrackingInfo.fromJson(Map<String, dynamic> json) {
    return DriverTrackingInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'rating': rating,
    };
  }

  String get displayRating => rating?.toStringAsFixed(1) ?? '0.0';

  @override
  String toString() {
    return 'DriverTrackingInfo{id: $id, name: $name, vehicle: $vehicleNumber}';
  }
}
