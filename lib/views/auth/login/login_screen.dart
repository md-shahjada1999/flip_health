import 'package:flip_health/controllers/auth%20controllers/login_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/app_validators.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),

                  CommonText(
                    controller.isEmailLogin.value
                        ? AppString.kEmailLoginTitle
                        : AppString.kLoginTitle,
                    fontSize: 28,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  const SizedBox(height: 8),

                  CommonText(
                    controller.isEmailLogin.value
                        ? AppString.kEmailLoginSubtitle
                        : AppString.kLoginSubtitle,
                    fontSize: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 40),

                  if (controller.isEmailLogin.value) ...[
                    _buildEmailFields(),
                  ] else ...[
                    _buildPhoneField(),
                  ],

                  const Spacer(),

                  _buildTermsCheckbox(),
                  const SizedBox(height: 24),

                  _buildConfirmButton(),
                  const SizedBox(height: 16),

                  _buildLoginModeToggle(),
                  const SizedBox(height: 24),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Obx(() => CustomTextField(
          label: AppString.kMobileNumberLabel,
          hint: AppString.kPhoneHint,
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          suffixIcon: controller.phoneText.isNotEmpty &&
                  AppValidator.isValidPhoneOrEmail(controller.phoneText.value)
              ? const Icon(Icons.check, color: AppColors.success)
              : null,
        ));
  }

  Widget _buildEmailFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => CustomTextField(
              label: AppString.kEmailLabel,
              hint: AppString.kEmailHint,
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
              suffixIcon: controller.emailText.isNotEmpty &&
                      AppValidator.isValidEmail(controller.emailText.value)
                  ? const Icon(Icons.check, color: AppColors.success)
                  : null,
            )),
        const SizedBox(height: 16),
        Obx(() => CustomTextField(
              label: AppString.kPasswordLabel,
              hint: AppString.kPasswordHint,
              controller: controller.passwordController,
              obscureText: controller.obscurePassword.value,
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
              suffixIcon: GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Obx(() => Row(
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
                    ? const Icon(Icons.check,
                        size: 14, color: AppColors.textOnPrimary)
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
        ));
  }

  Widget _buildConfirmButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: controller.isLoading
                ? null
                : controller.isButtonEnabled
                    ? (controller.isEmailLogin.value
                        ? controller.loginWithEmail
                        : controller.sendOTP)
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  controller.isButtonEnabled && !controller.isLoading
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                    ),
                  )
                : CommonText(
                    controller.isEmailLogin.value
                        ? AppString.kLogin
                        : AppString.kConfirm,
                    fontSize: 16,
                    color: AppColors.textOnPrimary,
                  ),
          ),
        ));
  }

  Widget _buildLoginModeToggle() {
    return Obx(() => Center(
          child: GestureDetector(
            onTap: controller.toggleLoginMode,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: controller.isEmailLogin.value
                        ? AppString.kLoginWithPhone
                        : AppString.kOrLoginWith,
                    style: TextStyleCustom.normalStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: controller.isEmailLogin.value
                        ? AppString.kMobile
                        : AppString.kEmail,
                    style: TextStyleCustom.normalStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
