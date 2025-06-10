class DriverStatusMetricsModel {
  final double onlinePercentage;
  final int offlineCount;
  final int workingCount;
  final int availableCount;

  DriverStatusMetricsModel({
    required this.onlinePercentage,
    required this.offlineCount,
    required this.workingCount,
    required this.availableCount,
  });

  factory DriverStatusMetricsModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusMetricsModel(
      onlinePercentage: (json['onlinePercentage'] as num?)?.toDouble() ?? 0.0,
      offlineCount: json['offlineCount'] as int? ?? 0,
      workingCount: json['workingCount'] as int? ?? 0,
      availableCount: json['availableCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onlinePercentage': onlinePercentage,
      'offlineCount': offlineCount,
      'workingCount': workingCount,
      'availableCount': availableCount,
    };
  }

  String get formattedOnlinePercentage =>
      '${onlinePercentage.toStringAsFixed(1)}%';
}
