// lib/data/models/order/place_order_response.dart
import 'package:del_pick/core/utils/parsing_helper.dart';

/// ✅ Response model yang PERSIS sesuai dengan backend place order
class PlaceOrderResponse {
  final String message;
  final PlaceOrderData data;

  PlaceOrderResponse({
    required this.message,
    required this.data,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    return PlaceOrderResponse(
      message: json['message'] as String? ?? '',
      data: PlaceOrderData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// ✅ Exact structure dari backend response
class PlaceOrderData {
  final int id;
  final int customerId;
  final int storeId;
  final String orderStatus;
  final String deliveryStatus;
  final double totalAmount;
  final double deliveryFee;
  final DateTime estimatedPickupTime;
  final DateTime estimatedDeliveryTime;
  final List<TrackingUpdate> trackingUpdates;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlaceOrderData({
    required this.id,
    required this.customerId,
    required this.storeId,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.totalAmount,
    required this.deliveryFee,
    required this.estimatedPickupTime,
    required this.estimatedDeliveryTime,
    required this.trackingUpdates,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlaceOrderData.fromJson(Map<String, dynamic> json) {
    return PlaceOrderData(
      id: ParsingHelper.parseIntWithDefault(json['id'], 0),
      customerId: ParsingHelper.parseIntWithDefault(json['customer_id'], 0),
      storeId: ParsingHelper.parseIntWithDefault(json['store_id'], 0),
      orderStatus: json['order_status'] as String? ?? 'pending',
      deliveryStatus: json['delivery_status'] as String? ?? 'pending',
      totalAmount:
          ParsingHelper.parseDoubleWithDefault(json['total_amount'], 0.0),
      deliveryFee:
          ParsingHelper.parseDoubleWithDefault(json['delivery_fee'], 0.0),
      estimatedPickupTime:
          DateTime.parse(json['estimated_pickup_time'] as String),
      estimatedDeliveryTime:
          DateTime.parse(json['estimated_delivery_time'] as String),
      trackingUpdates: (json['tracking_updates'] as List? ?? [])
          .map((update) =>
              TrackingUpdate.fromJson(update as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'store_id': storeId,
      'order_status': orderStatus,
      'delivery_status': deliveryStatus,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'estimated_pickup_time': estimatedPickupTime.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime.toIso8601String(),
      'tracking_updates':
          trackingUpdates.map((update) => update.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get orderCode => 'ORD${id.toString().padLeft(6, '0')}';
  double get grandTotal => totalAmount + deliveryFee;

  String get formattedTotal =>
      'Rp ${grandTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

/// ✅ Tracking update LENGKAP dari backend response
class TrackingUpdate {
  final DateTime timestamp;
  final String status;
  final String message;
  final LocationData? location;
  final EstimatedTimes? estimatedTimes;
  final DistanceData? distances;

  TrackingUpdate({
    required this.timestamp,
    required this.status,
    required this.message,
    this.location,
    this.estimatedTimes,
    this.distances,
  });

  factory TrackingUpdate.fromJson(Map<String, dynamic> json) {
    return TrackingUpdate(
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      estimatedTimes: json['estimated_times'] != null
          ? EstimatedTimes.fromJson(
              json['estimated_times'] as Map<String, dynamic>)
          : null,
      distances: json['distances'] != null
          ? DistanceData.fromJson(json['distances'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'message': message,
      'location': location?.toJson(),
      'estimated_times': estimatedTimes?.toJson(),
      'distances': distances?.toJson(),
    };
  }

  // Helper getters
  bool get hasLocation => location != null;
  bool get hasEstimatedTimes => estimatedTimes != null;
  bool get hasDistances => distances != null;

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[timestamp.month - 1]} ${timestamp.day}, ${formattedTime}';
  }
}

/// ✅ Location data dalam tracking update
class LocationData {
  final double latitude;
  final double longitude;

  LocationData({
    required this.latitude,
    required this.longitude,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: ParsingHelper.parseDoubleWithDefault(json['latitude'], 0.0),
      longitude: ParsingHelper.parseDoubleWithDefault(json['longitude'], 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude)';
}

/// ✅ Estimated times dalam tracking update
class EstimatedTimes {
  final DateTime? pickup;
  final DateTime? delivery;

  EstimatedTimes({
    this.pickup,
    this.delivery,
  });

  factory EstimatedTimes.fromJson(Map<String, dynamic> json) {
    return EstimatedTimes(
      pickup: json['pickup'] != null
          ? DateTime.tryParse(json['pickup'] as String)
          : null,
      delivery: json['delivery'] != null
          ? DateTime.tryParse(json['delivery'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup?.toIso8601String(),
      'delivery': delivery?.toIso8601String(),
    };
  }

  String? get formattedPickupTime {
    if (pickup == null) return null;
    return '${pickup!.hour.toString().padLeft(2, '0')}:${pickup!.minute.toString().padLeft(2, '0')}';
  }

  String? get formattedDeliveryTime {
    if (delivery == null) return null;
    return '${delivery!.hour.toString().padLeft(2, '0')}:${delivery!.minute.toString().padLeft(2, '0')}';
  }
}

/// ✅ Distance data dalam tracking update
class DistanceData {
  final double? toStore;
  final double? toCustomer;
  final double? remaining;

  DistanceData({
    this.toStore,
    this.toCustomer,
    this.remaining,
  });

  factory DistanceData.fromJson(Map<String, dynamic> json) {
    return DistanceData(
      toStore: ParsingHelper.parseDouble(json['to_store']),
      toCustomer: ParsingHelper.parseDouble(json['to_customer']),
      remaining: ParsingHelper.parseDouble(json['remaining']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'to_store': toStore,
      'to_customer': toCustomer,
      'remaining': remaining,
    };
  }

  String get formattedDistance {
    final distance = remaining ?? toStore ?? toCustomer ?? 0.0;
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }
}
