import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/add_address_controller.dart';

class AddAddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddAddressController>(() => AddAddressController());
  }
}
