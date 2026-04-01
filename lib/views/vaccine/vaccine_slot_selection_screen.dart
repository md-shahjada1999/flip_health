import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/vaccine%20controllers/vaccine_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/views/vaccine/vaccine_overview_screen.dart';

class VaccineSlotSelectionScreen extends GetView<VaccineController> {
  const VaccineSlotSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: AppString.kSelectVaccineSlots),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                  )),
            ),
          ),
          Obx(() => controller.selectedTimeSlot.value.isNotEmpty
              ? ActionButton(
                  text: AppString.kContinue,
                  onPressed: () => Get.to(() => const VaccineOverviewScreen()),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
