import 'package:del_pick/data/models/mapbox/route_info.dart';

class DeliveryRoute {
  final RouteInfo toStore;
  final RouteInfo toCustomer;
  final Duration totalDuration;
  final double totalDistance;

  DeliveryRoute({
    required this.toStore,
    required this.toCustomer,
    required this.totalDuration,
    required this.totalDistance,
  });

  factory DeliveryRoute.fromMapbox(Map<String, dynamic> json) {
    final routes = json['routes'] as List;
    final mainRoute = routes[0];
    final legs = mainRoute['legs'] as List;

    final toStore = RouteInfo.fromMapbox({
      'distance': legs[0]['distance'],
      'duration': legs[0]['duration'],
      'geometry': mainRoute['geometry'],
    });

    final toCustomer = RouteInfo.fromMapbox({
      'distance': legs[1]['distance'],
      'duration': legs[1]['duration'],
      'geometry': mainRoute['geometry'],
    });

    return DeliveryRoute(
      toStore: toStore,
      toCustomer: toCustomer,
      totalDuration: Duration(seconds: mainRoute['duration'].toInt()),
      totalDistance: mainRoute['distance'].toDouble(),
    );
  }
}
