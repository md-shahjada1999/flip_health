import 'package:flip_health/controllers/auth%20controllers/login_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/app_validators.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),

              // Title
              CommonText(
                AppString.kLoginTitle,
                fontSize: 28,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              const SizedBox(height: 8),

              // Subtitle
              CommonText(
                AppString.kLoginSubtitle,
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 40),

              // Phone input label
              CommonText(
                AppString.kMobileNumberLabel,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),

              // Phone input field with reactive suffix icon
              Obx(() => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyleCustom.textFieldStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: AppString.kPhoneHint,
                    hintStyle: TextStyleCustom.textFieldStyle(
                      fontSize: 16,
                      color: AppColors.textQuaternary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: controller.phoneText.isNotEmpty &&
                            AppValidator.isValidPhoneOrEmail(controller.phoneText.value)
                        ? const Icon(
                            Icons.check,
                            color: AppColors.success,
                          )
                        : null,
                  ),
                ),
              )),

              const Spacer(),

              // Terms and conditions
              Obx(() => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: controller.toggleTermsAcceptance,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: controller.isTermsAccepted
                            ? AppColors.primary
                            : AppColors.transparent,
                        border: Border.all(
                          color: controller.isTermsAccepted
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: controller.isTermsAccepted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.textOnPrimary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: AppString.kClickToAccept,
                            style: TextStyleCustom.normalStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: AppString.kTermsAndConditions,
                            style: TextStyleCustom.normalStyle(
                              fontSize: 14,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 24),

              // Confirm button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : controller.isButtonEnabled
                          ? controller.sendOTP
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isButtonEnabled && !controller.isLoading
                        ? AppColors.primary
                        : AppColors.textQuaternary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading
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
              )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
