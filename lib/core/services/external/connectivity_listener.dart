// lib/core/services/connectivity_listener.dart
import 'package:get/get.dart';
import 'package:del_pick/core/services/external/connectivity_service.dart';
import 'package:del_pick/core/middleware/connectivity_middleware.dart';

/// Service untuk mendengarkan perubahan koneksi internet
class ConnectivityListener extends GetxService {
  late final ConnectivityService _connectivityService;
  bool _previousConnectionState = true;

  @override
  void onInit() {
    super.onInit();
    _initializeListener();
  }

  void _initializeListener() {
    try {
      _connectivityService = Get.find<ConnectivityService>();
      _previousConnectionState = _connectivityService.isConnected;

      // Listen to connection changes using ever() for reactive programming
      ever(_connectivityService._isConnected, _onConnectionChanged);
    } catch (e) {
      print('Error initializing connectivity listener: $e');
    }
  }

  void _onConnectionChanged(bool isConnected) {
    // Only show messages when connection state actually changes
    if (_previousConnectionState != isConnected) {
      if (isConnected) {
        DioConnectivityMiddleware.showOnlineMessage();
      } else {
        DioConnectivityMiddleware.showOfflineMessage();
      }

      _previousConnectionState = isConnected;
    }
  }

  /// Force check connection status
  Future<bool> checkConnection() async {
    await _connectivityService.forceCheckConnectivity();
    return _connectivityService.isConnected;
  }

  /// Get current connection status
  bool get isConnected => _connectivityService.isConnected;

  /// Get connection type
  String get connectionType => _connectivityService.primaryConnectionTypeString;
}

/// Extension untuk ConnectivityService agar bisa diakses RxBool
extension ConnectivityServiceExtension on ConnectivityService {
  RxBool get isConnectedRx => _isConnected;
}
