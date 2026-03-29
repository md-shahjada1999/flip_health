import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';

class LabTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LabTestController>(() => LabTestController());
  }
}
