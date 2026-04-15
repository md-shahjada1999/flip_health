import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/helpers/subscription_helper.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/routes/app_routes.dart';

/// After POST `/patient/member` — patient_app `SuccessScreen` + optional `MySubscriptionsView`.
class AddFamilyMemberSuccessScreen extends StatelessWidget {
  const AddFamilyMemberSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final showSubscriptionPath =
        SubscriptionHelper.shouldOfferSubscriptionActivationCta();

    return PopScope(
      canPop: false,
      child: SafeScreenWrapper(
        bottomSafe: false,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.rw),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 48.rh),
                      CommonText(
                        AppString.kAddMemberSuccessTitle,
                        fontSize: 22.rf,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.rh),
                      CommonText(
                        AppString.kAddMemberSuccessBody,
                        fontSize: 14.rf,
                        height: 1.45,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 28.rh),
                      Lottie.asset(
                        'assets/lotties/success.json',
                        width: 220.rs,
                        height: 220.rs,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              SafeBottomPadding(
                child: showSubscriptionPath
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ActionButton(
                            text: AppString.kContinueToSubscriptions,
                            backgroundColor: AppColors.textPrimary,
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () =>
                                Get.offNamed(AppRoutes.mySubscriptions),
                          ),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: CommonText(
                              AppString.kDone,
                              fontSize: 15.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : ActionButton(
                        text: AppString.kDone,
                        backgroundColor: AppColors.textPrimary,
                        icon: Icons.check_rounded,
                        onPressed: () => Get.back(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
