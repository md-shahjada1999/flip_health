import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/data/repositories/member_repository.dart';
import 'package:flip_health/data/repositories/consultation_repository.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';

class ConsultationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<MemberController>()) {
      Get.put(MemberController());
    }
    if (!Get.isRegistered<MemberRepository>()) {
      Get.lazyPut<MemberRepository>(
        () => MemberRepository(apiService: Get.find()),
      );
    }
    Get.lazyPut<ConsultationRepository>(
      () => ConsultationRepository(
        apiService: Get.find(),
        memberRepository: Get.find(),
      ),
    );
    Get.lazyPut<ConsultationController>(
      () => ConsultationController(repository: Get.find()),
    );
  }
}
