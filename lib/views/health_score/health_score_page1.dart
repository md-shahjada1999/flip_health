import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health_score%20controllers/health_score_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';

class HealthScorePage1 extends GetView<HealthScoreController> {
  const HealthScorePage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 16.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Personal Information',
                  fontSize: 20.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 8.rh),
                CommonText(
                  'We need some basic details to calculate your health score',
                  fontSize: 13.rf,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 24.rh),
                Obx(() => CustomTextField(
                      label: 'Full Name *',
                      hint: 'Enter your full name',
                      controller: controller.nameController,
                      readOnly: controller.isNameLocked.value,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
                      ],
                      prefixIcon: Icon(Icons.person_outline,
                          size: 20.rs, color: AppColors.textSecondary),
                      suffixIcon: controller.isNameLocked.value
                          ? Icon(Icons.lock_outline,
                              size: 16.rs, color: AppColors.textTertiary)
                          : null,
                    )),
                SizedBox(height: 20.rh),
                _buildDateOfBirth(context),
                SizedBox(height: 20.rh),
                _buildLanguageSelector(),
                SizedBox(height: 24.rh),
                _buildDiabeticChips(),
                SizedBox(height: 20.rh),
                _buildBPChips(),
                SizedBox(height: 24.rh),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
        Obx(() {
          final allFilled =
              controller.nameText.value.trim().length >= 3 &&
              controller.dob.value != null &&
              controller.language.value.isNotEmpty &&
              controller.isDiabetic.value != null &&
              controller.hasBloodPressure.value != null;

          return ActionButton(
            text: 'Save & Proceed',
            icon: Icons.arrow_forward,
            onPressed: allFilled ? controller.nextPage : null,
          );
        }),
      ],
    );
  }

  Widget _buildDateOfBirth(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          'Date of Birth *',
          fontSize: 13.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 8.rh),
        Obx(() {
          final locked = controller.isDobLocked.value;
          return GestureDetector(
            onTap: locked ? null : () => _pickDate(context),
            child: Opacity(
              opacity: locked ? 0.7 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.rw, vertical: 16.rh),
                decoration: BoxDecoration(
                  color: locked
                      ? AppColors.backgroundTertiary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.rs),
                  border: Border.all(
                    color: controller.dob.value != null
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 20.rs, color: AppColors.textSecondary),
                    SizedBox(width: 12.rw),
                    Expanded(
                      child: CommonText(
                        controller.dob.value != null
                            ? controller.dobFormatted
                            : 'Select date of birth',
                        fontSize: 14.rf,
                        color: controller.dob.value != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (controller.dob.value != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.rw, vertical: 2.rh),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.rs),
                        ),
                        child: CommonText(
                          '${controller.calculatedAge} yrs',
                          fontSize: 12.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    SizedBox(width: 8.rw),
                    if (locked)
                      Icon(Icons.lock_outline,
                          size: 16.rs, color: AppColors.textTertiary)
                    else
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 22.rs, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.dob.value ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) controller.dob.value = picked;
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          'Preferred Language *',
          fontSize: 13.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 8.rh),
        Obx(() {
          final locked = controller.isLanguageLocked.value;
          return GestureDetector(
            onTap: locked ? null : _showLanguageSheet,
            child: Opacity(
              opacity: locked ? 0.7 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.rw, vertical: 16.rh),
                decoration: BoxDecoration(
                  color: locked
                      ? AppColors.backgroundTertiary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.rs),
                  border: Border.all(
                    color: controller.language.value.isNotEmpty
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.language,
                        size: 20.rs, color: AppColors.textSecondary),
                    SizedBox(width: 12.rw),
                    Expanded(
                      child: CommonText(
                        controller.language.value.isNotEmpty
                            ? controller.language.value
                            : 'Select language',
                        fontSize: 14.rf,
                        color: controller.language.value.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (locked)
                      Icon(Icons.lock_outline,
                          size: 16.rs, color: AppColors.textTertiary)
                    else
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 22.rs, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showLanguageSheet() {
    Get.bottomSheet(
      Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.rs, 12.rs, 20.rs, 24.rs),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.rw,
                height: 4.rh,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.rs),
                ),
              ),
              SizedBox(height: 16.rh),
              CommonText(
                'Select Language',
                fontSize: 18.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 16.rh),
              ...HealthScoreController.availableLanguages.map(
                (lang) => ListTile(
                  title: CommonText(
                    lang,
                    fontSize: 15.rf,
                    color: AppColors.textPrimary,
                  ),
                  trailing: controller.language.value == lang
                      ? Icon(Icons.check_circle,
                          color: AppColors.primary, size: 22.rs)
                      : null,
                  onTap: () {
                    controller.language.value = lang;
                    Get.back();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.rs),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDiabeticChips() {
    return Obx(() => _buildChipRow(
          title: 'Are you Diabetic? *',
          yesSelected: controller.isDiabetic.value == true,
          noSelected: controller.isDiabetic.value == false,
          onYes: () => controller.setDiabetic(true),
          onNo: () => controller.setDiabetic(false),
          locked: controller.isDiabeticLocked.value,
        ));
  }

  Widget _buildBPChips() {
    return Obx(() => _buildChipRow(
          title: 'Do you have Blood Pressure? *',
          yesSelected: controller.hasBloodPressure.value == true,
          noSelected: controller.hasBloodPressure.value == false,
          onYes: () => controller.setBP(true),
          onNo: () => controller.setBP(false),
          locked: controller.isBPLocked.value,
        ));
  }

  Widget _buildChipRow({
    required String title,
    required bool yesSelected,
    required bool noSelected,
    required VoidCallback onYes,
    required VoidCallback onNo,
    bool locked = false,
  }) {
    return Opacity(
      opacity: locked ? 0.7 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonText(
                title,
                fontSize: 13.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              if (locked) ...[
                SizedBox(width: 6.rw),
                Icon(Icons.lock_outline,
                    size: 14.rs, color: AppColors.textTertiary),
              ],
            ],
          ),
          SizedBox(height: 10.rh),
          Row(
            children: [
              _buildChip(
                  label: 'Yes',
                  isSelected: yesSelected,
                  onTap: locked ? null : onYes),
              SizedBox(width: 12.rw),
              _buildChip(
                  label: 'No',
                  isSelected: noSelected,
                  onTap: locked ? null : onNo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 32.rw, vertical: 10.rh),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10.rs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: CommonText(
          label,
          fontSize: 14.rf,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20.rs, color: AppColors.primary),
          SizedBox(width: 12.rw),
          Expanded(
            child: CommonText(
              'Your personal data is secure and will only be used to calculate your health score.',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
