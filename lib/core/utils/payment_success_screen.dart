import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/routes/app_routes.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onButtonPressed;
  final String? buttonText;

  const PaymentSuccessScreen({
    super.key,
    this.title = '',
    this.subtitle = '',
    this.onButtonPressed,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    final displayTitle =
        title.isNotEmpty ? title : AppString.kPaymentSuccessTitle;
    final displaySubtitle =
        subtitle.isNotEmpty ? subtitle : AppString.kPaymentSuccessMessage;
    final displayButtonText = buttonText ?? AppString.kAlright;
    final onTap = onButtonPressed ?? () => Get.offAllNamed(AppRoutes.dashboard);

    return PopScope(
      canPop: false,
      child: SafeScreenWrapper(
        bottomSafe: false,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 140.rh),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.rw),
                      child: CommonText(
                        displayTitle,
                        textAlign: TextAlign.center,
                        fontSize: 22.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 10.rh),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.rw),
                      child: CommonText(
                        displaySubtitle,
                        textAlign: TextAlign.center,
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 50.rh),

                    Lottie.asset(
                      'assets/lotties/success.json',
                      width: 250.rs,
                      height: 250.rs,
                      repeat: false,
                    ),
                  ],
                ),
              ),
            ),

            SafeBottomPadding(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.rw,
                  vertical: 18.rh,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.rh,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.rs),
                      ),
                    ),
                    child: CommonText(
                      displayButtonText,
                      fontSize: 15.rf,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
