import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';
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
  final String? cancellationReason; // ✅ ADDED: Backend field
  final List<dynamic>? trackingUpdates;
  final List<OrderItemModel>? items;
  final StoreModel? store;
  final UserModel? customer;
  final DriverModel? driver; // ✅ FIXED: Should be DriverModel, not dynamic
  final DateTime createdAt;
  final DateTime updatedAt;

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

  // ✅ FIXED: Safe parsing and handle all backend fields
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: ParsingHelper.parseIntWithDefault(json['id'], 0),
      customerId: ParsingHelper.parseIntWithDefault(json['customer_id'], 0),
      storeId: ParsingHelper.parseIntWithDefault(json['store_id'], 0),
      driverId: ParsingHelper.parseInt(json['driver_id']),
      orderStatus: json['order_status'] as String? ?? 'pending',
      deliveryStatus: json['delivery_status'] as String? ?? 'pending',
      totalAmount:
          ParsingHelper.parseDoubleWithDefault(json['total_amount'], 0.0),
      deliveryFee:
          ParsingHelper.parseDoubleWithDefault(json['delivery_fee'], 0.0),
      destinationLatitude:
          ParsingHelper.parseDouble(json['destination_latitude']),
      destinationLongitude:
          ParsingHelper.parseDouble(json['destination_longitude']),
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
      cancellationReason: json['cancellation_reason'] as String?, // ✅ ADDED
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
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null, // ✅ FIXED: Proper type
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
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
      'cancellation_reason': cancellationReason, // ✅ ADDED
      'tracking_updates': trackingUpdates,
      'items': items?.map((item) => item.toJson()).toList(),
      'store': store?.toJson(),
      'customer': customer?.toJson(),
      'driver': driver?.toJson(), // ✅ FIXED
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ Delivery address - Static sesuai backend (destinasi fixed)
  String get deliveryAddress {
    return 'Medan, North Sumatra, Indonesia';
  }

  // Helper getters
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

  // ✅ FIXED: Driver name access
  String get driverName => driver?.name ?? 'No Driver Assigned';
  bool get hasDriver => driverId != null && driver != null;

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
