import 'package:get/get.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';

class VisionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisionController>(() => VisionController());
  }
}
