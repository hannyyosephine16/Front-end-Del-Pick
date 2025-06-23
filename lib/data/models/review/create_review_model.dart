// lib/data/models/review/create_review_model.dart
class CreateReviewRequest {
  final OrderReviewRequest orderReview;
  final DriverReviewRequest driverReview;

  CreateReviewRequest({
    required this.orderReview,
    required this.driverReview,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_review': orderReview.toJson(),
      'driver_review': driverReview.toJson(),
    };
  }

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) {
    return CreateReviewRequest(
      orderReview: OrderReviewRequest.fromJson(json['order_review']),
      driverReview: DriverReviewRequest.fromJson(json['driver_review']),
    );
  }
}

class OrderReviewRequest {
  final int rating;
  final String? comment;

  OrderReviewRequest({
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }

  factory OrderReviewRequest.fromJson(Map<String, dynamic> json) {
    return OrderReviewRequest(
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
    );
  }
}

class DriverReviewRequest {
  final int rating;
  final String? comment;

  DriverReviewRequest({
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }

  factory DriverReviewRequest.fromJson(Map<String, dynamic> json) {
    return DriverReviewRequest(
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
    );
  }
}
