// lib/core/services/external/realtime_service.dart - OPTIMIZED VERSION
import 'dart:async';
import 'package:get/get.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';

class RealTimeService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  final Map<String, Timer> _activePolling = {};
  final Map<String, DateTime> _lastSuccessfulPoll = {};
  final Map<String, int> _errorCounts = {};

  // Stream controllers untuk real-time updates
  final StreamController<Map<String, dynamic>> _orderUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _driverLocationController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get orderUpdatesStream =>
      _orderUpdatesController.stream;
  Stream<Map<String, dynamic>> get driverLocationStream =>
      _driverLocationController.stream;

  // ✅ OPTIMASI: Polling intervals berdasarkan prioritas
  static const Duration _orderPollingInterval =
      Duration(seconds: 30); // ✅ 10→30 detik
  static const Duration _driverLocationInterval =
      Duration(seconds: 45); // ✅ 15→45 detik
  static const Duration _driverRequestsInterval =
      Duration(seconds: 60); // ✅ 20→60 detik
  static const Duration _maxPollingDuration =
      Duration(minutes: 15); // ✅ Auto cleanup
  static const int _maxErrorCount =
      3; // ✅ Stop polling after 3 consecutive errors

  @override
  void onClose() {
    _stopAllPolling();
    _orderUpdatesController.close();
    _driverLocationController.close();
    super.onClose();
  }

  // ======================================================================
  // ORDER TRACKING - Optimized dengan error handling
  // ======================================================================

  void startOrderTracking(int orderId) {
    final key = 'order_$orderId';
    if (_activePolling.containsKey(key)) return;

    _resetErrorCount(key);

    _activePolling[key] = Timer.periodic(_orderPollingInterval, (timer) async {
      // ✅ Check connectivity first
      if (!_connectivity.isConnected) {
        print('No connection, skipping order polling $orderId');
        return;
      }

      try {
        final response =
            await _apiService.get('/orders/$orderId'); // ✅ Direct endpoint

        if (response.statusCode == 200) {
          _lastSuccessfulPoll[key] = DateTime.now();
          _resetErrorCount(key);

          _orderUpdatesController.add({
            'type': 'order_updated',
            'orderId': orderId,
            'data': response.data['data'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        _handlePollingError(key, 'order', orderId, e);
      }
    });

    // ✅ Auto cleanup setelah 15 menit
    _scheduleAutoCleanup(key, orderId);
    print('Started order tracking for order $orderId');
  }

  void stopOrderTracking(int orderId) {
    final key = 'order_$orderId';
    _cleanupPolling(key);
    print('Stopped order tracking for order $orderId');
  }

  // ======================================================================
  // DRIVER LOCATION - Optimized untuk battery life
  // ======================================================================

  void startDriverLocationTracking(int driverId) {
    final key = 'driver_location_$driverId';
    if (_activePolling.containsKey(key)) return;

    _resetErrorCount(key);

    _activePolling[key] =
        Timer.periodic(_driverLocationInterval, (timer) async {
      if (!_connectivity.isConnected) return;

      try {
        final response = await _apiService
            .get('/drivers/$driverId/location'); // ✅ Direct endpoint

        if (response.statusCode == 200) {
          _lastSuccessfulPoll[key] = DateTime.now();
          _resetErrorCount(key);

          _driverLocationController.add({
            'type': 'driver_location_updated',
            'driverId': driverId,
            'data': response.data['data'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        _handlePollingError(key, 'driver_location', driverId, e);
      }
    });

    _scheduleAutoCleanup(key, driverId);
  }

  void stopDriverLocationTracking(int driverId) {
    final key = 'driver_location_$driverId';
    _cleanupPolling(key);
  }

  // ======================================================================
  // DRIVER REQUESTS - Untuk driver app
  // ======================================================================

  void startDriverRequestsPolling() {
    const key = 'driver_requests';
    if (_activePolling.containsKey(key)) return;

    _resetErrorCount(key);

    _activePolling[key] =
        Timer.periodic(_driverRequestsInterval, (timer) async {
      if (!_connectivity.isConnected) return;

      try {
        final response =
            await _apiService.get('/driver-requests'); // ✅ Direct endpoint

        if (response.statusCode == 200) {
          _lastSuccessfulPoll[key] = DateTime.now();
          _resetErrorCount(key);

          _orderUpdatesController.add({
            'type': 'driver_requests_updated',
            'data': response.data['data'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        _handlePollingError(key, 'driver_requests', null, e);
      }
    });
  }

  void stopDriverRequestsPolling() {
    const key = 'driver_requests';
    _cleanupPolling(key);
  }

  // ======================================================================
  // SMART POLLING - Adaptive based on connection and errors
  // ======================================================================

  void _handlePollingError(String key, String type, int? id, dynamic error) {
    _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;

    print(
        'Error polling $type ${id ?? ''}: $error (${_errorCounts[key]}/$_maxErrorCount)');

    // ✅ Stop polling after too many errors
    if (_errorCounts[key]! >= _maxErrorCount) {
      print('Too many errors for $type ${id ?? ''}, stopping polling');
      _cleanupPolling(key);
    }
  }

  void _resetErrorCount(String key) {
    _errorCounts[key] = 0;
  }

  void _scheduleAutoCleanup(String key, int? id) {
    Timer(_maxPollingDuration, () {
      if (_activePolling.containsKey(key)) {
        print(
            'Auto cleanup for $key after ${_maxPollingDuration.inMinutes} minutes');
        _cleanupPolling(key);
      }
    });
  }

  void _cleanupPolling(String key) {
    _activePolling[key]?.cancel();
    _activePolling.remove(key);
    _lastSuccessfulPoll.remove(key);
    _errorCounts.remove(key);
  }

  // ======================================================================
  // UTILITY METHODS - Enhanced
  // ======================================================================

  void _stopAllPolling() {
    for (final key in _activePolling.keys.toList()) {
      _cleanupPolling(key);
    }
  }

  bool isPolling(String type, [int? id]) {
    final key = id != null ? '${type}_$id' : type;
    return _activePolling.containsKey(key);
  }

  int get activePollingCount => _activePolling.length;

  // ✅ Get polling health status
  Map<String, dynamic> getPollingStatus() {
    final now = DateTime.now();
    return {
      'activePolling': activePollingCount,
      'totalPolling': _activePolling.keys.toList(),
      'lastSuccessful': _lastSuccessfulPoll
          .map((key, time) => MapEntry(key, now.difference(time).inSeconds)),
      'errorCounts': _errorCounts,
      'isConnected': _connectivity.isConnected,
    };
  }

  // Manual refresh with timeout
  Future<Map<String, dynamic>?> refreshOrderStatus(int orderId) async {
    try {
      final response = await _apiService
          .get('/orders/$orderId')
          .timeout(const Duration(seconds: 10)); // ✅ Add timeout

      if (response.statusCode == 200) {
        return response.data['data'];
      }
    } catch (e) {
      print('Error refreshing order $orderId: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> refreshDriverLocation(int driverId) async {
    try {
      final response = await _apiService
          .get('/drivers/$driverId/location')
          .timeout(const Duration(seconds: 10)); // ✅ Add timeout

      if (response.statusCode == 200) {
        return response.data['data'];
      }
    } catch (e) {
      print('Error refreshing driver location $driverId: $e');
    }
    return null;
  }

  // Reduce polling when app in background
  void pauseAllPolling() {
    print('Pausing all polling (app in background)');
    for (final timer in _activePolling.values) {
      timer.cancel();
    }
  }

  void resumeAllPolling() {
    print('Resuming all polling (app in foreground)');
    // Restart polling for active keys
    final activeKeys = _activePolling.keys.toList();
    _activePolling.clear();

    for (final key in activeKeys) {
      if (key.startsWith('order_')) {
        final orderId = int.parse(key.split('_')[1]);
        startOrderTracking(orderId);
      } else if (key.startsWith('driver_location_')) {
        final driverId = int.parse(key.split('_')[2]);
        startDriverLocationTracking(driverId);
      } else if (key == 'driver_requests') {
        startDriverRequestsPolling();
      }
    }
  }
}
