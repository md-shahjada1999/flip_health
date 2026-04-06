import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
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
                  _buildDateTimeHeader(),
                  SizedBox(height: 24.rh),
                  _buildDateSelection(),
                  SizedBox(height: 24.rh),
                  _buildTimeSlotSection(
                    AppString.kMorning,
                    Icons.wb_sunny_outlined,
                    controller.morningSlots,
                  ),
                  SizedBox(height: 24.rh),
                  _buildTimeSlotSection(
                    AppString.kAfternoon,
                    Icons.wb_twilight_outlined,
                    controller.afternoonSlots,
                  ),
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

  Widget _buildDateTimeHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppColors.primary, size: 20.rs),
          SizedBox(width: 8.rw),
          CommonText(
            AppString.kChooseDateAndTime,
            fontSize: 13.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          const Spacer(),
          Obx(() => CommonText(
                controller.selectedMonthYear.value,
                fontSize: 13.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              )),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return SizedBox(
      height: 70.rh,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.rw),
            itemCount: controller.availableDates.length,
            itemBuilder: (context, index) {
              final date = controller.availableDates[index];
              final isSelected = controller.selectedDateIndex.value == index;

              return FadeInRight(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 50 * index),
                child: GestureDetector(
                  onTap: () => controller.selectDate(index),
                  child: Container(
                    width: 70.rw,
                    margin: EdgeInsets.only(right: 12.rw),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(12.rs),
                      border: Border.all(
                        color: isSelected
                            ? Colors.black
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText(
                          date['day']!,
                          fontSize: 20.rf,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          height: 1.3,
                        ),
                        SizedBox(height: 4.rh),
                        CommonText(
                          date['weekday']!,
                          fontSize: 11.rf,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _buildTimeSlotSection(
    String title,
    IconData icon,
    List<Map<String, dynamic>> slots,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18.rs),
              SizedBox(width: 8.rw),
              CommonText(
                title,
                fontSize: 12.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ],
          ),
          SizedBox(height: 12.rh),
          Obx(() => Wrap(
                spacing: 12.rw,
                runSpacing: 12.rh,
                children: slots.map((slot) {
                  final isSelected =
                      controller.selectedTimeSlot.value == slot['time'];
                  final isDisabled = slot['isDisabled'] ?? false;

                  return FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () => controller.selectTimeSlot(slot['time']),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.rw, vertical: 10.rh),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black
                              : isDisabled
                                  ? AppColors.backgroundTertiary
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(25.rs),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : AppColors.borderLight,
                          ),
                        ),
                        child: CommonText(
                          '${slot['time']}',
                          fontSize: 12.rf,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isDisabled
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
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
