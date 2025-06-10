import '../../../core/constants/driver_status_constants.dart';

/// Model untuk detail perubahan status
class DriverStatusChangeModel {
  final String from;
  final String to;
  final DateTime timestamp;
  final String? title;
  final String? action;
  final bool forced;
  final String? reason;
  final int? adminId;

  DriverStatusChangeModel({
    required this.from,
    required this.to,
    required this.timestamp,
    this.title,
    this.action,
    this.forced = false,
    this.reason,
    this.adminId,
  });

  factory DriverStatusChangeModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusChangeModel(
      from: json['from'] as String,
      to: json['to'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String?,
      action: json['action'] as String?,
      forced: json['forced'] as bool? ?? false,
      reason: json['reason'] as String?,
      adminId: json['adminId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'action': action,
      'forced': forced,
      'reason': reason,
      'adminId': adminId,
    };
  }

  String get fromDisplayName => DriverStatusConstants.getDriverStatusName(from);
  String get toDisplayName => DriverStatusConstants.getDriverStatusName(to);

  String get changeDescription {
    if (forced) {
      return 'Status changed from $fromDisplayName to $toDisplayName by admin${reason != null ? ': $reason' : ''}';
    }
    return 'Status changed from $fromDisplayName to $toDisplayName';
  }

  bool get isUpgrade => _getStatusPriority(to) > _getStatusPriority(from);
  bool get isDowngrade => _getStatusPriority(to) < _getStatusPriority(from);

  int _getStatusPriority(String status) {
    switch (status) {
      case DriverStatusConstants.inactive:
        return 0;
      case DriverStatusConstants.active:
        return 1;
      case DriverStatusConstants.busy:
        return 2;
      default:
        return -1;
    }
  }

  @override
  String toString() {
    return 'DriverStatusChangeModel{from: $from, to: $to, timestamp: $timestamp}';
  }
}
