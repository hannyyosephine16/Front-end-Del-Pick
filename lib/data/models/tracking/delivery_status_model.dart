// lib/data/models/tracking/delivery_status_model.dart
import 'package:del_pick/core/constants/app_constants.dart';

class DeliveryStatusModel {
  final String status;
  final String displayName;
  final String description;
  final DateTime? timestamp;

  DeliveryStatusModel({
    required this.status,
    required this.displayName,
    required this.description,
    this.timestamp,
  });

  factory DeliveryStatusModel.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusModel(
      status: json['status'] as String,
      displayName:
          json['display_name'] as String? ?? _getDisplayName(json['status']),
      description:
          json['description'] as String? ?? _getDescription(json['status']),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'display_name': displayName,
      'description': description,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  static String _getDisplayName(String status) {
    switch (status) {
      case AppConstants.deliveryPending:
        return 'Menunggu';
      case AppConstants.deliveryPickedUp:
        return 'Diambil';
      case AppConstants.deliveryOnWay:
        return 'Dalam Perjalanan';
      case AppConstants.deliveryDelivered:
        return 'Terkirim';
      default:
        return status;
    }
  }

  static String _getDescription(String status) {
    switch (status) {
      case AppConstants.deliveryPending:
        return 'Menunggu driver mengambil pesanan';
      case AppConstants.deliveryPickedUp:
        return 'Pesanan sudah diambil driver';
      case AppConstants.deliveryOnWay:
        return 'Driver sedang dalam perjalanan';
      case AppConstants.deliveryDelivered:
        return 'Pesanan sudah sampai tujuan';
      default:
        return '';
    }
  }

  bool get isPending => status == AppConstants.deliveryPending;
  bool get isPickedUp => status == AppConstants.deliveryPickedUp;
  bool get isOnWay => status == AppConstants.deliveryOnWay;
  bool get isDelivered => status == AppConstants.deliveryDelivered;
}
