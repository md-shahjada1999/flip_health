import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/claims/add_claim_step1.dart';
import 'package:flip_health/views/claims/add_claim_step2.dart';
import 'package:flip_health/views/claims/claim_overview_screen.dart';

class AddClaimScreen extends GetView<ClaimsController> {
  const AddClaimScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && controller.currentStep.value > 0) {
          controller.goToStep(controller.currentStep.value - 1);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: CommonAppBar.build(title: AppString.kAddNewClaim),
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => controller.currentStep.value = index,
                children: const [
                  AddClaimStep1(),
                  AddClaimStep2(),
                  ClaimOverviewScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Obx(() {
      final step = controller.currentStep.value;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 16.rh),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            _buildStepDot(0, step, AppString.kStepPatient),
            _buildStepLine(step >= 1),
            _buildStepDot(1, step, AppString.kStepBills),
            _buildStepLine(step >= 2),
            _buildStepDot(2, step, AppString.kStepReview),
          ],
        ),
      );
    });
  }

  Widget _buildStepDot(int index, int current, String label) {
    final isActive = current >= index;
    final isCurrent = current == index;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32.rs,
            height: 32.rs,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.backgroundTertiary,
              border: isCurrent ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 3) : null,
              boxShadow: isCurrent ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)] : null,
            ),
            child: Center(
              child: isActive
                  ? (isCurrent
                      ? CommonText('${index + 1}', fontSize: 12.rf, fontWeight: FontWeight.w700, color: Colors.white)
                      : Icon(Icons.check, size: 16.rs, color: Colors.white))
                  : CommonText('${index + 1}', fontSize: 12.rf, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 6.rh),
          CommonText(label, fontSize: 10.rf, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400, color: isActive ? AppColors.primary : AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 20.rh),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.borderLight,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
