import 'driver_status_change_model.dart';

/// Model untuk response status change
class DriverStatusChangeResponse {
  final String message;
  final DriverStatusChangeModel statusChange;
  final String? businessRule;
  final Map<String, dynamic>? additionalData;

  DriverStatusChangeResponse({
    required this.message,
    required this.statusChange,
    this.businessRule,
    this.additionalData,
  });

  factory DriverStatusChangeResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatusChangeResponse(
      message: json['message'] as String,
      statusChange: DriverStatusChangeModel.fromJson(
        json['data']['statusChange'] as Map<String, dynamic>,
      ),
      businessRule: json['businessRule'] as String?,
      additionalData: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusChange': statusChange.toJson(),
      'businessRule': businessRule,
      'additionalData': additionalData,
    };
  }

  bool get isSuccess => businessRule == null;
  bool get isBusinessRuleViolation => businessRule != null;

  @override
  String toString() {
    return 'DriverStatusChangeResponse{message: $message, isSuccess: $isSuccess}';
  }
}
