import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/dental%20controllers/dental_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';
import 'package:flip_health/views/dental/dental_vendors_screen.dart';

class DentalMemberSelectionScreen extends GetView<DentalController> {
  const DentalMemberSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MemberController>();

    return CommonMemberSelectionScreen(
      title: AppString.kDentalService,
   
      onContinue: (selected) {
        if (selected.isEmpty) return;
        mc.selectUser(selected.first.id);
        controller.continueToVendors();
        Get.to(() => const DentalVendorsScreen());
      },
    );
  }
}
