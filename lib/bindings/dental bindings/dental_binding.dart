import 'package:get/get.dart';
import 'package:flip_health/controllers/dental%20controllers/dental_controller.dart';

class DentalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DentalController>(() => DentalController());
  }
}
