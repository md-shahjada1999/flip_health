import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/views/daignostics/widgets/add_family_member_button.dart';
import 'package:flip_health/views/daignostics/widgets/header_section.dart';
import 'package:flip_health/views/daignostics/widgets/user_card.dart';

class CommonMemberSelectionScreen extends StatelessWidget {
  final String title;
  final bool allowMultiSelect;
  final void Function(List<FamilyMember> selected) onContinue;
  final String sponsoredSubtitle;
  final String familySubtitle;
  final Widget? headerWidget;

  const CommonMemberSelectionScreen({
    super.key,
    required this.title,
    this.allowMultiSelect = false,
    required this.onContinue,
    this.sponsoredSubtitle = AppString.kBookFreeHealthCheckups,
    this.familySubtitle = AppString.kBookPaidHealthCheckups,
    this.headerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MemberController>();

    return Scaffold(
      backgroundColor: AppColors.background,
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
                        title: AppString.kForYou,
                        subtitle: sponsoredSubtitle,
                      ),
                      SizedBox(height: 16.rh),
                      ...mc.sponsoredMembers.map((member) => Obx(() => UserCard(
                            name: member.name,
                            subtitle: AppString.kSponsoredByCompany(
                              member.sponsoredBy ?? '',
                            ),
                            subtitleColor: AppColors.success,
                            isSelected: allowMultiSelect
                                ? mc.isMemberSelected(member.id)
                                : mc.isUserSelected(member.id),
                            onTap: () => allowMultiSelect
                                ? mc.toggleMember(member.id)
                                : mc.selectUser(member.id),
                          ))),
                      SizedBox(height: 32.rh),
                      SectionHeader(
                        title: AppString.kForYourFamily,
                        subtitle: familySubtitle,
                      ),
                      SizedBox(height: 16.rh),
                      ...mc.nonSponsoredMembers.map((member) => Obx(() => UserCard(
                            name: member.name,
                            subtitle: member.hasPackages
                                ? AppString.kPackagesAvailable
                                : null,
                            subtitleColor: AppColors.textSecondary,
                            isSelected: allowMultiSelect
                                ? mc.isMemberSelected(member.id)
                                : mc.isUserSelected(member.id),
                            showAddButton: true,
                            onAddTap: () => allowMultiSelect
                                ? mc.toggleMember(member.id)
                                : mc.selectUser(member.id),
                          ))),
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
          ? ActionButton(
              text:
                  '${AppString.kContinue} (${mc.selectedMemberIds.length})',
              onPressed: () => onContinue(mc.selectedMembers),
            )
          : const SizedBox.shrink());
    }

    return Obx(() => ActionButton(
          text: AppString.kContinue,
          onPressed: () {
            if (mc.selectedUserId.value.isEmpty) {
              return;
            }
            final member = mc.selectedMember;
            onContinue(member != null ? [member] : []);
          },
          isLoading: mc.isLoading.value,
        ));
  }
}
