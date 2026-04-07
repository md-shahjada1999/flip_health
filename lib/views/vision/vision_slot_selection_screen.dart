import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/vision/vision_prescription_screen.dart';
import 'package:flip_health/views/vision/vision_overview_screen.dart';

class VisionSlotSelectionScreen extends GetView<VisionController> {
  const VisionSlotSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kSelectVisionSlots),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary));
              }

              if (controller.availableDates.isEmpty) {
                return Center(
                  child: CommonText(
                    'No slots available',
                    fontSize: 14.rf,
                    color: AppColors.textSecondary,
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 20.rh),
                child: Obx(() => CommonSlotSelector(
                      monthYearLabel: controller.monthYearLabel.value,
                      availableDates: controller.availableDates.toList(),
                      selectedDateIndex: controller.selectedDateIndex.value,
                      onDateSelected: controller.selectDate,
                      selectedTimeSlot: controller.selectedTimeSlot.value,
                      onTimeSlotSelected: controller.selectTimeSlot,
                      morningSlots: controller.morningSlots.toList(),
                      afternoonSlots: controller.afternoonSlots.toList(),
                      eveningSlots: controller.eveningSlots.toList(),
                    )),
              );
            }),
          ),
          Obx(() => controller.selectedTimeSlot.value.isNotEmpty
              ? SafeBottomPadding(
                  child: ActionButton(
                    text: AppString.kContinue,
                    onPressed: () => Get.to(() => controller.isEyeCheckup
                        ? const VisionOverviewScreen()
                        : const VisionPrescriptionScreen()),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
