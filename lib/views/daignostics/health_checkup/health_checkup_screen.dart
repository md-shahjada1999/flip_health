import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';

class HealthCheckupsScreen extends StatefulWidget {
  const HealthCheckupsScreen({super.key});

  @override
  State<HealthCheckupsScreen> createState() => _HealthCheckupsScreenState();
}

class _HealthCheckupsScreenState extends State<HealthCheckupsScreen> {
  late final HealthCheckupsController _hc;
  late final MemberController _members;

  @override
  void initState() {
    super.initState();
    _hc = Get.find<HealthCheckupsController>();
    _members = Get.find<MemberController>();
    _hc.applyEntryArguments(Get.arguments);
    _members.resetSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CommonMemberSelectionScreen(
        title: AppString.kHealthCheckupsTitle,
        allowMultiSelect: true,
        filterAhcEligibleOnly: _hc.filterAhcMembersOnly.value,
        showAddFamilyMember: !_hc.hideAddFamilyMemberOnPicker,
        onContinue: (selected) {
          if (selected.isEmpty) return;
          _hc.continueWithMemberSelection(selected);
        },
      ),
    );
  }
}
