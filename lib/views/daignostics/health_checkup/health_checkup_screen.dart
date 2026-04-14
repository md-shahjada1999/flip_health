import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';

class HealthCheckupsScreen extends GetView<HealthCheckupsController> {
  const HealthCheckupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonMemberSelectionScreen(
      title: AppString.kHealthCheckupsTitle,
      allowMultiSelect: true,
      onContinue: (selected) {
        if (selected.isEmpty) return;
        controller.continueWithMemberSelection(selected);
      },
    );
  }
}
