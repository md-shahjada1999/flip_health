import 'package:get/get.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/family_member_repository.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/add_family_member_controller.dart';

class AddFamilyMemberBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    Get.lazyPut<FamilyMemberRepository>(
      () => FamilyMemberRepository(apiService: Get.find()),
    );
    Get.put<AddFamilyMemberController>(
      AddFamilyMemberController(repository: Get.find()),
    );
  }
}
