import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/gym_repository.dart';
import 'package:flip_health/controllers/gym%20controllers/gym_controller.dart';

class GymBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    Get.lazyPut<GymRepository>(
      () => GymRepository(apiService: Get.find()),
    );
    Get.lazyPut<GymController>(
      () => GymController(repository: Get.find()),
    );
  }
}
