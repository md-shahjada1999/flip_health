import 'package:flip_health/controllers/consultation_order_detail_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/consultation_order_repository.dart';
import 'package:get/get.dart';

class ConsultationOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<ConsultationOrderRepository>(
      () => ConsultationOrderRepository(apiService: Get.find()),
    );
    Get.lazyPut<ConsultationOrderDetailController>(
      () => ConsultationOrderDetailController(repository: Get.find()),
    );
  }
}
