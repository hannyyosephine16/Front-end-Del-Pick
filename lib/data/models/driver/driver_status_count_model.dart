class DriverStatusCountModel {
  final int active;
  final int inactive;
  final int busy;
  final int total;

  DriverStatusCountModel({
    required this.active,
    required this.inactive,
    required this.busy,
    required this.total,
  });

  factory DriverStatusCountModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusCountModel(
      active: json['active'] as int? ?? 0,
      inactive: json['inactive'] as int? ?? 0,
      busy: json['busy'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'inactive': inactive,
      'busy': busy,
      'total': total,
    };
  }

  int get totalOnline => active + busy;
  double get onlinePercentage => total > 0 ? (totalOnline / total * 100) : 0.0;
}
