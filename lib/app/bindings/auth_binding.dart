import 'package:get/get.dart';
import 'package:del_pick/data/repositories/auth_repository.dart';
import 'package:del_pick/data/providers/auth_provider.dart';
import 'package:del_pick/data/datasources/remote/auth_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';
import 'package:del_pick/features/auth/controllers/login_controller.dart';
import 'package:del_pick/features/auth/controllers/register_controller.dart';
import 'package:del_pick/features/auth/controllers/forget_password_controller.dart';
import 'package:del_pick/features/auth/controllers/profile_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSource(Get.find()));
    Get.lazyPut<AuthLocalDataSource>(() => AuthLocalDataSource(Get.find()));

    // Provider
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
    );

    // Repository
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));

    // Controllers - Fix the constructor parameter name
    Get.lazyPut<AuthController>(
        () => AuthController(Get.find<AuthRepository>()));
    Get.lazyPut<LoginController>(
        () => LoginController(Get.find<AuthRepository>()));
    Get.lazyPut<RegisterController>(
        () => RegisterController(Get.find<AuthRepository>()));
    Get.lazyPut<ForgetPasswordController>(
      () => ForgetPasswordController(Get.find<AuthRepository>()),
    );
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
