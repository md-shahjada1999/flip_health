import 'package:get/get.dart';
import 'package:flip_health/controllers/pharmacy%20controllers/pharmacy_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';

class PharmacyBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<PharmacyRepository>(
        () => PharmacyRepository(apiService: Get.find()));
    Get.lazyPut<PharmacyController>(
        () => PharmacyController(repository: Get.find()));
  }
}
