import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/views/daignostics/widgets/add_family_member_button.dart';
import 'package:flip_health/views/daignostics/widgets/header_section.dart';
import 'package:flip_health/views/daignostics/widgets/user_card.dart';

class CommonMemberSelectionScreen extends StatelessWidget {
  final String title;
  final bool allowMultiSelect;
  final void Function(List<FamilyMember> selected) onContinue;
  final Widget? headerWidget;

  const CommonMemberSelectionScreen({
    super.key,
    required this.title,
    this.allowMultiSelect = false,
    required this.onContinue,
    this.headerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MemberController>();

    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: title),
      body: Obx(() {
        if (mc.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            if (headerWidget != null) headerWidget!,
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.rs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: AppString.kSelectFamilyMember,
                        subtitle: 'Select the family member for the service',
                      ),
                      SizedBox(height: 16.rh),
                      ...mc.familyMembers.map(
                        (member) => Obx(
                          () => UserCard(
                            name: member.name,
                            isSelected: allowMultiSelect
                                ? mc.isMemberSelected(member.id)
                                : mc.isUserSelected(member.id),
                            showAddButton: true,
                            onTap: () => allowMultiSelect
                                ? mc.toggleMember(member.id)
                                : mc.selectUser(member.id),
                            onAddTap: () => allowMultiSelect
                                ? mc.toggleMember(member.id)
                                : mc.selectUser(member.id),
                          ),
                        ),
                      ),
                      AddFamilyMemberButton(
                        onTap: mc.addNewFamilyMember,
                      ),
                      SizedBox(height: 80.rh),
                    ],
                  ),
                ),
              ),
            ),
            _buildContinueButton(mc),
          ],
        );
      }),
    );
  }

  Widget _buildContinueButton(MemberController mc) {
    if (allowMultiSelect) {
      return Obx(() => mc.selectedMemberIds.isNotEmpty
          ? SafeBottomPadding(
              child: ActionButton(
                text: '${AppString.kContinue} (${mc.selectedMemberIds.length})',
                onPressed: () => onContinue(mc.selectedMembers),
              ),
            )
          : const SizedBox.shrink());
    }

    return Obx(() {
      final hasSelection = mc.selectedUserId.value.isNotEmpty;
      return SafeBottomPadding(
        child: Opacity(
          opacity: hasSelection ? 1.0 : 0.5,
          child: ActionButton(
            text: AppString.kContinue,
            onPressed: () {
              if (!hasSelection) return;
              final member = mc.selectedMember;
              onContinue(member != null ? [member] : []);
            },
            isLoading: mc.isLoading.value,
          ),
        ),
      );
    });
  }
}