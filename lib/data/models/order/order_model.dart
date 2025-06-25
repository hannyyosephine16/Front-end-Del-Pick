// lib/data/models/order/order_model.dart - IMPROVED VERSION
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';
import 'order_item_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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
  final List<Map<String, dynamic>> trackingUpdates;
  final List<OrderItemModel>? items;
  final StoreModel? store;
  final UserModel? customer;
  final DriverModel? driver;
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
    this.trackingUpdates = const [],
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
      cancellationReason: json['cancellation_reason'] as String?,
      trackingUpdates: _parseTrackingUpdates(json['tracking_updates']),
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
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // ✅ FIXED: Robust _parseTrackingUpdates method
  static List<Map<String, dynamic>> _parseTrackingUpdates(dynamic value) {
    if (value == null) return [];

    try {
      // Case 1: Already a List
      if (value is List) {
        final List<Map<String, dynamic>> result = [];

        for (final item in value) {
          if (item is Map<String, dynamic>) {
            result.add(item);
          } else if (item is Map) {
            result.add(Map<String, dynamic>.from(item));
          } else if (item is String) {
            try {
              final parsed = jsonDecode(item);
              if (parsed is Map<String, dynamic>) {
                result.add(parsed);
              } else if (parsed is Map) {
                result.add(Map<String, dynamic>.from(parsed));
              }
            } catch (e) {
              print('Error parsing tracking update item: $e');
              // Add empty map as fallback
              result.add(<String, dynamic>{});
            }
          } else {
            // Add empty map for unknown types
            result.add(<String, dynamic>{});
          }
        }

        return result;
      }

      // Case 2: String (might be JSON)
      if (value is String) {
        String cleanedValue = value.trim();

        // Handle empty cases
        if (cleanedValue.isEmpty ||
            cleanedValue == '[]' ||
            cleanedValue == 'null' ||
            cleanedValue == '""') {
          return [];
        }

        // Try to parse as JSON
        try {
          final parsed = jsonDecode(cleanedValue);

          // If parsed result is a List, recursively call this method
          if (parsed is List) {
            return _parseTrackingUpdates(parsed);
          }

          // If parsed result is a single Map, wrap it in a List
          if (parsed is Map) {
            return [Map<String, dynamic>.from(parsed)];
          }
        } catch (e) {
          print('Error parsing JSON string: $cleanedValue - Error: $e');

          // Try to handle escaped JSON as fallback
          try {
            // Remove extra quotes if present
            String unescaped = cleanedValue;
            if (unescaped.startsWith('"') && unescaped.endsWith('"')) {
              unescaped = unescaped.substring(1, unescaped.length - 1);
            }

            // Replace escaped quotes
            unescaped = unescaped.replaceAll('\\"', '"');
            unescaped = unescaped.replaceAll('\\\\', '\\');

            final parsed = jsonDecode(unescaped);
            if (parsed is List) {
              return _parseTrackingUpdates(parsed);
            }
            if (parsed is Map) {
              return [Map<String, dynamic>.from(parsed)];
            }
          } catch (e2) {
            print('Error parsing escaped JSON: $e2');
          }
        }
      }

      // Case 3: Map (single tracking update)
      if (value is Map) {
        return [Map<String, dynamic>.from(value)];
      }

      return [];
    } catch (e) {
      print('Error in _parseTrackingUpdates: $e');
      return [];
    }
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
      'driver': driver?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ IMPROVED: Better isActive check using OrderStatusConstants
  bool get isActive {
    return OrderStatusConstants.isActive(orderStatus);
  }

  // ✅ IMPROVED: Better canTrack check using OrderStatusConstants
  bool get canTrack {
    return OrderStatusConstants.canTrack(orderStatus);
  }

  // ✅ FIXED: Delivery address sesuai backend (destinasi fixed ke IT Del)
  String get deliveryAddress {
    return 'Institut Teknologi Del, Laguboti, Toba, North Sumatra, Indonesia';
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

  // ✅ Driver information - Backend Compatible
  String get driverName => driver?.name ?? 'No Driver Assigned';
  bool get hasDriver => driverId != null && driver != null;

  // ✅ ADDED: Additional useful getters
  bool get hasTrackingUpdates => trackingUpdates.isNotEmpty;

  List<Map<String, dynamic>> get formattedTrackingUpdates => trackingUpdates;

  // ✅ ADDED: Status checking methods for compatibility with extensions
  bool get isPending => orderStatus == OrderStatusConstants.pending;
  bool get isConfirmed => orderStatus == OrderStatusConstants.confirmed;
  bool get isPreparing => orderStatus == OrderStatusConstants.preparing;
  bool get isReadyForPickup =>
      orderStatus == OrderStatusConstants.readyForPickup;
  bool get isOnDelivery => orderStatus == OrderStatusConstants.onDelivery;
  bool get isDelivered => orderStatus == OrderStatusConstants.delivered;
  bool get isCancelled => orderStatus == OrderStatusConstants.cancelled;
  bool get isRejected => orderStatus == OrderStatusConstants.rejected;

  // ✅ ADDED: Additional capabilities
  bool get canCancel => OrderStatusConstants.canCancel(orderStatus);
  bool get isCompleted => OrderStatusConstants.isCompleted(orderStatus);

  bool get canReview {
    return orderStatus == OrderStatusConstants.delivered;
  }

  bool get canReorder {
    return orderStatus == OrderStatusConstants.delivered ||
        orderStatus == OrderStatusConstants.cancelled ||
        orderStatus == OrderStatusConstants.rejected;
  }

  // ✅ ADDED: copyWith method for immutability
  OrderModel copyWith({
    int? id,
    int? customerId,
    int? storeId,
    int? driverId,
    String? orderStatus,
    String? deliveryStatus,
    double? totalAmount,
    double? deliveryFee,
    double? destinationLatitude,
    double? destinationLongitude,
    DateTime? estimatedPickupTime,
    DateTime? actualPickupTime,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    String? cancellationReason,
    List<Map<String, dynamic>>? trackingUpdates,
    List<OrderItemModel>? items,
    StoreModel? store,
    UserModel? customer,
    DriverModel? driver,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      driverId: driverId ?? this.driverId,
      orderStatus: orderStatus ?? this.orderStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      estimatedPickupTime: estimatedPickupTime ?? this.estimatedPickupTime,
      actualPickupTime: actualPickupTime ?? this.actualPickupTime,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      trackingUpdates: trackingUpdates ?? this.trackingUpdates,
      items: items ?? this.items,
      store: store ?? this.store,
      customer: customer ?? this.customer,
      driver: driver ?? this.driver,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderModel{id: $id, orderStatus: $orderStatus, deliveryStatus: $deliveryStatus, total: $totalAmount}';
  }
}
