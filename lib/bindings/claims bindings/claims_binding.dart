import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';

class ClaimsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClaimsController>(() => ClaimsController());
  }
}
