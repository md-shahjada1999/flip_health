import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/model/consultation%20models/consultation_model.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';

class ConsultationMemberSelectionScreen extends GetView<ConsultationController> {
  const ConsultationMemberSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args == 'virtual') {
      controller.consultationType.value = ConsultationType.virtual_;
    } else {
      controller.consultationType.value = ConsultationType.hospital;
    }

    final mc = Get.find<MemberController>();

    return CommonMemberSelectionScreen(
      title: controller.appBarTitle,
      onContinue: (selected) {
        if (selected.isEmpty) return;
        mc.selectUser(selected.first.id);
        controller.continueWithMemberSelection();
      },
    );
  }
}
