// lib/data/models/tracking/tracking_data_model.dart - FIXED
class TrackingDataModel {
  final int orderId;
  final String orderStatus;
  final String deliveryStatus;
  final LocationDataModel? storeLocation;
  final LocationDataModel? driverLocation;
  final DateTime? estimatedPickupTime;
  final DateTime? actualPickupTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final List<TrackingUpdateModel>? trackingUpdates;
  final DriverInfoModel? driver;
  final String? message;

  TrackingDataModel({
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

  factory TrackingDataModel.fromJson(Map<String, dynamic> json) {
    return TrackingDataModel(
      orderId: json['order_id'] as int,
      orderStatus: json['order_status'] as String,
      deliveryStatus: json['delivery_status'] as String,
      storeLocation: json['store_location'] != null
          ? LocationDataModel.fromJson(
              json['store_location'] as Map<String, dynamic>)
          : null,
      driverLocation: json['driver_location'] != null
          ? LocationDataModel.fromJson(
              json['driver_location'] as Map<String, dynamic>)
          : null,
      estimatedPickupTime: json['estimated_pickup_time'] != null
          ? DateTime.parse(json['estimated_pickup_time'] as String)
          : null,
      actualPickupTime: json['actual_pickup_time'] != null
          ? DateTime.parse(json['actual_pickup_time'] as String)
          : null,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'] as String)
          : null,
      actualDeliveryTime: json['actual_delivery_time'] != null
          ? DateTime.parse(json['actual_delivery_time'] as String)
          : null,
      trackingUpdates: json['tracking_updates'] != null
          ? (json['tracking_updates'] as List)
              .map((update) =>
                  TrackingUpdateModel.fromJson(update as Map<String, dynamic>))
              .toList()
          : null,
      driver: json['driver'] != null
          ? DriverInfoModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  bool get hasDriver => driver != null;
  bool get hasDriverLocation => driverLocation != null;
  bool get hasStoreLocation => storeLocation != null;
}

class LocationDataModel {
  final double latitude;
  final double longitude;

  LocationDataModel({
    required this.latitude,
    required this.longitude,
  });

  factory LocationDataModel.fromJson(Map<String, dynamic> json) {
    return LocationDataModel(
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

class TrackingUpdateModel {
  final DateTime timestamp;
  final String status;
  final String message;
  final LocationDataModel? location;

  TrackingUpdateModel({
    required this.timestamp,
    required this.status,
    required this.message,
    this.location,
  });

  factory TrackingUpdateModel.fromJson(Map<String, dynamic> json) {
    return TrackingUpdateModel(
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      message: json['message'] as String,
      location: json['location'] != null
          ? LocationDataModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DriverInfoModel {
  final int id;
  final String name;
  final String? phone;

  DriverInfoModel({
    required this.id,
    required this.name,
    this.phone,
  });

  factory DriverInfoModel.fromJson(Map<String, dynamic> json) {
    return DriverInfoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
    );
  }
}
