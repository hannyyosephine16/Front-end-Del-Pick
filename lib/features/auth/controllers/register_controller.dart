import 'package:get/get.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/core/constants/app_constants.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository;

  RegisterController(this._authRepository);

  final RxBool _isLoading = false.obs;
  final RxString _selectedRole = AppConstants.roleCustomer.obs;

  bool get isLoading => _isLoading.value;
  String get selectedRole => _selectedRole.value;

  void setRole(String role) {
    _selectedRole.value = role;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      final result = await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: _selectedRole.value,
      );

      if (result.isSuccess) {
        Get.snackbar('Success', 'Registration successful');
        Get.offAllNamed('/login');
        return true;
      } else {
        Get.snackbar('Error', result.message ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during registration');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
