import 'package:flip_health/controllers/lab_order_detail_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';
import 'package:get/get.dart';

class LabOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<PharmacyRepository>(
      () => PharmacyRepository(apiService: Get.find()),
    );
    Get.lazyPut<LabOrderDetailController>(
      () => LabOrderDetailController(repository: Get.find()),
    );
  }
}
