import 'package:flip_health/controllers/pharmacy_order_detail_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';
import 'package:get/get.dart';

class PharmacyOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<PharmacyRepository>(
      () => PharmacyRepository(apiService: Get.find()),
    );
    Get.lazyPut<PharmacyOrderDetailController>(
      () => PharmacyOrderDetailController(repository: Get.find()),
    );
  }
}
