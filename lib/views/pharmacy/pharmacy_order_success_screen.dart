import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:lottie/lottie.dart';

class PharmacyOrderSuccessScreen extends StatelessWidget {
  const PharmacyOrderSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonText(
                      AppString.kOrderGenerated,
                      fontSize: 28.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                      height: 1.3,
                    ),
                    SizedBox(height: 40.rh),
                    Lottie.asset(
                      'assets/lotties/success.json',
                      width: 250.rs,
                      height: 250.rs,
                    ),
                  ],
                ),
              ),
              ActionButton(
                text: AppString.kDone,
                onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
