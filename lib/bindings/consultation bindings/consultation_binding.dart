import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';

class ConsultationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsultationController>(() => ConsultationController());
  }
}
