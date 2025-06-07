import 'package:get/get.dart';
import '../../../data/repositories/order_repository.dart';

// Driver Orders Controller
class DriverOrdersController extends GetxController {
  final OrderRepository orderRepository;

  DriverOrdersController(this.orderRepository);

  final RxList _orders = [].obs;
  List get orders => _orders;
}
