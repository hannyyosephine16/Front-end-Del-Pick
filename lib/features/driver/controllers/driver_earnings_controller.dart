import 'package:get/get.dart';

import '../../../data/repositories/driver_repository.dart';

// Driver Earnings Controller
class DriverEarningsController extends GetxController {
  final DriverRepository driverRepository;

  DriverEarningsController(this.driverRepository);

  final RxDouble _totalEarnings = 0.0.obs;
  double get totalEarnings => _totalEarnings.value;
}
