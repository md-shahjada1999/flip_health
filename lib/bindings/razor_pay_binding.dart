import 'package:flip_health/controllers/razor_pay_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/consultation_order_repository.dart';
import 'package:get/get.dart';

class RazorPayBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<ConsultationOrderRepository>()) {
      Get.lazyPut<ConsultationOrderRepository>(
        () => ConsultationOrderRepository(apiService: Get.find()),
      );
    }
    // Must be eager [put]: [lazyPut] only runs on [Get.find], and [RazorPayScreen]
    // does not find the controller — checkout would never open.
    if (Get.isRegistered<RazorPayController>()) {
      Get.delete<RazorPayController>(force: true);
    }
    Get.put<RazorPayController>(RazorPayController(), permanent: false);
  }
}
