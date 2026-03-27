import 'package:get/get.dart';
import 'package:flip_health/controllers/dashboard%20controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization of controllers
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
