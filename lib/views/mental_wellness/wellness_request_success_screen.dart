import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/routes/app_routes.dart';

/// Full-screen success after POST `/patient/wellness/session` succeeds.
class WellnessRequestSuccessScreen extends StatelessWidget {
  const WellnessRequestSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final isNutrition = args is Map && args['nutrition'] == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.rw),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 88.rs,
                    ),
                    SizedBox(height: 24.rh),
                    CommonText(
                      AppString.kWellnessSuccessTitle,
                      fontSize: 22.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.rh),
                    CommonText(
                      isNutrition
                          ? AppString.kWellnessSuccessBodyNutrition
                          : AppString.kWellnessSuccessBody,
                      fontSize: 15.rf,
                      height: 1.45,
                      color: AppColors.textTertiary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ActionButton(
                text: AppString.kDone,
                backgroundColor: AppColors.textPrimary,
                icon: Icons.done_rounded,
                onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
