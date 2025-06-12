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
}
