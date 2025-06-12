// lib/core/services/external/realtime_service.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class RealTimeService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  final Map<String, Timer> _activePolling = {};
  final Map<String, StreamController> _controllers = {};

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

  @override
  void onClose() {
    _stopAllPolling();
    _orderUpdatesController.close();
    _driverLocationController.close();
    super.onClose();
  }

  // ======================================================================
  // ORDER TRACKING - Poll order status setiap 10 detik
  // ======================================================================

  void startOrderTracking(int orderId) {
    final key = 'order_$orderId';

    if (_activePolling.containsKey(key)) return; // Already polling

    _activePolling[key] = Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        try {
          final response =
              await _apiService.get(ApiEndpoints.getOrderById(orderId));

          if (response.statusCode == 200) {
            _orderUpdatesController.add({
              'type': 'order_updated',
              'orderId': orderId,
              'data': response.data['data'],
            });
          }
        } catch (e) {
          print('Error polling order $orderId: $e');
        }
      },
    );

    print('Started order tracking for order $orderId');
  }

  void stopOrderTracking(int orderId) {
    final key = 'order_$orderId';
    _activePolling[key]?.cancel();
    _activePolling.remove(key);
    print('Stopped order tracking for order $orderId');
  }

  // ======================================================================
  // DRIVER LOCATION - Poll driver location setiap 15 detik
  // ======================================================================

  void startDriverLocationTracking(int driverId) {
    final key = 'driver_location_$driverId';

    if (_activePolling.containsKey(key)) return;

    _activePolling[key] = Timer.periodic(
      const Duration(seconds: 15),
      (timer) async {
        try {
          final response =
              await _apiService.get(ApiEndpoints.getDriverLocation(driverId));

          if (response.statusCode == 200) {
            _driverLocationController.add({
              'type': 'driver_location_updated',
              'driverId': driverId,
              'data': response.data['data'],
            });
          }
        } catch (e) {
          print('Error polling driver location $driverId: $e');
        }
      },
    );
  }

  void stopDriverLocationTracking(int driverId) {
    final key = 'driver_location_$driverId';
    _activePolling[key]?.cancel();
    _activePolling.remove(key);
  }

  // ======================================================================
  // DRIVER REQUESTS - Poll driver requests setiap 20 detik
  // ======================================================================

  void startDriverRequestsPolling() {
    const key = 'driver_requests';

    if (_activePolling.containsKey(key)) return;

    _activePolling[key] = Timer.periodic(
      const Duration(seconds: 20),
      (timer) async {
        try {
          final response =
              await _apiService.get(ApiEndpoints.getDriverRequests);

          if (response.statusCode == 200) {
            _orderUpdatesController.add({
              'type': 'driver_requests_updated',
              'data': response.data['data'],
            });
          }
        } catch (e) {
          print('Error polling driver requests: $e');
        }
      },
    );
  }

  void stopDriverRequestsPolling() {
    const key = 'driver_requests';
    _activePolling[key]?.cancel();
    _activePolling.remove(key);
  }

  // ======================================================================
  // UTILITY METHODS
  // ======================================================================

  void _stopAllPolling() {
    for (final timer in _activePolling.values) {
      timer.cancel();
    }
    _activePolling.clear();
  }

  // Check active polling status
  bool isPolling(String type, [int? id]) {
    final key = id != null ? '${type}_$id' : type;
    return _activePolling.containsKey(key);
  }

  // Get active polling count
  int get activePollingCount => _activePolling.length;

  // Manual refresh for pull-to-refresh scenarios
  Future<Map<String, dynamic>?> refreshOrderStatus(int orderId) async {
    try {
      final response =
          await _apiService.get(ApiEndpoints.getOrderById(orderId));
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
      final response =
          await _apiService.get(ApiEndpoints.getDriverLocation(driverId));
      if (response.statusCode == 200) {
        return response.data['data'];
      }
    } catch (e) {
      print('Error refreshing driver location $driverId: $e');
    }
    return null;
  }
}
