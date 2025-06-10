import 'package:get/get.dart';
import '../../../core/services/external/location_service.dart';
import '../../../data/repositories/driver_repository.dart';

// Driver Location Controller
class DriverLocationController extends GetxController {
  final DriverRepository driverRepository;
  final LocationService locationService;

  DriverLocationController({
    required this.driverRepository,
    required this.locationService,
  });

  void updateLocation() {
    // Update driver location
  }
}
