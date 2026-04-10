import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/address_repository.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';

class AddressBookBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
          () => AddressRepository(apiService: Get.find()));
    }
    Get.lazyPut<AddressController>(
        () => AddressController(repository: Get.find()));
  }
}
