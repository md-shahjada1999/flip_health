import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/add_family_member_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/family_member_repository.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/custom_dropdown.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';

class AddFamilyMemberScreen extends StatelessWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<FamilyMemberRepository>()) {
      Get.lazyPut<FamilyMemberRepository>(
        () => FamilyMemberRepository(apiService: Get.find()),
      );
    }
    final controller = Get.put(
      AddFamilyMemberController(repository: Get.find()),
    );

    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kAddNewFamilyMemberTitle),
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.rw,
                  vertical: 20.rh,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => CustomDropdown(
                        label:
                            '${AppString.kRelationship}${AppString.kRequiredStar}',
                        hint: AppString.kRelationshipHint,
                        value: controller.selectedRelationship.value.isEmpty
                            ? null
                            : controller.selectedRelationship.value,
                        items: controller.relationshipOptions.toList(),
                        onChanged: controller.selectRelationship,
                        validator: controller.validateRelationship,
                      ),
                    ),
                    SizedBox(height: 20.rh),

                    CustomTextField(
                      label: '${AppString.kName}${AppString.kRequiredStar}',
                      hint: AppString.kNameHint,
                      controller: controller.nameController,
                      keyboardType: TextInputType.name,
                      validator: controller.validateName,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.rh),

                    Obx(
                      () => CustomTextField(
                        label:
                            '${AppString.kDateOfBirth}${AppString.kRequiredStar}',
                        hint: controller.getFormattedDate(),
                        readOnly: true,
                        onTap: () => controller.selectDateOfBirth(context),
                        validator: controller.validateDateOfBirth,
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20.rs,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.rh),

                    FormField<String>(
                      validator: (_) => controller.validateGender(
                        controller.selectedGender.value.isEmpty
                            ? null
                            : controller.selectedGender.value,
                      ),
                      builder: (fieldState) {
                        return Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                '${AppString.kGender}${AppString.kRequiredStar}',
                                fontSize: 13.rf,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 8.rh),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (
                                    var i = 0;
                                    i < AppString.kGenders.length;
                                    i++
                                  ) ...[
                                    if (i > 0) SizedBox(width: 8.rw),
                                    Expanded(
                                      child: _GenderOptionTile(
                                        label: AppString.kGenders[i],
                                        icon: _genderIcon(
                                          AppString.kGenders[i],
                                        ),
                                        selected:
                                            controller.selectedGender.value ==
                                            AppString.kGenders[i],
                                        onTap: () {
                                          final g = AppString.kGenders[i];
                                          controller.selectGender(g);
                                          fieldState.didChange(g);
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (fieldState.hasError)
                                Padding(
                                  padding: EdgeInsets.only(top: 6.rh),
                                  child: Text(
                                    fieldState.errorText!,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12.rf,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.rh),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label:
                                '${AppString.kPhoneNumber}${AppString.kOptionalInParens}',
                            hint: AppString.kPhoneNumberOptionalHint,
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            validator: controller.validatePhoneOptional,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        SizedBox(width: 8.rw),
                        Padding(
                          padding: EdgeInsets.only(top: 36.rh),
                          child: Tooltip(
                            message: AppString.kMemberOtpNote,
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.textSecondary,
                              size: 22.rs,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.rh),
                    CommonText(
                      AppString.kPhoneNotRequiredForChildren,
                      fontSize: 11.rf,
                      color: AppColors.textTertiary,
                      height: 1.35,
                    ),
                    SizedBox(height: 8.rh),
                    Obx(() {
                      if (controller.phoneForUi.value.trim().length != 10) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CommonText(
                            AppString.kMemberOtpNote,
                            fontSize: 11.rf,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                          SizedBox(height: 12.rh),
                          _OtpButtons(controller: controller),
                          SizedBox(height: 12.rh),
                          Obx(
                            () => CustomTextField(
                              label:
                                  '${AppString.kEnterOtpLabel}${AppString.kRequiredStar}',
                              hint: controller.otpSent.value
                                  ? AppString.kEnterOtpHint
                                  : AppString.kOtpHintBeforeSend,
                              controller: controller.otpController,
                              readOnly: !controller.otpSent.value,
                              keyboardType: TextInputType.number,
                              validator: controller.validateOtp,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          SizedBox(height: 16.rh),
                        ],
                      );
                    }),

                    CommonText(
                      '${AppString.kHeight}${AppString.kRequiredStar}',
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 8.rh),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Obx(
                            () => CustomDropdown(
                              label:
                                  '${AppString.kHeightFt}${AppString.kRequiredStar}',
                              hint: AppString.kHeightFt,
                              value: controller.selectedHeightFeet.value.isEmpty
                                  ? null
                                  : controller.selectedHeightFeet.value,
                              items: controller.heightFeetOptions,
                              onChanged: controller.selectHeightFeet,
                              validator: controller.validateHeightFeet,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.rw),
                        Expanded(
                          child: Obx(
                            () => CustomDropdown(
                              label:
                                  '${AppString.kHeightIn}${AppString.kRequiredStar}',
                              hint: AppString.kHeightIn,
                              value:
                                  controller.selectedHeightInches.value.isEmpty
                                  ? null
                                  : controller.selectedHeightInches.value,
                              items: controller.heightInchOptions,
                              onChanged: controller.selectHeightInches,
                              validator: controller.validateHeightInches,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.rh),

                    CustomTextField(
                      label: '${AppString.kWeight}${AppString.kRequiredStar}',
                      hint: AppString.kWeightHint,
                      controller: controller.weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: controller.validateWeight,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                    ),
                    SizedBox(height: 20.rh),

                    FormField<String>(
                      validator: (_) => controller.validateBloodPressure(
                        controller.selectedBloodPressure.value.isEmpty
                            ? null
                            : controller.selectedBloodPressure.value,
                      ),
                      builder: (fieldState) {
                        return Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                '${AppString.kBloodPressure}${AppString.kRequiredStar}',
                                fontSize: 13.rf,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 8.rh),
                              _yesNoRadios(
                                groupValue:
                                    controller.selectedBloodPressure.value,
                                onChanged: (v) {
                                  if (v != null) {
                                    controller.selectBloodPressure(v);
                                    fieldState.didChange(v);
                                  }
                                },
                              ),
                              if (fieldState.hasError)
                                Padding(
                                  padding: EdgeInsets.only(top: 6.rh),
                                  child: Text(
                                    fieldState.errorText!,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12.rf,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.rh),

                    FormField<String>(
                      validator: (_) => controller.validateDiabetes(
                        controller.selectedDiabetes.value.isEmpty
                            ? null
                            : controller.selectedDiabetes.value,
                      ),
                      builder: (fieldState) {
                        return Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                '${AppString.kDiabetes}${AppString.kRequiredStar}',
                                fontSize: 13.rf,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 8.rh),
                              _yesNoRadios(
                                groupValue: controller.selectedDiabetes.value,
                                onChanged: (v) {
                                  if (v != null) {
                                    controller.selectDiabetes(v);
                                    fieldState.didChange(v);
                                  }
                                },
                              ),
                              if (fieldState.hasError)
                                Padding(
                                  padding: EdgeInsets.only(top: 6.rh),
                                  child: Text(
                                    fieldState.errorText!,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12.rf,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.rh),

                    CommonText(
                      AppString.kFamilyMemberDisclaimer,
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ],
                ),
              ),
            ),
            SafeBottomPadding(
              child: Obx(() {
                controller.formStateTick.value;
                final canSubmit = controller.canSave();
                return ActionButton(
                  text: AppString.kSaveAndContinue,
                  onPressed: canSubmit && !controller.isLoading.value
                      ? controller.saveAndContinue
                      : null,
                  isLoading: controller.isLoading.value,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _genderIcon(String gender) {
  switch (gender) {
    case 'Male':
      return Icons.male_rounded;
    case 'Female':
      return Icons.female_rounded;
    default:
      return Icons.transgender_rounded;
  }
}

/// Gender option: icon + label in one row of three.
class _GenderOptionTile extends StatelessWidget {
  const _GenderOptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : AppColors.borderLight;
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.surface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12.rs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.rs),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.rh, horizontal: 4.rw),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26.rs,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              SizedBox(height: 6.rh),
              CommonText(
                label,
                fontSize: 12.rf,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yes / No on one row (blood pressure & diabetes).
Widget _yesNoRadios({
  required String groupValue,
  required ValueChanged<String?> onChanged,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      for (final y in AddFamilyMemberController.yesNoDisplay)
        Expanded(
          child: RadioListTile<String>(
            title: CommonText(y, fontSize: 14.rf, color: AppColors.textPrimary),
            value: y,
            groupValue: groupValue.isEmpty ? null : groupValue,
            activeColor: AppColors.primary,
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 4.rw),
            visualDensity: VisualDensity.compact,
            onChanged: onChanged,
          ),
        ),
    ],
  );
}

class _OtpButtons extends StatelessWidget {
  const _OtpButtons({required this.controller});

  final AddFamilyMemberController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sending = controller.otpSending.value;
      final sent = controller.otpSent.value;
      final sec = controller.resendSeconds.value;
      final cooldown = sent && sec > 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed: sending || cooldown ? null : () => controller.sendOtp(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(vertical: 12.rh),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.rs),
              ),
            ),
            child: sending
                ? SizedBox(
                    height: 20.rh,
                    width: 20.rh,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : CommonText(
                    sent ? AppString.kResendOtp : AppString.kSendOtp,
                    fontSize: 14.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
          ),
          if (sent && sec > 0) ...[
            SizedBox(height: 8.rh),
            CommonText(
              'Resend available in ${sec}s',
              fontSize: 12.rf,
              color: AppColors.textTertiary,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    });
  }
}
