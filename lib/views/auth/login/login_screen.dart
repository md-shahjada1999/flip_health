import 'package:flip_health/controllers/auth%20controllers/login_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/app_validators.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: 40),
                _buildInputFields(),
                const Spacer(),
                _buildTermsCheckbox(),
                const SizedBox(height: 24),
                _buildConfirmButton(),
                const SizedBox(height: 24),
              ],
            )),
      ),
    );
  }

  Widget _buildTitle() {
    if (controller.isLinkFlow) {
      return CommonText(
        controller.linkTitle.value,
        fontSize: 28,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        height: 1.3,
      );
    }
    return CommonText(
      AppString.kLoginTitle,
      fontSize: 28,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      height: 1.3,
    );
  }

  Widget _buildSubtitle() {
    if (controller.isLinkFlow) {
      return CommonText(
        controller.linkSubtitle.value,
        fontSize: 16,
        color: AppColors.textTertiary,
      );
    }
    return CommonText(
      AppString.kLoginSubtitle,
      fontSize: 16,
      color: AppColors.textTertiary,
    );
  }

  Widget _buildInputFields() {
    if (controller.loginMode.value == LoginMode.linkEmail) {
      return _buildLinkEmailField();
    }
    if (controller.loginMode.value == LoginMode.linkPhone) {
      return _buildPhoneField();
    }
    return _buildPhoneField();
  }

  Widget _buildPhoneField() {
    final isLinkPhone = controller.loginMode.value == LoginMode.linkPhone;
    return Obx(() => CustomTextField(
          label: isLinkPhone ? 'Phone Number' : 'Phone Number or Email',
          hint: isLinkPhone
              ? 'Enter phone number to link'
              : 'Enter phone number or email',
          controller: controller.phoneController,
          keyboardType: isLinkPhone
              ? TextInputType.phone
              : TextInputType.emailAddress,
          prefixIcon: isLinkPhone
              ? Icon(Icons.phone_outlined,
                  size: 20, color: AppColors.textSecondary)
              : null,
          suffixIcon: controller.phoneText.isNotEmpty &&
                  (isLinkPhone
                      ? AppValidator.isValidPhoneNumber(
                          controller.phoneText.value)
                      : AppValidator.isValidPhoneOrEmail(
                          controller.phoneText.value))
              ? const Icon(Icons.check, color: AppColors.success)
              : null,
        ));
  }

  Widget _buildLinkEmailField() {
    return Obx(() => CustomTextField(
          label: 'Email Address',
          hint: 'Enter email to link',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined,
              color: AppColors.textSecondary, size: 20),
          suffixIcon: controller.emailText.isNotEmpty &&
                  AppValidator.isValidEmail(controller.emailText.value)
              ? const Icon(Icons.check, color: AppColors.success)
              : null,
        ));
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
                    ? _getButtonAction()
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
                    _getButtonText(),
                    fontSize: 16,
                    color: AppColors.textOnPrimary,
                  ),
          ),
        ));
  }

  VoidCallback? _getButtonAction() {
    if (controller.isLinkFlow) return controller.sendLinkOTP;
    return controller.sendOTP;
  }

  String _getButtonText() {
    if (controller.isLinkFlow) return 'Send OTP';
    return AppString.kConfirm;
  }

}
