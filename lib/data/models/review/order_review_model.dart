// lib/data/models/review/order_review_model.dart
import 'package:del_pick/data/models/auth/user_model.dart';

class OrderReviewModel {
  final int id;
  final int orderId;
  final int customerId;
  final int rating;
  final String? comment;
  final UserModel? customer;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.rating,
    this.comment,
    this.customer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderReviewModel.fromJson(Map<String, dynamic> json) {
    return OrderReviewModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      customerId: json['customer_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
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
      'customer_id': customerId,
      'rating': rating,
      'comment': comment,
      'customer': customer?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderReviewModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
