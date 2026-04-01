import 'package:get/get.dart';
import 'package:flip_health/controllers/profile%20controllers/profile_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/profile_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<ProfileRepository>(
        () => ProfileRepository(apiService: Get.find()));
    Get.lazyPut<ProfileController>(
        () => ProfileController(repository: Get.find()));
  }
}
