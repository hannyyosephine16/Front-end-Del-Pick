import 'package:get/get.dart';
import '../../../Services/location_service.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/tracking_repository.dart';

class DeliveryController extends GetxController {
  final TrackingRepository trackingRepository;
  final OrderRepository orderRepository;
  final LocationService locationService;

  DeliveryController({
    required this.trackingRepository,
    required this.orderRepository,
    required this.locationService,
  });

  final RxString _currentOrderId = ''.obs;
  String get currentOrderId => _currentOrderId.value;
}
