import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';

class ConsultationSlotSelectionScreen extends GetView<ConsultationController> {
  const ConsultationSlotSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title:
            'Appointment - ${controller.selectedDoctor.value?.name ?? 'Doctor'}',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppointmentNote(),
                  SizedBox(height: 16.rh),
                  Obx(() => CommonSlotSelector(
                        monthYearLabel: controller.selectedMonthYear.value,
                        availableDates: controller.availableDates,
                        selectedDateIndex:
                            controller.selectedDateIndex.value,
                        onDateSelected: controller.selectDate,
                        selectedTimeSlot:
                            controller.selectedTimeSlot.value,
                        onTimeSlotSelected: controller.selectTimeSlot,
                        morningSlots: controller.morningSlots,
                        afternoonSlots: controller.afternoonSlots,
                      )),
                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.rs),
            child: SafeBottomPadding(
              child: ActionButton(
                text: AppString.kConfirm,
                onPressed: controller.confirmSlotSelection,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentNote() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.rw, 16.rh, 16.rw, 0),
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 18.rs),
          SizedBox(width: 10.rw),
          Expanded(
            child: CommonText(
              AppString.kAppointmentNote,
              fontSize: 12.rf,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
