import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/claims_repository.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';

class ClaimsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    Get.lazyPut<ClaimsRepository>(
        () => ClaimsRepository(apiService: Get.find()));
    Get.lazyPut<ClaimsController>(
        () => ClaimsController(repository: Get.find()));
  }
}
