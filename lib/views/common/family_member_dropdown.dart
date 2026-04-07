import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';

/// Dropdown row + bottom sheet to pick a [FamilyMember] (same pattern as language selector).
class FamilyMemberDropdown extends StatelessWidget {
  final List<FamilyMember> members;
  final bool isLoading;
  final String? selectedMemberId;
  final ValueChanged<FamilyMember> onSelected;
  final String label;
  final bool showRequiredMark;

  const FamilyMemberDropdown({
    Key? key,
    required this.members,
    required this.isLoading,
    required this.selectedMemberId,
    required this.onSelected,
    this.label = '',
    this.showRequiredMark = true,
  }) : super(key: key);

  FamilyMember? get _selected {
    if (selectedMemberId == null || selectedMemberId!.isEmpty) return null;
    try {
      return members.firstWhere((m) => m.id == selectedMemberId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = label.isEmpty ? AppString.kSelectFamilyMember : label;
    final heading = showRequiredMark ? '$title *' : title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          heading,
          fontSize: 13.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        SizedBox(height: 6.rh),
        if (isLoading)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.rh),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: CommonText(
              'Loading…',
              fontSize: 14.rf,
              color: AppColors.textSecondary,
            ),
          )
        else if (members.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.rh),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: CommonText(
              'No family members found',
              fontSize: 14.rf,
              color: AppColors.textSecondary,
            ),
          )
        else
          InkWell(
            onTap: () => _openSheet(context, title),
            child: ShakeX(
              duration: Duration(milliseconds: 800),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.rh, horizontal: 12.rw),
                decoration:  BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(12.rs),
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      blurRadius: 10.rs,
                      offset: Offset(0, 4.rs),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        _displayName(_selected),
                        fontSize: 14.rf,
                        color: _selected == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                      size: 28.rs,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _displayName(FamilyMember? m) {
    if (m == null) return AppString.kSelectFamilyMember;
    final rel = m.relationship ?? '';
    return rel.isNotEmpty ? '${m.name} ($rel)' : m.name;
  }

  void _openSheet(BuildContext context, String sheetTitle) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.55),
        padding: EdgeInsets.all(20.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.rw,
              height: 4.rh,
              margin: EdgeInsets.only(bottom: 16.rh),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.rs),
              ),
            ),
            CommonText(
              sheetTitle,
              fontSize: 18.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 12.rh),
            Expanded(
              child: ListView.separated(
                itemCount: members.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (_, i) {
                  final m = members[i];
                  final sel = m.id == selectedMemberId;
                  return ListTile(
                    dense: true,
                    selected: sel,
                    selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                    leading: Icon(
                      sel ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: sel ? AppColors.primary : AppColors.textSecondary,
                      size: 22.rs,
                    ),
                    title: CommonText(
                      m.name,
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    subtitle: CommonText(
                      '${m.relationship ?? ''} • ${m.gender ?? ''} • ${m.age} yrs',
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      onSelected(m);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
