import 'driver_status_count_model.dart';
import 'driver_status_metrics_model.dart';

class DriverStatusSummaryModel {
  final DriverStatusCountModel summary;
  final DriverStatusMetricsModel metrics;
  final DateTime timestamp;

  DriverStatusSummaryModel({
    required this.summary,
    required this.metrics,
    required this.timestamp,
  });

  factory DriverStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusSummaryModel(
      summary: DriverStatusCountModel.fromJson(
          json['summary'] as Map<String, dynamic>),
      metrics: DriverStatusMetricsModel.fromJson(
          json['metrics'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'metrics': metrics.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
