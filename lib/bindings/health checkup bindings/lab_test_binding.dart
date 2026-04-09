import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/data/repositories/lab_test_repository.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';

class LabTestBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
        () => AddressRepository(apiService: Get.find()),
      );
    }
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController(repository: Get.find()));
    }
    Get.lazyPut<LabTestRepository>(
      () => LabTestRepository(apiService: Get.find()),
    );
    Get.lazyPut<LabTestController>(
      () => LabTestController(repository: Get.find()),
    );
  }
}
