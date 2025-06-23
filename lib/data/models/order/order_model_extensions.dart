// lib/data/models/order/order_model_extensions.dart - NEW FILE
import 'package:flutter/material.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';

extension OrderModelExtensions on OrderModel {
  // ✅ Status checking methods
  bool get isPending => orderStatus == OrderStatusConstants.pending;
  bool get isConfirmed => orderStatus == OrderStatusConstants.confirmed;
  bool get isPreparing => orderStatus == OrderStatusConstants.preparing;
  bool get isReadyForPickup =>
      orderStatus == OrderStatusConstants.readyForPickup;
  bool get isOnDelivery => orderStatus == OrderStatusConstants.onDelivery;
  bool get isDelivered => orderStatus == OrderStatusConstants.delivered;
  bool get isCancelled => orderStatus == OrderStatusConstants.cancelled;
  bool get isRejected => orderStatus == OrderStatusConstants.rejected;

  // Helper methods
  bool get isActive => OrderStatusConstants.isActive(orderStatus);
  bool get isCompleted => OrderStatusConstants.isCompleted(orderStatus);
  bool get canCancel => OrderStatusConstants.canCancel(orderStatus);
  bool get canTrack => OrderStatusConstants.canTrack(orderStatus);

  String get statusDisplayName =>
      OrderStatusConstants.getStatusName(orderStatus);
  Color get statusColor => OrderStatusConstants.getStatusColor(orderStatus);

  // ✅ Generate order code dari ID
  String get code => 'ORD${id.toString().padLeft(6, '0')}';

  // ✅ Total calculations
  double get total => totalAmount + deliveryFee;
  String get formattedTotal =>
      'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  // Store name from relationship
  String get storeName => store?.name ?? 'Unknown Store';
}
