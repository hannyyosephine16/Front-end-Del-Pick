import 'package:del_pick/data/models/tracking/location_model.dart';
import 'package:del_pick/data/models/tracking/tracking_data_model.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';

class TrackingInfoModel {
  final int orderId;
  final String orderStatus;
  final String deliveryStatus;
  final LocationDataModel? storeLocation;
  final LocationDataModel? driverLocation;
  final DateTime? estimatedPickupTime;
  final DateTime? actualPickupTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final List<dynamic>? trackingUpdates;
  final DriverModel? driver;
  final String? message;

  TrackingInfoModel({
    required this.orderId,
    required this.orderStatus,
    required this.deliveryStatus,
    this.storeLocation,
    this.driverLocation,
    this.estimatedPickupTime,
    this.actualPickupTime,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.trackingUpdates,
    this.driver,
    this.message,
  });

  // ✅ FIXED: Safe parsing and correct field names
  factory TrackingInfoModel.fromJson(Map<String, dynamic> json) {
    return TrackingInfoModel(
      orderId:
          ParsingHelper.parseIntWithDefault(json['order_id'], 0), // ✅ FIXED
      orderStatus: json['order_status'] as String? ?? 'pending', // ✅ FIXED
      deliveryStatus:
          json['delivery_status'] as String? ?? 'pending', // ✅ FIXED
      storeLocation: json['store_location'] != null
          ? LocationDataModel.fromJson(
              json['store_location'] as Map<String, dynamic>)
          : null,
      driverLocation: json['driver_location'] != null
          ? LocationDataModel.fromJson(
              json['driver_location'] as Map<String, dynamic>)
          : null,
      estimatedPickupTime: json['estimated_pickup_time'] != null
          ? DateTime.tryParse(json['estimated_pickup_time'] as String)
          : null,
      actualPickupTime: json['actual_pickup_time'] != null
          ? DateTime.tryParse(json['actual_pickup_time'] as String)
          : null,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.tryParse(json['estimated_delivery_time'] as String)
          : null,
      actualDeliveryTime: json['actual_delivery_time'] != null
          ? DateTime.tryParse(json['actual_delivery_time'] as String)
          : null,
      trackingUpdates: json['tracking_updates'] as List<dynamic>?,
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
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
