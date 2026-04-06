import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/gym%20controllers/gym_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';
import 'package:flip_health/views/gym/gym_center_selection_screen.dart';

class GymMemberSelectionScreen extends GetView<GymController> {
  const GymMemberSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MemberController>();
    mc.resetSelection();

    return CommonMemberSelectionScreen(
      title: AppString.kSelectMembers,
      allowMultiSelect: true,
     
      headerWidget: _buildPlanBadge(),
      onContinue: (selected) {
        if (selected.isEmpty) return;
        Get.to(() => const GymCenterSelectionScreen());
      },
    );
  }

  Widget _buildPlanBadge() {
    final plan = controller.selectedPlan;
    if (plan == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 12.rh),
      decoration: BoxDecoration(
        color: plan.tierColor.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
              color: plan.tierColor.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.fitness_center, color: plan.tierColor, size: 18.rs),
          SizedBox(width: 10.rw),
          Expanded(
            child: CommonText(
              '${plan.type} • ${plan.months} ${AppString.kMonths} • ₹${plan.discountedPrice.toInt()}',
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 3.rh),
            decoration: BoxDecoration(
              color: plan.tierColor,
              borderRadius: BorderRadius.circular(4.rs),
            ),
            child: CommonText(
              plan.tier,
              fontSize: 10.rf,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
