import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';

class LabTestMemberSelectionScreen extends GetView<LabTestController> {
  const LabTestMemberSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MemberController>();

    return CommonMemberSelectionScreen(
      title: AppString.kLabTestsTitle,
      onContinue: (selected) {
        if (selected.isEmpty) return;
        mc.selectUser(selected.first.id);
        controller.continueWithMemberSelection();
      },
    );
  }
}
