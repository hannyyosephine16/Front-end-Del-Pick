import 'package:del_pick/data/models/tracking/location_model.dart';
import 'package:del_pick/data/models/tracking/tracking_data_model.dart';

import '../driver/driver_model.dart';

class TrackingInfoModel {
  final int orderId;
  final String status;
  final LocationData? storeLocation;
  final LocationData? driverLocation;
  final String deliveryAddress;
  final DateTime? estimatedDeliveryTime;
  final DriverModel? driver;
  final String? message;

  TrackingInfoModel({
    required this.orderId,
    required this.status,
    this.storeLocation,
    this.driverLocation,
    required this.deliveryAddress,
    this.estimatedDeliveryTime,
    this.driver,
    this.message,
  });

  factory TrackingInfoModel.fromJson(Map<String, dynamic> json) {
    return TrackingInfoModel(
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

  String get estimatedTimeString {
    if (estimatedDeliveryTime == null) return 'Calculating...';

    final now = DateTime.now();
    final difference = estimatedDeliveryTime!.difference(now);

    if (difference.isNegative) return 'Delivered';

    final minutes = difference.inMinutes;
    if (minutes < 60) {
      return '${minutes} mins';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMins = minutes % 60;
      return '${hours}h ${remainingMins}m';
    }
  }
}
