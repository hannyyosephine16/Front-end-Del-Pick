import 'package:get/get.dart';
import '../../../data/repositories/driver_repository.dart';

// Driver Profile Controller
class DriverProfileController extends GetxController {
  final DriverRepository driverRepository;

  DriverProfileController(this.driverRepository);

  final RxMap _profile = {}.obs;
  Map get profile => _profile;
}
