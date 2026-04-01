import 'package:get/get.dart';
import 'package:flip_health/controllers/health_score%20controllers/health_score_controller.dart';

class HealthScoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthScoreController>(() => HealthScoreController());
  }
}
