import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/vaccine_repository.dart';
import 'package:flip_health/controllers/vaccine%20controllers/vaccine_controller.dart';

class VaccineBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    Get.lazyPut<VaccineRepository>(
      () => VaccineRepository(apiService: Get.find()),
    );
    Get.lazyPut<VaccineController>(
      () => VaccineController(repository: Get.find()),
    );
  }
}
