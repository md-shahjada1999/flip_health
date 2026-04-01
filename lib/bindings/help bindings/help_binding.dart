import 'package:get/get.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/help_repository.dart';

class HelpBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<HelpRepository>(
        () => HelpRepository(apiService: Get.find()));
    Get.lazyPut<HelpController>(
        () => HelpController(repository: Get.find()));
  }
}
