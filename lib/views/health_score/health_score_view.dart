import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health_score%20controllers/health_score_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/health_score/health_score_page1.dart';
import 'package:flip_health/views/health_score/health_score_bmi.dart';

class HealthScoreView extends GetView<HealthScoreController> {
  const HealthScoreView({Key? key}) : super(key: key);

  static const _stepLabels = ['Personal Info', 'BMI Score'];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (controller.currentPage.value > 0) {
            controller.previousPage();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppColors.textPrimary,
            onPressed: () {
              if (controller.currentPage.value > 0) {
                controller.previousPage();
              } else {
                Get.back();
              }
            },
          ),
          title: CommonText(
            'User Details',
            fontSize: 18.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  HealthScorePage1(),
                  HealthScoreBmiPage(),
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
      final page = controller.currentPage.value;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 48.rw, vertical: 16.rh),
        child: Row(
          children: List.generate(2, (index) {
            final isActive = index <= page;
            final isLast = index == 1;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 28.rs,
                          height: 28.rs,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4.rs),
                          ),
                          child: Center(
                            child: isActive && index < page
                                ? Icon(Icons.check,
                                    size: 16.rs, color: Colors.white)
                                : CommonText(
                                    '${index + 1}',
                                    fontSize: 12.rf,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                          ),
                        ),
                        SizedBox(height: 6.rh),
                        CommonText(
                          _stepLabels[index],
                          fontSize: 10.rf,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        margin: EdgeInsets.only(bottom: 20.rh),
                        color: index < page
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      );
    });
  }
}
