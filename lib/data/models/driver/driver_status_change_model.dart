// lib/data/models/driver/driver_status_change_model.dart - FIXED VERSION
import '../../../core/constants/driver_status_constants.dart';

class DriverStatusChangeModel {
  final String from;
  final String to;
  final DateTime timestamp;
  final String? reason;
  final bool automated;

  DriverStatusChangeModel({
    required this.from,
    required this.to,
    required this.timestamp,
    this.reason,
    this.automated = false,
  });

  factory DriverStatusChangeModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusChangeModel(
      from: json['from'] as String,
      to: json['to'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reason: json['reason'] as String?,
      automated: json['automated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
      'automated': automated,
    };
  }

  String get fromDisplayName => DriverStatusConstants.getDriverStatusName(from);
  String get toDisplayName => DriverStatusConstants.getDriverStatusName(to);

  String get changeDescription {
    if (automated) {
      return 'Status changed automatically from $fromDisplayName to $toDisplayName${reason != null ? ': $reason' : ''}';
    }
    return 'Status changed from $fromDisplayName to $toDisplayName${reason != null ? ': $reason' : ''}';
  }

  bool get isUpgrade => _getStatusPriority(to) > _getStatusPriority(from);
  bool get isDowngrade => _getStatusPriority(to) < _getStatusPriority(from);

  int _getStatusPriority(String status) {
    return DriverStatusConstants.getDriverStatusPriority(status);
  }

  @override
  String toString() {
    return 'DriverStatusChangeModel{from: $from, to: $to, timestamp: $timestamp}';
  }
}
