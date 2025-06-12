// // lib/core/services/external/mapbox_service.dart
// import 'dart:async';
// import 'dart:math' as math;
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:get/get.dart' as getx;
// import 'package:del_pick/core/services/external/location_service.dart';
//
// class MapboxService extends getx.GetxService {
//   final LocationService _locationService = getx.Get.find<LocationService>();
//
//   // Mapbox API base URL
//   static const String _baseUrl = 'https://api.mapbox.com';
//   static const String _accessToken =
//       'YOUR_MAPBOX_ACCESS_TOKEN'; // Ganti dengan token Anda
//
//   // Get route between two points using Mapbox Directions API
//   Future<Map<String, dynamic>?> getRoute({
//     required double startLat,
//     required double startLng,
//     required double endLat,
//     required double endLng,
//     String profile = 'driving', // driving, walking, cycling
//   }) async {
//     try {
//       final String url =
//           '$_baseUrl/directions/v5/mapbox/$profile/$startLng,$startLat;$endLng,$endLat'
//           '?access_token=$_accessToken'
//           '&geometries=geojson'
//           '&overview=full'
//           '&steps=true';
//
//       // Implementasi HTTP request di sini
//       // Untuk sekarang, return simulasi data
//       return {
//         'routes': [
//           {
//             'geometry': {
//               'coordinates': [
//                 [startLng, startLat],
//                 [endLng, endLat]
//               ]
//             },
//             'distance':
//                 calculateDistance(startLat, startLng, endLat, endLng) * 1000,
//             'duration':
//                 (calculateDistance(startLat, startLng, endLat, endLng) / 40) *
//                     3600, // Asumsi 40 km/h
//             'legs': [
//               {'steps': []}
//             ]
//           }
//         ]
//       };
//     } catch (e) {
//       print('Error getting route: $e');
//       return null;
//     }
//   }
//
//   // Get address from coordinates using Mapbox Geocoding
//   Future<String> getAddressFromCoordinates(
//     double latitude,
//     double longitude,
//   ) async {
//     try {
//       // Gunakan geocoding package sebagai fallback
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         latitude,
//         longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         return '${place.street}, ${place.subLocality}, ${place.locality}';
//       }
//
//       return 'Alamat tidak diketahui';
//     } catch (e) {
//       print('Error getting address: $e');
//       return 'Error mendapatkan alamat';
//     }
//   }
//
//   // Get coordinates from address using Mapbox Geocoding
//   Future<Position?> getCoordinatesFromAddress(String address) async {
//     try {
//       List<Location> locations = await locationFromAddress(address);
//
//       if (locations.isNotEmpty) {
//         Location location = locations[0];
//         return Position(
//           latitude: location.latitude,
//           longitude: location.longitude,
//           timestamp: DateTime.now(),
//           accuracy: 0,
//           altitude: 0,
//           altitudeAccuracy: 0,
//           heading: 0,
//           headingAccuracy: 0,
//           speed: 0,
//           speedAccuracy: 0,
//         );
//       }
//
//       return null;
//     } catch (e) {
//       print('Error getting coordinates: $e');
//       return null;
//     }
//   }
//
//   // Calculate distance between two points
//   double calculateDistance(
//     double startLatitude,
//     double startLongitude,
//     double endLatitude,
//     double endLongitude,
//   ) {
//     return _locationService.calculateDistance(
//       startLatitude,
//       startLongitude,
//       endLatitude,
//       endLongitude,
//     );
//   }
//
//   // Calculate estimated delivery time
//   Duration calculateEstimatedDeliveryTime(double distanceInKm) {
//     // Kecepatan rata-rata delivery: 25 km/h
//     const averageSpeed = 25.0;
//     final timeInHours = distanceInKm / averageSpeed;
//     final timeInMinutes = (timeInHours * 60).round();
//
//     // Tambah buffer time (10-20 menit)
//     final bufferTime = (distanceInKm * 2).round().clamp(10, 20);
//
//     return Duration(minutes: timeInMinutes + bufferTime);
//   }
//
//   // Check if location is within delivery radius
//   bool isWithinDeliveryRadius(
//     double storeLatitude,
//     double storeLongitude,
//     double customerLatitude,
//     double customerLongitude,
//     double radiusInKm,
//   ) {
//     final distance = calculateDistance(
//       storeLatitude,
//       storeLongitude,
//       customerLatitude,
//       customerLongitude,
//     );
//
//     return distance <= radiusInKm;
//   }
//
//   // Format distance for display
//   String formatDistance(double distanceInKm) {
//     if (distanceInKm < 1.0) {
//       return '${(distanceInKm * 1000).round()} m';
//     } else {
//       return '${distanceInKm.toStringAsFixed(1)} km';
//     }
//   }
//
//   // Format duration for display
//   String formatDuration(Duration duration) {
//     if (duration.inHours > 0) {
//       return '${duration.inHours}j ${duration.inMinutes % 60}m';
//     } else {
//       return '${duration.inMinutes}m';
//     }
//   }
//
//   // Get static map URL for Mapbox
//   String getStaticMapUrl(
//     double latitude,
//     double longitude, {
//     int zoom = 15,
//     int width = 400,
//     int height = 300,
//     String style = 'streets-v11',
//   }) {
//     return 'https://api.mapbox.com/styles/v1/mapbox/$style/static/'
//         'pin-s+ff0000($longitude,$latitude)/'
//         '$longitude,$latitude,$zoom/${width}x$height'
//         '?access_token=$_accessToken';
//   }
//
//   // Convert coordinates to map bounds
//   Map<String, double> getMapBounds(List<Position> positions) {
//     if (positions.isEmpty) {
//       return {};
//     }
//
//     double minLat = positions.first.latitude;
//     double maxLat = positions.first.latitude;
//     double minLng = positions.first.longitude;
//     double maxLng = positions.first.longitude;
//
//     for (Position position in positions) {
//       minLat = math.min(minLat, position.latitude);
//       maxLat = math.max(maxLat, position.latitude);
//       minLng = math.min(minLng, position.longitude);
//       maxLng = math.max(maxLng, position.longitude);
//     }
//
//     return {
//       'minLatitude': minLat,
//       'maxLatitude': maxLat,
//       'minLongitude': minLng,
//       'maxLongitude': maxLng,
//     };
//   }
//
//   // Get nearby stores using Mapbox Geocoding
//   Future<List<Map<String, dynamic>>> getNearbyStores(
//     double latitude,
//     double longitude,
//     double radiusKm,
//   ) async {
//     try {
//       // Implementasi pencarian toko terdekat
//       // Ini biasanya akan memanggil API backend Anda
//       // yang kemudian menggunakan database spatial queries
//
//       // Untuk demo, return data dummy
//       return [
//         {
//           'id': 1,
//           'name': 'Warung Padang Sederhana',
//           'latitude': latitude + 0.001,
//           'longitude': longitude + 0.001,
//           'distance': 0.2,
//         },
//         {
//           'id': 2,
//           'name': 'Ayam Geprek Mantul',
//           'latitude': latitude + 0.002,
//           'longitude': longitude - 0.001,
//           'distance': 0.3,
//         },
//       ];
//     } catch (e) {
//       print('Error getting nearby stores: $e');
//       return [];
//     }
//   }
// }
// lib/core/services/external/mapbox_service.dart - ENHANCED
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class MapboxService extends GetxService {
  static const String _baseUrl = 'https://api.mapbox.com';
  static const String _accessToken =
      'YOUR_MAPBOX_ACCESS_TOKEN'; // Add your token

  // ======================================================================
  // DELIVERY TRACKING - Customer can see real-time driver location
  // ======================================================================

  /// Get optimized route for delivery with real-time updates
  Future<DeliveryRoute?> getDeliveryRoute({
    required Position driverLocation,
    required Position storeLocation,
    required Position customerLocation,
    bool includeSteps = true,
  }) async {
    try {
      // Multi-stop route: Driver → Store → Customer
      final coordinates = [
        [driverLocation.longitude, driverLocation.latitude],
        [storeLocation.longitude, storeLocation.latitude],
        [customerLocation.longitude, customerLocation.latitude],
      ];

      final url = '$_baseUrl/directions/v5/mapbox/driving/'
          '${coordinates.map((c) => '${c[0]},${c[1]}').join(';')}'
          '?access_token=$_accessToken'
          '&geometries=geojson'
          '&overview=full'
          '&steps=$includeSteps'
          '&annotations=duration,distance';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DeliveryRoute.fromMapbox(data);
      }

      return null;
    } catch (e) {
      print('Error getting delivery route: $e');
      return null;
    }
  }

  /// Get route between two points (driver to customer)
  Future<RouteInfo?> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String profile = 'driving',
  }) async {
    try {
      final url = '$_baseUrl/directions/v5/mapbox/$profile/'
          '$startLng,$startLat;$endLng,$endLat'
          '?access_token=$_accessToken'
          '&geometries=geojson'
          '&overview=full'
          '&steps=true';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes']?.isNotEmpty == true) {
          return RouteInfo.fromMapbox(data['routes'][0]);
        }
      }

      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  // ======================================================================
  // STATIC MAPS - For order cards, store previews, etc
  // ======================================================================

  /// Generate static map URL for order tracking preview
  String getDeliveryTrackingMapUrl({
    required Position driverLocation,
    required Position customerLocation,
    int width = 600,
    int height = 400,
    String style = 'streets-v11',
  }) {
    final driverMarker =
        'pin-s-car+ff0000(${driverLocation.longitude},${driverLocation.latitude})';
    final customerMarker =
        'pin-s-home+0000ff(${customerLocation.longitude},${customerLocation.latitude})';

    // Calculate center point and zoom
    final centerLat = (driverLocation.latitude + customerLocation.latitude) / 2;
    final centerLng =
        (driverLocation.longitude + customerLocation.longitude) / 2;

    return 'https://api.mapbox.com/styles/v1/mapbox/$style/static/'
        '$driverMarker,$customerMarker/'
        '$centerLng,$centerLat,12/${width}x$height'
        '?access_token=$_accessToken';
  }

  /// Static map for store location
  String getStoreMapUrl({
    required double latitude,
    required double longitude,
    int width = 400,
    int height = 300,
    String style = 'streets-v11',
  }) {
    return 'https://api.mapbox.com/styles/v1/mapbox/$style/static/'
        'pin-s-restaurant+ff6b35($longitude,$latitude)/'
        '$longitude,$latitude,15/${width}x$height'
        '?access_token=$_accessToken';
  }

  // ======================================================================
  // ETA & DISTANCE CALCULATIONS
  // ======================================================================

  /// Calculate accurate delivery ETA using Mapbox routing
  Future<Duration?> getDeliveryETA({
    required Position driverLocation,
    required Position customerLocation,
  }) async {
    final route = await getRoute(
      startLat: driverLocation.latitude,
      startLng: driverLocation.longitude,
      endLat: customerLocation.latitude,
      endLng: customerLocation.longitude,
    );

    if (route != null) {
      return Duration(seconds: route.duration.toInt());
    }

    // Fallback calculation
    final distance = calculateDistance(
      driverLocation.latitude,
      driverLocation.longitude,
      customerLocation.latitude,
      customerLocation.longitude,
    );

    return calculateEstimatedDeliveryTime(distance);
  }

  // ======================================================================
  // UTILITY METHODS
  // ======================================================================

  double calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000;
  }

  Duration calculateEstimatedDeliveryTime(double distanceInKm) {
    const averageSpeed = 25.0; // km/h
    final timeInHours = distanceInKm / averageSpeed;
    final timeInMinutes = (timeInHours * 60).round();
    final bufferTime = (distanceInKm * 2).round().clamp(5, 15);
    return Duration(minutes: timeInMinutes + bufferTime);
  }

  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1.0) {
      return '${(distanceInKm * 1000).round()} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}j ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

// ======================================================================
// DATA MODELS for Mapbox responses
// ======================================================================

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
