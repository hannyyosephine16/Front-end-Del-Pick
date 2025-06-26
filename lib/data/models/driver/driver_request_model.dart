// lib/data/models/driver/driver_request_model.dart - FIXED
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';
import 'package:del_pick/data/models/order/order_model_extensions.dart';

class DriverRequestModel {
  final int id;
  final int orderId;
  final int driverId;
  final String status;
  final DateTime? estimatedPickupTime;
  final DateTime? estimatedDeliveryTime;
  final OrderModel? order;
  final DriverModel? driver;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DriverRequestModel({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.status,
    this.estimatedPickupTime,
    this.estimatedDeliveryTime,
    this.order,
    this.driver,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ FIXED: Safe parsing using ParsingHelper sesuai response backend
  factory DriverRequestModel.fromJson(Map<String, dynamic> json) {
    return DriverRequestModel(
      id: ParsingHelper.parseIntWithDefault(json['id'], 0),
      orderId: ParsingHelper.parseIntWithDefault(json['order_id'], 0),
      driverId: ParsingHelper.parseIntWithDefault(json['driver_id'], 0),
      status: json['status'] as String? ?? 'pending',
      estimatedPickupTime: json['estimated_pickup_time'] != null
          ? DateTime.tryParse(json['estimated_pickup_time'] as String)
          : null,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.tryParse(json['estimated_delivery_time'] as String)
          : null,
      order: json['order'] != null
          ? OrderModel.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'driver_id': driverId,
      'status': status,
      'estimated_pickup_time': estimatedPickupTime?.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'order': order?.toJson(),
      'driver': driver?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DriverRequestModel copyWith({
    int? id,
    int? orderId,
    int? driverId,
    String? status,
    DateTime? estimatedPickupTime,
    DateTime? estimatedDeliveryTime,
    OrderModel? order,
    DriverModel? driver,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverRequestModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      estimatedPickupTime: estimatedPickupTime ?? this.estimatedPickupTime,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      order: order ?? this.order,
      driver: driver ?? this.driver,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Status checks (sesuai backend: pending, accepted, rejected, expired, completed)
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';
  bool get isCompleted => status == 'completed';

  bool get isActive => isPending || isAccepted;
  bool get canRespond => isPending;
  bool get canAccept => isPending;
  bool get canReject => isPending;

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      case 'expired':
        return 'Kedaluwarsa';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  String get orderCode => 'ORD-${orderId.toString().padLeft(6, '0')}';
  String get storeName => order?.store?.name ?? '';
  String get customerName => order?.customer?.name ?? '';
  String get customerPhone => order?.customer?.phone ?? '';
  double get orderTotal => order?.totalAmount ?? 0.0;
  double get deliveryFee => order?.deliveryFee ?? 0.0;

  String get formattedCreatedAt {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year} ${createdAt!.hour}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }

  Duration? get timeElapsed {
    if (createdAt == null) return null;
    return DateTime.now().difference(createdAt!);
  }

  String get timeElapsedString {
    final elapsed = timeElapsed;
    if (elapsed == null) return '';

    if (elapsed.inMinutes < 1) {
      return 'Baru saja';
    } else if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} menit yang lalu';
    } else if (elapsed.inHours < 24) {
      return '${elapsed.inHours} jam yang lalu';
    } else {
      return '${elapsed.inDays} hari yang lalu';
    }
  }

  // ✅ FIXED: Helper methods untuk data order - menggunakan getter yang ada di OrderModel
  String get orderStatusDisplayName => order?.statusDisplayName ?? '';
  String get deliveryStatusDisplayName => order?.deliveryStatusText ?? '';

  bool get hasEstimatedTimes =>
      estimatedPickupTime != null && estimatedDeliveryTime != null;

  String get formattedEstimatedPickupTime {
    if (estimatedPickupTime == null) return '';
    final time = estimatedPickupTime!;
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEstimatedDeliveryTime {
    if (estimatedDeliveryTime == null) return '';
    final time = estimatedDeliveryTime!;
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DriverRequestModel{id: $id, orderId: $orderId, driverId: $driverId, status: $status}';
  }
}
