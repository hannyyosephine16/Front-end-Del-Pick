// lib/data/models/driver/driver_status_model.dart
import 'package:del_pick/core/constants/driver_status_constants.dart';
import 'driver_location_model.dart';

/// Model untuk driver status dengan business logic
class DriverStatusModel {
  final String status;
  final List<String> validTransitions;
  final bool hasActiveOrders;
  final int activeOrderCount;
  final DateTime lastUpdated;
  final DriverLocationModel? location;
  final List<String> activeOrderIds;

  DriverStatusModel({
    required this.status,
    required this.validTransitions,
    required this.hasActiveOrders,
    required this.activeOrderCount,
    required this.lastUpdated,
    this.location,
    this.activeOrderIds = const [],
  });

  factory DriverStatusModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusModel(
      status: json['current'] as String,
      validTransitions: (json['canTransitionTo'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hasActiveOrders: json['hasActiveOrders'] as bool? ?? false,
      activeOrderCount: json['activeOrderCount'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      location: json['location'] != null
          ? DriverLocationModel.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
      activeOrderIds: (json['activeOrderIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': status,
      'canTransitionTo': validTransitions,
      'hasActiveOrders': hasActiveOrders,
      'activeOrderCount': activeOrderCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'location': location?.toJson(),
      'activeOrderIds': activeOrderIds,
    };
  }

  // Status checks
  bool get isActive => status == DriverStatusConstants.active;
  bool get isInactive => status == DriverStatusConstants.inactive;
  bool get isBusy => status == DriverStatusConstants.busy;
  bool get isOffline => status == DriverStatusConstants.offline;

  // Transition checks
  bool get canGoOnline =>
      validTransitions.contains(DriverStatusConstants.active);
  bool get canGoOffline =>
      validTransitions.contains(DriverStatusConstants.inactive);
  bool get canBeBusy => validTransitions.contains(DriverStatusConstants.busy);

  // Business logic checks
  bool get canToggleStatus => !isBusy && activeOrderCount == 0;
  bool get requiresLocationPermission =>
      canGoOnline && (location?.hasLocation != true);
  bool get hasValidLocation => location?.hasLocation == true;

  // Display helpers
  String get statusDisplayName =>
      DriverStatusConstants.getDriverStatusName(status);
  String get statusDescription =>
      DriverStatusConstants.getDriverStatusDescription(status);

  String get toggleActionText {
    if (isActive) return 'Go Offline';
    if (isInactive) return 'Go Online';
    if (isBusy) return 'Busy';
    return 'Toggle Status';
  }

  String get blockingReason {
    if (isBusy) return 'Complete current delivery to change status';
    if (hasActiveOrders)
      return 'Complete $activeOrderCount active orders first';
    if (requiresLocationPermission)
      return 'Location permission required to go online';
    return '';
  }

  bool get hasBlockingReason => blockingReason.isNotEmpty;

  DriverStatusModel copyWith({
    String? status,
    List<String>? validTransitions,
    bool? hasActiveOrders,
    int? activeOrderCount,
    DateTime? lastUpdated,
    DriverLocationModel? location,
    List<String>? activeOrderIds,
  }) {
    return DriverStatusModel(
      status: status ?? this.status,
      validTransitions: validTransitions ?? this.validTransitions,
      hasActiveOrders: hasActiveOrders ?? this.hasActiveOrders,
      activeOrderCount: activeOrderCount ?? this.activeOrderCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      location: location ?? this.location,
      activeOrderIds: activeOrderIds ?? this.activeOrderIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverStatusModel &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode => status.hashCode ^ lastUpdated.hashCode;

  @override
  String toString() {
    return 'DriverStatusModel{status: $status, validTransitions: $validTransitions, hasActiveOrders: $hasActiveOrders}';
  }
}
