import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health_score%20controllers/health_score_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/views/health_score/health_score_result.dart';

class HealthScoreBmiPage extends GetView<HealthScoreController> {
  const HealthScoreBmiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 20.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.rh),
                _buildGenderSelector(),
                SizedBox(height: 24.rh),
                _buildAgeDisplay(),
                SizedBox(height: 40.rh),
                _buildHeightSlider(),
                SizedBox(height: 40.rh),
                _buildWeightSlider(),
              ],
            ),
          ),
        ),
        _buildCalculateButton(),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Obx(() {
      final locked = controller.isGenderLocked.value;
      return Opacity(
        opacity: locked ? 0.7 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.rs),
            border: Border.all(color: AppColors.borderLight, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                  child: _buildGenderTab(0, Icons.male, 'Male', locked)),
              Expanded(
                  child: _buildGenderTab(1, Icons.female, 'Female', locked)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGenderTab(
      int gender, IconData icon, String label, bool locked) {
    final isSelected = controller.selectedGender.value == gender;
    return GestureDetector(
      onTap: locked ? null : () => controller.selectGenderInt(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.rh),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.transparent,
          borderRadius: BorderRadius.circular(40.rs),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.rs,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(width: 8.rw),
            CommonText(
              label,
              fontSize: 15.rf,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            if (locked && isSelected) ...[
              SizedBox(width: 6.rw),
              Icon(Icons.lock_outline,
                  size: 14.rs,
                  color: isSelected ? Colors.white70 : AppColors.textTertiary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAgeDisplay() {
    return Obx(() => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(Icons.cake_outlined,
                  size: 20.rs, color: AppColors.textSecondary),
              SizedBox(width: 12.rw),
              CommonText(
                'Age',
                fontSize: 14.rf,
                color: AppColors.textSecondary,
              ),
              const Spacer(),
              CommonText(
                '${controller.calculatedAge} years',
                fontSize: 16.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 8.rw),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 2.rh),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.rs),
                ),
                child: CommonText(
                  'From DOB',
                  fontSize: 10.rf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildHeightSlider() {
    return Obx(() {
      final display = controller.heightDisplay;
      final displayStr = controller.isHeightInCm.value
          ? '${display.round()} cm'
          : '${display.toStringAsFixed(1)} ft';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                'Height(${controller.heightUnitLabel})',
                fontSize: 16.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              _buildUnitToggle(
                leftLabel: 'cm',
                rightLabel: 'feet',
                isLeftSelected: controller.isHeightInCm.value,
                onToggle: controller.toggleHeightUnit,
              ),
            ],
          ),
          SizedBox(height: 8.rh),
          CommonText(
            displayStr,
            fontSize: 28.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          SliderTheme(
            data: _sliderTheme(),
            child: Slider(
              value: display.clamp(0, controller.heightMax),
              min: 0,
              max: controller.heightMax,
              onChanged: controller.setHeight,
            ),
          ),
          _buildSliderLabels('0', '${controller.heightMax.round()}'),
        ],
      );
    });
  }

  Widget _buildWeightSlider() {
    return Obx(() {
      final display = controller.weightDisplay;
      final displayStr = controller.isWeightInKg.value
          ? display.round().toString()
          : display.toStringAsFixed(1);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                'Weight(${controller.weightUnitLabel})',
                fontSize: 16.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              _buildUnitToggle(
                leftLabel: 'kg',
                rightLabel: 'lbs',
                isLeftSelected: controller.isWeightInKg.value,
                onToggle: controller.toggleWeightUnit,
              ),
            ],
          ),
          SizedBox(height: 8.rh),
          CommonText(
            displayStr,
            fontSize: 28.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          SliderTheme(
            data: _sliderTheme(),
            child: Slider(
              value: display.clamp(0, controller.weightMax),
              min: 0,
              max: controller.weightMax,
              onChanged: controller.setWeight,
            ),
          ),
          _buildSliderLabels('0', '${controller.weightMax.round()}'),
        ],
      );
    });
  }

  Widget _buildUnitToggle({
    required String leftLabel,
    required String rightLabel,
    required bool isLeftSelected,
    required Function(bool) onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.rs),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleChip(leftLabel, isLeftSelected, () => onToggle(true)),
          _buildToggleChip(rightLabel, !isLeftSelected, () => onToggle(false)),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 6.rh),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.transparent,
          borderRadius: BorderRadius.circular(20.rs),
        ),
        child: CommonText(
          label,
          fontSize: 12.rf,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSliderLabels(String min, String max) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.rw),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(min, fontSize: 11.rf, color: AppColors.textSecondary),
          CommonText(max, fontSize: 11.rf, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  SliderThemeData _sliderTheme() {
    return SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.borderLight,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.15),
      trackHeight: 4.rh,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.rs),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 20.rs),
    );
  }

  Widget _buildCalculateButton() {
    return Obx(() => ActionButton(
          text: 'Calculate BMI',
          backgroundColor: AppColors.primary,
          icon: Icons.calculate,
          isLoading: controller.isSubmitting.value,
          onPressed: () async {
            if (controller.isSubmitting.value) return;
            final success = await controller.submitHealthScore();
            if (success) {
              Get.to(() => const HealthScoreResult());
            } else {
              ToastCustom.showSnackBar(
                subtitle: controller.apiError.value.isNotEmpty
                    ? controller.apiError.value
                    : 'Failed to calculate BMI. Please try again.',
              );
            }
          },
        ));
  }
}
