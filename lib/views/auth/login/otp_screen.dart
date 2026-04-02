import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth controllers/otp_controllers.dart';

class OTPScreen extends GetView<OTPController> {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OTPController c = controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),

                    Obx(() => CommonText(
                          c.isLinkFlow
                              ? 'Verify Link'
                              : AppString.kOTPTitle,
                          fontSize: 28,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        )),
                    const SizedBox(height: 16),

                    Obx(() {
                      return RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: c.isLinkFlow
                                  ? 'Enter the OTP sent to '
                                  : AppString.kOTPSubtitle,
                              style: TextStyleCustom.normalStyle(
                                fontSize: 16,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            TextSpan(
                              text: '\n${c.phoneNumber} ',
                              style: TextStyleCustom.normalStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            WidgetSpan(
                                child: SizedBox(
                              height: ResponsiveHelper.spacing(35),
                            )),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: c.editPhoneNumber,
                                child: CommonText(
                                  AppString.kEdit,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 40),

                    Obx(() {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:
                            List.generate(c.otpControllers.length, (index) {
                          final str = c.otpValues[index];
                          final filled = str.isNotEmpty;
                          return Container(
                            width: 48,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: filled
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 1.5,
                              ),
                              color: filled
                                  ? AppColors.primaryLight
                                  : AppColors.background,
                            ),
                            child: TextField(
                              controller: c.otpControllers[index],
                              focusNode: c.focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: TextStyleCustom.textFieldStyle(
                                fontSize: 20,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) =>
                                  c.onOTPChanged(value, index),
                            ),
                          );
                        }),
                      );
                    }),

                    const SizedBox(height: 32),

                    Obx(() {
                      return GestureDetector(
                        onTap: c.canResend ? c.resendOTP : null,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppString.kDidntGetOTP,
                                style: TextStyleCustom.normalStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: c.canResend
                                    ? AppString.kResend
                                    : ' (${c.resendTimer}s)',
                                style: TextStyleCustom.normalStyle(
                                  fontSize: 14,
                                  color: c.canResend
                                      ? AppColors.primary
                                      : AppColors.textQuaternary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const Spacer(),

                    Obx(() {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: c.isLoading
                              ? null
                              : (c.isButtonEnabled ? c.verifyOTP : null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.isButtonEnabled && !c.isLoading
                                ? AppColors.primary
                                : AppColors.textQuaternary,
                            foregroundColor: AppColors.textOnPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: c.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textOnPrimary,
                                    ),
                                  ),
                                )
                              : CommonText(
                                  AppString.kConfirm,
                                  fontSize: 16,
                                  color: AppColors.textOnPrimary,
                                ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
