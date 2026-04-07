import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/data/repositories/upload_repository.dart';
import 'package:flip_health/data/repositories/vision_repository.dart';

class VisionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
        () => AddressRepository(apiService: Get.find()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AddressController>()) {
      Get.lazyPut<AddressController>(
        () => AddressController(repository: Get.find()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    if (!Get.isRegistered<UploadRepository>()) {
      Get.lazyPut<UploadRepository>(
        () => UploadRepository(apiService: Get.find()),
        fenix: true,
      );
    }
    Get.lazyPut<VisionRepository>(
      () => VisionRepository(apiService: Get.find()),
    );
    Get.lazyPut<VisionController>(
      () => VisionController(
        repository: Get.find(),
        uploadRepository: Get.find(),
      ),
    );
  }
}
