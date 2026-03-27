import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';

class HealthCheckupsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthCheckupsController>(
      () => HealthCheckupsController(),
    );
  }
}