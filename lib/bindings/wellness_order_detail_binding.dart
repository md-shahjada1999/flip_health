import 'package:flip_health/controllers/wellness_order_detail_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/wellness_order_repository.dart';
import 'package:get/get.dart';

class WellnessOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<WellnessOrderRepository>(
      () => WellnessOrderRepository(apiService: Get.find()),
    );
    Get.lazyPut<WellnessOrderDetailController>(
      () => WellnessOrderDetailController(repository: Get.find()),
    );
  }
}
