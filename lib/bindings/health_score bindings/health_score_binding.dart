import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/health_score_repository.dart';
import 'package:flip_health/controllers/health_score%20controllers/health_score_controller.dart';

class HealthScoreBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    Get.lazyPut<HealthScoreRepository>(
        () => HealthScoreRepository(apiService: Get.find()));
    Get.lazyPut<HealthScoreController>(
        () => HealthScoreController(repository: Get.find()));
  }
}
