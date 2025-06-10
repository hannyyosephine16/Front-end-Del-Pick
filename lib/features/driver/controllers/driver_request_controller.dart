import 'package:get/get.dart';

import '../../../data/repositories/driver_repository.dart';
import '../../../data/repositories/order_repository.dart';

class DriverRequestController extends GetxController {
  final DriverRepository driverRepository;
  final OrderRepository orderRepository;

  DriverRequestController({
    required this.driverRepository,
    required this.orderRepository,
  });

  final RxList _requests = [].obs;
  List get requests => _requests;

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  void loadRequests() {
    // Load driver requests
  }
}
