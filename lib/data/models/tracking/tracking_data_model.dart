// lib/data/models/tracking/tracking_data_model.dart
import 'package:del_pick/data/models/driver/driver_model.dart';

class TrackingData {
  final int orderId;
  final String status;
  final LocationData? storeLocation;
  final LocationData? driverLocation;
  final String deliveryAddress;
  final DateTime? estimatedDeliveryTime;
  final DriverModel? driver;
  final String? message;

  TrackingData({
    required this.orderId,
    required this.status,
    this.storeLocation,
    this.driverLocation,
    required this.deliveryAddress,
    this.estimatedDeliveryTime,
    this.driver,
    this.message,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      orderId: json['orderId'] as int,
      status: json['status'] as String,
      storeLocation: json['storeLocation'] != null
          ? LocationData.fromJson(json['storeLocation'] as Map<String, dynamic>)
          : null,
      driverLocation: json['driverLocation'] != null
          ? LocationData.fromJson(
              json['driverLocation'] as Map<String, dynamic>)
          : null,
      deliveryAddress: json['deliveryAddress'] as String,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'] as String)
          : null,
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'status': status,
      'storeLocation': storeLocation?.toJson(),
      'driverLocation': driverLocation?.toJson(),
      'deliveryAddress': deliveryAddress,
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'driver': driver?.toJson(),
      'message': message,
    };
  }

  bool get hasDriver => driver != null;
  bool get hasDriverLocation => driverLocation != null;
  bool get hasStoreLocation => storeLocation != null;
}

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({
    required this.latitude,
    required this.longitude,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
