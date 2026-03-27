import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';

class HealthCheckUpSlotSelectionPage extends StatelessWidget {
  const HealthCheckUpSlotSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder(builder:  (HealthCheckupsController controller) {
      return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: AppString.kHealthCheckupsTitle,
        showBackButton: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.rw),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 6.rh),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.borderDark, width: 0.7),
                borderRadius: BorderRadius.circular(20.rs),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(AppString.kShoppingBagIcon, width: 12.rs),
                  SizedBox(width: 4.rw),
                  CommonText(
                    AppString.kMyOrders,
                    fontSize: 12.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            // Location Header
            _buildLocationHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.rh),

                    // Date and Time Selection
                    _buildDateTimeSection(controller),

                    SizedBox(height: 24.rh),

                    // Date Selection Row
                    _buildDateSelection(controller),

                    SizedBox(height: 24.rh),

                    // Morning Slots
                    _buildTimeSlotSection(
                      controller,
                      AppString.kMorning,
                      Icons.wb_sunny_outlined,
                      controller.morningSlots,
                    ),

                    SizedBox(height: 24.rh),

                    // Afternoon Slots
                    _buildTimeSlotSection(
                      controller,
                      AppString.kAfternoon,
                      Icons.wb_twilight_outlined,
                      controller.afternoonSlots,
                    ),

                    SizedBox(height: 16.rh),

                    // Note Section
                    _buildNoteSection(),

                    SizedBox(height: 16.rh),

                    // Points to Remember
                    _buildPointsToRemember(),

                    SizedBox(height: 100.rh),
                  ],
                ),
              ),
            ),

            // Bottom Confirm Button
            _buildBottomButton(controller),
          ],
        );
      }),
    );
    });
    
    
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 12.rh),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary, size: 20.rs),
          SizedBox(width: 8.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  AppString.kHome,
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        AppString.kDefaultAddress,
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16.rs,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(HealthCheckupsController controller) {
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
          Spacer(),
          CommonText(
            controller.selectedMonthYear.value,
            fontSize: 13.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ],
      ),
    );
  }
Widget _buildDateSelection(HealthCheckupsController controller) {
    return 
    
    Container(
      height: 70.rh,
      child: Obx(() => ListView.builder(
        
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.rw),
        itemCount: controller.availableDates.length,
        itemBuilder: (context, index) {
          final date = controller.availableDates[index];
          RxBool isSelected = (controller.selectedDateIndex.value == index).obs;

          return FadeInRight(
            duration: Duration(milliseconds: 300),
            delay: Duration(milliseconds: 50 * index),
            child: GestureDetector(
              onTap: () => controller.selectDate(index),
              child: Container(
                width: 70.rw,
                margin: EdgeInsets.only(right: 12.rw),
                decoration: BoxDecoration(
                  color: isSelected.value ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12.rs),
                  border: Border.all(
                    color: isSelected.value ? Colors.black : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonText(
                      date['day']!,
                      fontSize: 20.rf,
                      fontWeight: FontWeight.w700,
                      color: isSelected.value ? Colors.white : AppColors.textPrimary,
                      height: 1.3,
                    ),
                    SizedBox(height: 4.rh),
                    CommonText(
                      date['weekday']!,
                      fontSize: 11.rf,
                      fontWeight: FontWeight.w500,
                      color: isSelected.value ? Colors.white : AppColors.textSecondary,
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
    HealthCheckupsController controller,
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
              final isSelected = controller.selectedTimeSlot.value == slot['time'];
              final isDisabled = slot['isDisabled'] ?? false;

              return FadeIn(
                duration: Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: isDisabled ? null : () => controller.selectTimeSlot(slot['time']),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 10.rh),
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
                            : isDisabled
                                ? AppColors.borderLight
                                : AppColors.borderLight,
                        width: 1,
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

  Widget _buildBottomButton(HealthCheckupsController controller) {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: ActionButton(
        text: AppString.kConfirm,
        onPressed: () {
          controller.confirmSlotSelection();
        },
      ),
    );
  }
}