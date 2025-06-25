// 2. lib/features/shared/screens/splash_screen.dart (NEW FILE - untuk mengatasi error SplashScreen)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import 'package:del_pick/features/shared/splash_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(SplashController());

    return const SplashView();
  }
}
