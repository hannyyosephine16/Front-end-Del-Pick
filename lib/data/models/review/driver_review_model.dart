// lib/data/models/review/driver_review_model.dart
import 'package:del_pick/data/models/auth/user_model.dart';

class DriverReviewModel {
  final int id;
  final int orderId;
  final int driverId;
  final int customerId;
  final int rating;
  final String? comment;
  final bool isAutoGenerated;
  final UserModel? customer;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverReviewModel({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.customerId,
    required this.rating,
    this.comment,
    required this.isAutoGenerated,
    this.customer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverReviewModel.fromJson(Map<String, dynamic> json) {
    return DriverReviewModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      driverId: json['driver_id'] as int,
      customerId: json['customer_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      isAutoGenerated: json['is_auto_generated'] as bool? ?? false,
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'driver_id': driverId,
      'customer_id': customerId,
      'rating': rating,
      'comment': comment,
      'is_auto_generated': isAutoGenerated,
      'customer': customer?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverReviewModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
