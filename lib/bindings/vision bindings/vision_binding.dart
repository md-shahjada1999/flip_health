import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/vision_repository.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';

class VisionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    Get.lazyPut<VisionRepository>(
      () => VisionRepository(apiService: Get.find()),
    );
    Get.lazyPut<VisionController>(
      () => VisionController(repository: Get.find()),
    );
  }
}
