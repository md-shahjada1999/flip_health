import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/data/repositories/health_checkup_repository.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';

class HealthCheckupsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
          () => AddressRepository(apiService: Get.find()));
    }
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController(repository: Get.find()));
    }
    Get.lazyPut<HealthCheckupRepository>(
      () => HealthCheckupRepository(apiService: Get.find()),
    );
    Get.lazyPut<HealthCheckupsController>(
      () => HealthCheckupsController(repository: Get.find()),
    );
  }
}
