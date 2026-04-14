import 'package:flip_health/controllers/gym_membership_order_detail_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/gym_repository.dart';
import 'package:get/get.dart';

class GymMembershipOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<GymRepository>()) {
      Get.lazyPut<GymRepository>(() => GymRepository(apiService: Get.find()));
    }
    Get.lazyPut<GymMembershipOrderDetailController>(
      () => GymMembershipOrderDetailController(repository: Get.find()),
    );
  }
}
