import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/pharmacy%20controllers/pharmacy_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/data/repositories/member_repository.dart';
import 'package:flip_health/data/repositories/pharmacy_repository.dart';
import 'package:flip_health/data/repositories/upload_repository.dart';

class PharmacyBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<MemberRepository>()) {
      Get.lazyPut<MemberRepository>(
          () => MemberRepository(apiService: Get.find()),
          fenix: true);
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
          () => AddressRepository(apiService: Get.find()),
          fenix: true);
    }
    if (!Get.isRegistered<AddressController>()) {
      Get.lazyPut<AddressController>(
          () => AddressController(repository: Get.find()),
          fenix: true);
    }
    if (!Get.isRegistered<UploadRepository>()) {
      Get.lazyPut<UploadRepository>(
          () => UploadRepository(apiService: Get.find()),
          fenix: true);
    }
    Get.lazyPut<PharmacyRepository>(
        () => PharmacyRepository(apiService: Get.find()));
    Get.lazyPut<PharmacyController>(
      () => PharmacyController(
        repository: Get.find(),
        memberRepository: Get.find(),
        uploadRepository: Get.find(),
      ),
    );
  }
}
