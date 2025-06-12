import 'dart:convert';

class RouteInfo {
  final double distance; // in meters
  final double duration; // in seconds
  final List<List<double>> coordinates;
  final String geometry;

  RouteInfo({
    required this.distance,
    required this.duration,
    required this.coordinates,
    required this.geometry,
  });

  factory RouteInfo.fromMapbox(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final coordinates = (geometry['coordinates'] as List)
        .map<List<double>>(
            (coord) => [coord[0].toDouble(), coord[1].toDouble()])
        .toList();

    return RouteInfo(
      distance: json['distance'].toDouble(),
      duration: json['duration'].toDouble(),
      coordinates: coordinates,
      geometry: jsonEncode(geometry),
    );
  }
}
