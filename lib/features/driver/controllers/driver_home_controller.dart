// lib/features/driver/controllers/driver_home_controller.dart
import 'package:get/get.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';

class DriverHomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final RxBool _isLoading = false.obs;
  final RxString _driverStatus = 'inactive'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get driverStatus => _driverStatus.value;
  String get driverName => _authController.userName;

  @override
  void onInit() {
    super.onInit();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    try {
      _isLoading.value = true;
      // TODO: Load driver specific data
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    } catch (e) {
      Get.snackbar('Error', 'Failed to load driver data');
    } finally {
      _isLoading.value = false;
    }
  }

  void toggleDriverStatus() {
    if (_driverStatus.value == 'active') {
      _driverStatus.value = 'inactive';
    } else {
      _driverStatus.value = 'active';
    }

    Get.snackbar(
      'Status Updated',
      'Driver status: ${_driverStatus.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    _authController.logout();
  }
}
