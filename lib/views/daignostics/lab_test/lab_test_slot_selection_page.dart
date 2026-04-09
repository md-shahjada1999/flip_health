import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabTestSlotSelectionPage extends GetView<LabTestController> {
  const LabTestSlotSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Pick a Slot',
        showBackButton: true,
        actions: [const MyOrdersButton()],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isSlotsLoading.value &&
                  controller.slotsResponse.value == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final hasSlots = controller.morningSlotMaps.isNotEmpty ||
                  controller.afternoonSlotMaps.isNotEmpty ||
                  controller.eveningSlotMaps.isNotEmpty;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 16.rh),
                child: Column(
                  children: [
                    FadeIn(
                      child: Obx(() => CommonSlotSelector(
                            monthYearLabel: controller.selectedMonthYear.value,
                            availableDates: controller.availableDates,
                            selectedDateIndex: controller.selectedDateIndex.value,
                            onDateSelected: controller.selectDate,
                            selectedTimeSlot: controller.selectedSlotDisplay.value,
                            onTimeSlotSelected: controller.selectTimeSlot,
                            morningSlots: controller.morningSlotMaps,
                            afternoonSlots: controller.afternoonSlotMaps,
                            eveningSlots: controller.eveningSlotMaps,
                          )),
                    ),
                    if (!hasSlots && !controller.isSlotsLoading.value)
                      Padding(
                        padding: EdgeInsets.only(top: 40.rh),
                        child: Column(
                          children: [
                            Icon(Icons.event_busy_rounded,
                                size: 40.rs, color: AppColors.textQuaternary),
                            SizedBox(height: 12.rh),
                            CommonText(
                              'No slots for this date',
                              fontSize: 13.rf,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 4.rh),
                            CommonText(
                              'Try selecting another date',
                              fontSize: 12.rf,
                              color: AppColors.textQuaternary,
                            ),
                          ],
                        ),
                      ),
                    if (controller.isSlotsLoading.value &&
                        controller.slotsResponse.value != null)
                      Padding(
                        padding: EdgeInsets.only(top: 40.rh),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          Obx(() {
            final hasSelection = controller.selectedSlotId.value.isNotEmpty;
            return SafeBottomPadding(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasSelection ? 1.0 : 0.4,
                child: ActionButton(
                  text: 'Confirm Slot',
                  onPressed: controller.confirmSlotSelection,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
