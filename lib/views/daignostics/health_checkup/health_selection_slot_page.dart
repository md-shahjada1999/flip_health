import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class HealthCheckUpSlotSelectionPage extends StatelessWidget {
  const HealthCheckUpSlotSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HealthCheckupsController>();

    return Obx(() {
      final cat = controller.currentSlotCategory.value;
      return SafeScreenWrapper(
        bottomSafe: false,
        appBar: CommonAppBar.build(
          title: cat == 'pathology' ? 'Pathology Slot' : 'Radiology Slot',
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const LocationHeaderBar(),
                _buildCategoryIndicator(controller),
                Expanded(child: _buildSlotContent(controller)),
                _buildBottomButton(controller),
              ],
            ),
            Obx(() => controller.isBookingPreviewLoading.value
                ? Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryIndicator(HealthCheckupsController controller) {
    return Obx(() {
      final cat = controller.currentSlotCategory.value;
      final showBoth =
          controller.containsPathology && controller.containsRadiology;

      if (!showBoth) return const SizedBox.shrink();

      return FadeIn(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
          padding: EdgeInsets.all(4.rs),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12.rs),
          ),
          child: Row(
            children: [
              _tabItem(
                label: 'Pathology',
                icon: Icons.science_outlined,
                isActive: cat == 'pathology',
                isDone: controller.selectedPathologySlot.value != null,
              ),
              _tabItem(
                label: 'Radiology',
                icon: Icons.monitor_heart_outlined,
                isActive: cat == 'radiology',
                isDone: controller.selectedRadiologySlot.value != null,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _tabItem({
    required String label,
    required IconData icon,
    required bool isActive,
    required bool isDone,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(vertical: 10.rh),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.rs),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16.rs,
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary),
            SizedBox(width: 6.rw),
            CommonText(
              label,
              fontSize: 13.rf,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            if (isDone) ...[
              SizedBox(width: 6.rw),
              Icon(Icons.check_circle,
                  size: 14.rs, color: AppColors.success),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlotContent(HealthCheckupsController controller) {
    return Obx(() {
      if (controller.isSlotsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final cat = controller.currentSlotCategory.value;
      final dates =
          cat == 'pathology' ? controller.pathologyDates : controller.radiologyDates;
      final dateIndex = cat == 'pathology'
          ? controller.pathologyDateIndex.value
          : controller.radiologyDateIndex.value;
      final timeSlot = cat == 'pathology'
          ? controller.pathologyTimeSlot.value
          : controller.radiologyTimeSlot.value;
      final monthYear = cat == 'pathology'
          ? controller.pathologyMonthYear.value
          : controller.radiologyMonthYear.value;
      final slotsResp = cat == 'pathology'
          ? controller.pathologySlotsResponse.value
          : controller.radiologySlotsResponse.value;

      if (dates.isEmpty) {
        return Center(
          child: FadeIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_busy_outlined,
                    size: 64.rs, color: AppColors.textSecondary),
                SizedBox(height: 16.rh),
                CommonText(
                  'No slots available',
                  fontSize: 15.rf,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.rh),
        child: FadeIn(
          child: CommonSlotSelector(
            monthYearLabel: monthYear,
            availableDates: dates,
            selectedDateIndex: dateIndex,
            onDateSelected: (idx) => controller.onDateSelected(cat, idx),
            selectedTimeSlot: timeSlot,
            onTimeSlotSelected: (time) {
              if (slotsResp != null) {
                controller.onTimeSlotSelected(cat, time, slotsResp);
              }
            },
            morningSlots: controller.morningSlotMaps(slotsResp),
            afternoonSlots: controller.afternoonSlotMaps(slotsResp),
            eveningSlots: controller.eveningSlotMaps(slotsResp),
            slotsPerRow: 2,
            slotTimeFontSize: 10.5.rf,
          ),
        ),
      );
    });
  }

  Widget _buildBottomButton(HealthCheckupsController controller) {
    return Obx(() {
      final cat = controller.currentSlotCategory.value;
      final hasSlot = cat == 'pathology'
          ? controller.selectedPathologySlot.value != null
          : controller.selectedRadiologySlot.value != null;

      final isLast = cat == 'radiology' ||
          (cat == 'pathology' && !controller.containsRadiology);
      final label = isLast ? 'Continue to Overview' : 'Next: Radiology Slot';

      return ActionButton(
        text: label,
        isLoading: controller.isBookingPreviewLoading.value,
        onPressed: hasSlot && !controller.isBookingPreviewLoading.value
            ? () async => controller.confirmCurrentSlot()
            : null,
      );
    });
  }
}
