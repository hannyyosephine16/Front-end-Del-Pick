import 'package:get/get.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<UserModel?> _user = Rx<UserModel?>(null);

  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  UserModel? get user => _user.value;

  @override
  void onInit() {
    super.onInit();
    // Use current user from AuthController initially
    _user.value = _authController.currentUser.value;
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;
      _errorMessage.value = '';

      final result = await _authRepository.getProfile();

      if (result.isSuccess && result.data != null) {
        _user.value = result.data;
        // Update AuthController's current user
        // _authController.updateCurrentUser(result.data!);
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to load profile';
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'An error occurred while loading profile: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  ///Update Profile
//   Future<bool> updateProfile({
//     String? name,
//     String? email,
//     String? phone,
//     String? avatar,
//   })
//   async {
//     try {
//       _isLoading.value = true;
//
//       final result = await _authRepository.updateProfile(
//         name: name,
//         email: email,
//         phone: phone,
//         avatar: avatar,
//       );
//
//       if (result.isSuccess && result.data != null) {
//         _user.value = result.data;
//         // Update AuthController's current user
//         // _authController.updateCurrentUser(result.data!);
//
//         Get.snackbar(
//           'Success',
//           'Profile updated successfully',
//           snackPosition: SnackPosition.TOP,
//         );
//         return true;
//       } else {
//         Get.snackbar(
//           'Error',
//           result.message ?? 'Failed to update profile',
//           snackPosition: SnackPosition.TOP,
//         );
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred while updating profile: $e',
//         snackPosition: SnackPosition.TOP,
//       );
//       return false;
//     } finally {
//       _isLoading.value = false;
//     }
//   }

  void refresh() {
    loadProfile();
  }
}
