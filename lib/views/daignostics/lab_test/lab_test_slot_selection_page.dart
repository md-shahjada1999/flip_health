import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabTestSlotSelectionPage extends GetView<LabTestController> {
  const LabTestSlotSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Lab Tests',
        showBackButton: true,
        actions: [const MyOrdersButton()],
      ),
      body: Column(
        children: [
          const LocationHeaderBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 16.rh),
                  _buildNoteSection(),
                  SizedBox(height: 16.rh),
                  _buildPointsToRemember(),
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

  Widget _buildNoteSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.rw),
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8.rs),
      ),
      child: CommonText(
        AppString.kTimeSlotNote,
        fontSize: 11.rf,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildPointsToRemember() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kPointsToRemember,
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            height: 1.3,
          ),
          SizedBox(height: 8.rh),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 16.rs),
              SizedBox(width: 8.rw),
              Expanded(
                child: CommonText(
                  AppString.kPointToRemember1,
                  fontSize: 11.rf,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
