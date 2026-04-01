import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';
import 'package:flip_health/views/vision/vision_vendors_screen.dart';

class VisionMemberSelectionScreen extends GetView<VisionController> {
  const VisionMemberSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args is String) {
      controller.visionType.value = args;
    }

    final mc = Get.find<MemberController>();

    return CommonMemberSelectionScreen(
      title: controller.appBarTitle,
      sponsoredSubtitle: AppString.kBookVisionServices,
      familySubtitle: AppString.kBookVisionForFamily,
      onContinue: (selected) {
        if (selected.isEmpty) return;
        mc.selectUser(selected.first.id);
        controller.continueToVendors();
        Get.to(() => const VisionVendorsScreen());
      },
    );
  }
}
