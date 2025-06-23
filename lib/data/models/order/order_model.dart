// lib/data/models/order/order_model.dart - ADD THESE GETTERS
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'order_item_model.dart';
import 'package:intl/intl.dart';

class OrderModel {
  final int id;
  final int customerId;
  final int storeId;
  final int? driverId;
  final String orderStatus;
  final String deliveryStatus;
  final double totalAmount;
  final double deliveryFee;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final DateTime? estimatedPickupTime;
  final DateTime? actualPickupTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final String? cancellationReason;
  final List<dynamic>? trackingUpdates;
  final List<OrderItemModel>? items;
  final StoreModel? store;
  final UserModel? customer;
  final dynamic driver; // ✅ Changed to dynamic to handle backend structure
  final DateTime createdAt;
  final DateTime updatedAt;
  // ... existing fields and constructor ...

  OrderModel({
    required this.id,
    required this.customerId,
    required this.storeId,
    this.driverId,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.totalAmount,
    required this.deliveryFee,
    this.destinationLatitude,
    this.destinationLongitude,
    this.estimatedPickupTime,
    this.actualPickupTime,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.cancellationReason,
    this.trackingUpdates,
    this.items,
    this.store,
    this.customer,
    this.driver,
    required this.createdAt,
    required this.updatedAt,
  });

  // ✅ ADD THESE GETTERS
  String get code => 'ORD${id.toString().padLeft(6, '0')}';

  String get statusDisplayName =>
      OrderStatusConstants.getStatusName(orderStatus);

  String get storeName => store?.name ?? 'Unknown Store';

  String get formattedOrderDate {
    return DateFormat('MMM dd, yyyy • HH:mm').format(createdAt);
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(createdAt);
  }

  int get totalItems {
    if (items == null) return 0;
    return items!.fold(0, (sum, item) => sum + item.quantity);
  }

  double get grandTotal => totalAmount + deliveryFee;

  String get formattedTotal =>
      'Rp ${grandTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  // ✅ Existing methods stay the same
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      storeId: json['store_id'] as int,
      driverId: json['driver_id'] as int?,
      orderStatus: json['order_status'] as String,
      deliveryStatus: json['delivery_status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      destinationLatitude: (json['destination_latitude'] as num?)?.toDouble(),
      destinationLongitude: (json['destination_longitude'] as num?)?.toDouble(),
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
      cancellationReason: json['cancellation_reason'] as String?,
      trackingUpdates: json['tracking_updates'] as List<dynamic>?,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) =>
                  OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      store: json['store'] != null
          ? StoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      driver: json['driver'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'store_id': storeId,
      'driver_id': driverId,
      'order_status': orderStatus,
      'delivery_status': deliveryStatus,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'estimated_pickup_time': estimatedPickupTime?.toIso8601String(),
      'actual_pickup_time': actualPickupTime?.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'actual_delivery_time': actualDeliveryTime?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'tracking_updates': trackingUpdates,
      'items': items?.map((item) => item.toJson()).toList(),
      'store': store?.toJson(),
      'customer': customer?.toJson(),
      'driver': driver,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderModel{id: $id, status: $orderStatus, total: $totalAmount}';
  }
}
