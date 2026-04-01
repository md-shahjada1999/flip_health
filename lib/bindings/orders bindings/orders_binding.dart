import 'package:get/get.dart';
import 'package:flip_health/controllers/orders%20controllers/orders_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/orders_repository.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<OrdersRepository>(
        () => OrdersRepository(apiService: Get.find()));
    Get.lazyPut<OrdersController>(
        () => OrdersController(repository: Get.find()));
  }
}
