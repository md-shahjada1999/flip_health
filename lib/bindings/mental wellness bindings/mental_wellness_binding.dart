import 'package:get/get.dart';
import 'package:flip_health/controllers/mental%20wellness%20controllers/mental_wellness_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/member_repository.dart';
import 'package:flip_health/data/repositories/mental_wellness_repository.dart';

class MentalWellnessBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<MemberRepository>()) {
      Get.lazyPut<MemberRepository>(
          () => MemberRepository(apiService: Get.find()), fenix: true);
    }
    Get.lazyPut<MentalWellnessRepository>(
        () => MentalWellnessRepository(apiService: Get.find()));
    Get.lazyPut<MentalWellnessController>(
      () => MentalWellnessController(
        repository: Get.find(),
        memberRepository: Get.find(),
      ),
    );
  }
}
