// lib/core/utils/location_helper.dart - FIXED VERSION (clean ending)
import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/core/errors/exceptions.dart' as app_exceptions;

class LocationHelper {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const double _earthRadiusKm = 6371.0;

  /// Get current user location
  static Future<Position> getCurrentLocation({
    Duration timeout = _defaultTimeout,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const app_exceptions.LocationServiceDisabledException();
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const app_exceptions.LocationPermissionDeniedException();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const app_exceptions.LocationPermissionDeniedException();
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout,
      );

      return position;
    } on TimeoutException {
      throw const app_exceptions.LocationTimeoutException();
    } catch (e) {
      if (e is app_exceptions.LocationException) rethrow;
      throw app_exceptions.LocationException(
          'Failed to get current location: ${e.toString()}');
    }
  }

  /// Get last known location (faster but potentially less accurate)
  static Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two points using Haversine formula
  /// (Same as backend implementation for consistency)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Convert degrees to radians
    final double lat1Rad = lat1 * (math.pi / 180);
    final double lat2Rad = lat2 * (math.pi / 180);
    final double deltaLatRad = (lat2 - lat1) * (math.pi / 180);
    final double deltaLonRad = (lon2 - lon1) * (math.pi / 180);

    // Haversine formula
    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = _earthRadiusKm * c;

    return distance;
  }

  /// Check if location is within delivery radius
  static bool isWithinDeliveryRadius(
    Position userLocation,
    double storeLat,
    double storeLon, {
    double? customRadius,
  }) {
    final distance = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      storeLat,
      storeLon,
    );
    final radiusKm = customRadius ?? AppConstants.maxDeliveryRadius;
    return distance <= radiusKm;
  }

  /// Get formatted distance string
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    } else if (distanceKm < 10.0) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.round()} km';
    }
  }

  /// Calculate estimated travel time (basic estimation)
  static Duration calculateEstimatedTravelTime(
    double distanceKm, {
    double averageSpeedKmh = 30.0, // Default speed for city driving
  }) {
    final timeHours = distanceKm / averageSpeedKmh;
    final timeMinutes = (timeHours * 60).round();
    return Duration(minutes: timeMinutes);
  }

  /// Get address from coordinates (reverse geocoding)
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return _formatPlacemark(placemark);
      }

      return 'Unknown location';
    } catch (e) {
      throw app_exceptions.LocationException(
          'Failed to get address: ${e.toString()}');
    }
  }

  /// Get coordinates from address (geocoding)
  static Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      return null;
    } catch (e) {
      throw app_exceptions.LocationException(
          'Failed to get coordinates: ${e.toString()}');
    }
  }

  /// Stream location updates for real-time tracking
  static Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // Minimum distance in meters before update
    Duration interval = const Duration(seconds: 15),
  }) {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: _defaultTimeout,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Check location permissions status
  static Future<LocationPermissionStatus> checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.granted;
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.deniedForever;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.unknown;
      }
    } catch (e) {
      return LocationPermissionStatus.unknown;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      // Check if service is enabled first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Request user to enable location service
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Request permission
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      return false;
    }
  }

  /// Get default location (IT Del coordinates)
  static Position getDefaultLocation() {
    return Position(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  /// Find nearest stores from user location
  static List<T> findNearestLocations<T>(
    Position userLocation,
    List<T> locations,
    double Function(T) getLatitude,
    double Function(T) getLongitude, {
    double? maxRadius,
    int? limit,
  }) {
    final locationsWithDistance = locations.map((location) {
      final distance = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        getLatitude(location),
        getLongitude(location),
      );
      return MapEntry(location, distance);
    }).toList();

    // Filter by radius if specified
    if (maxRadius != null) {
      locationsWithDistance.removeWhere((entry) => entry.value > maxRadius);
    }

    // Sort by distance
    locationsWithDistance.sort((a, b) => a.value.compareTo(b.value));

    // Limit results if specified
    final limitedLocations = limit != null
        ? locationsWithDistance.take(limit)
        : locationsWithDistance;

    return limitedLocations.map((entry) => entry.key).toList();
  }

  /// Format placemark to readable address
  static String _formatPlacemark(Placemark placemark) {
    final List<String> addressParts = [];

    if (placemark.street?.isNotEmpty == true) {
      addressParts.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true) {
      addressParts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      addressParts.add(placemark.country!);
    }

    return addressParts.join(', ');
  }

  /// Calculate bearing between two points (for navigation)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double lat1Rad = lat1 * (math.pi / 180);
    final double lat2Rad = lat2 * (math.pi / 180);
    final double deltaLonRad = (lon2 - lon1) * (math.pi / 180);

    final double y = math.sin(deltaLonRad) * math.cos(lat2Rad);
    final double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLonRad);

    final double bearingRad = math.atan2(y, x);
    final double bearingDeg = bearingRad * (180 / math.pi);

    return (bearingDeg + 360) % 360; // Normalize to 0-360 degrees
  }
}

/// Location permission status enum
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  unknown,
}

/// Location data model for easy handling
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    this.address,
  });

  factory LocationData.fromPosition(Position position, {String? address}) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp ?? DateTime.now(),
      address: address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      address: json['address'],
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}
