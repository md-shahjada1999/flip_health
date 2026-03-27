import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/add_family_member_controller.dart';

class AddFamilyMemberBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AddFamilyMemberController>(
      AddFamilyMemberController(),
    );
  }
}