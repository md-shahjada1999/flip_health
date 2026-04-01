import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/dental_repository.dart';
import 'package:flip_health/controllers/dental%20controllers/dental_controller.dart';

class DentalBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    Get.lazyPut<DentalRepository>(
      () => DentalRepository(apiService: Get.find()),
    );
    Get.lazyPut<DentalController>(
      () => DentalController(repository: Get.find()),
    );
  }
}
