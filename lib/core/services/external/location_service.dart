// lib/core/services/external/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' as getx;
import 'package:del_pick/app/config/app_config.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';

class LocationService extends getx.GetxService {
  final StorageService _storageService = getx.Get.find<StorageService>();

  final getx.Rx<Position?> _currentPosition = getx.Rx<Position?>(null);
  final getx.RxString _currentAddress = getx.RxString('Institut Teknologi Del');
  final getx.RxBool _isLocationEnabled = getx.RxBool(true);

  StreamSubscription<Position>? _positionStreamSubscription;

  Position? get currentPosition => _currentPosition.value;
  String get currentAddress => _currentAddress.value;
  bool get isLocationEnabled => _isLocationEnabled.value;

  // Default location coordinates for Institut Teknologi Del
  double get defaultLatitude => AppConfig.defaultLatitude;
  double get defaultLongitude => AppConfig.defaultLongitude;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeLocation();
  }

  @override
  void onClose() {
    stopLocationUpdates();
    super.onClose();
  }

  Future<void> _initializeLocation() async {
    // Set default location and address first
    _setDefaultLocation();

    // Load last known location if available
    await _loadLastKnownLocation();

    // Try to get current location (optional)
    try {
      await getCurrentLocation();
    } catch (e) {
      // If failed to get location, keep using default
      print(
          'Failed to get current location, using default IT Del location: $e');
    }
  }

  void _setDefaultLocation() {
    _currentPosition.value = defaultLocation;
    _currentAddress.value = getDefaultAddress();
    _isLocationEnabled.value = true;
  }

  Future<void> _loadLastKnownLocation() async {
    final lat = _storageService.readDouble(StorageConstants.lastKnownLatitude);
    final lng = _storageService.readDouble(StorageConstants.lastKnownLongitude);

    if (lat != null && lng != null) {
      _currentPosition.value = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    } else {
      // If no saved location, use default IT Del location
      _setDefaultLocation();
    }
  }

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Return true but use default location
      _setDefaultLocation();
      return true;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Use default location if permission denied
        _setDefaultLocation();
        return true;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Use default location if permission denied forever
      _setDefaultLocation();
      return true;
    }

    await _storageService.writeBool(
      StorageConstants.locationPermissionGranted,
      true,
    );
    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return defaultLocation;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition.value = position;
      await _saveLastKnownLocation(position);

      // Update address if needed (you can implement reverse geocoding here)
      // For now, keep Institut Teknologi Del as default

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      // Return default location if error
      _setDefaultLocation();
      return defaultLocation;
    }
  }

  Future<void> startLocationUpdates() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      _setDefaultLocation();
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    try {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _currentPosition.value = position;
        _saveLastKnownLocation(position);
      });
    } catch (e) {
      print('Error starting location updates: $e');
      _setDefaultLocation();
    }
  }

  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<void> _saveLastKnownLocation(Position position) async {
    await _storageService.writeDouble(
      StorageConstants.lastKnownLatitude,
      position.latitude,
    );
    await _storageService.writeDouble(
      StorageConstants.lastKnownLongitude,
      position.longitude,
    );
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  bool isWithinDeliveryRadius(
    double storeLatitude,
    double storeLongitude,
    double customerLatitude,
    double customerLongitude,
  ) {
    final distance = calculateDistance(
      storeLatitude,
      storeLongitude,
      customerLatitude,
      customerLongitude,
    );
    return distance <= AppConfig.maxDeliveryRadius;
  }

  Position get defaultLocation => Position(
        latitude: AppConfig.defaultLatitude,
        longitude: AppConfig.defaultLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        speed: 0,
        headingAccuracy: 0,
        speedAccuracy: 0,
      );

  // NEW: Get default address for Institut Teknologi Del
  String getDefaultAddress() {
    return 'Institut Teknologi Del, Jl. Sisingamangaraja, Sitoluama, Laguboti, Toba, Sumatera Utara 22381';
  }

  // NEW: Force use default location (useful for customer app)
  void useDefaultLocation() {
    _setDefaultLocation();
  }

  // NEW: Get current location with fallback to default
  Future<Position> getCurrentLocationWithFallback() async {
    try {
      final position = await getCurrentLocation();
      return position ?? defaultLocation;
    } catch (e) {
      return defaultLocation;
    }
  }

  // NEW: Get distance from current location to target
  double getDistanceFromCurrent(double targetLat, double targetLng) {
    final current = _currentPosition.value ?? defaultLocation;
    return calculateDistance(
      current.latitude,
      current.longitude,
      targetLat,
      targetLng,
    );
  }

  // NEW: Update current address
  void updateCurrentAddress(String address) {
    _currentAddress.value = address;
  }

  // NEW: Reset to default location
  void resetToDefault() {
    _setDefaultLocation();
  }
}
