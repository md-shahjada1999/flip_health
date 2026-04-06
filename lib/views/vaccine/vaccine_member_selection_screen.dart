import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/controllers/vaccine%20controllers/vaccine_controller.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';
import 'package:flip_health/views/vaccine/vaccine_types_screen.dart';

class VaccineMemberSelectionScreen extends GetView<VaccineController> {
  const VaccineMemberSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MemberController>();

    return CommonMemberSelectionScreen(
      title: AppString.kVaccineService,
     
      onContinue: (selected) {
        if (selected.isEmpty) return;
        mc.selectUser(selected.first.id);
        controller.continueToVaccineTypes();
        Get.to(() => const VaccineTypesScreen());
      },
    );
  }
}
