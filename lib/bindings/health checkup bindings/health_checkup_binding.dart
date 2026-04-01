import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/health_checkup_repository.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';

class HealthCheckupsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    Get.lazyPut<HealthCheckupRepository>(
      () => HealthCheckupRepository(apiService: Get.find()),
    );
    Get.lazyPut<HealthCheckupsController>(
      () => HealthCheckupsController(repository: Get.find()),
    );
  }
}
