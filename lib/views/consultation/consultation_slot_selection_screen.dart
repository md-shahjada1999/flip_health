import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/consultation%20models/slot_model.dart';

class ConsultationSlotSelectionScreen extends GetView<ConsultationController> {
  const ConsultationSlotSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorName = controller.isOnline
        ? controller.selectedOnlineDoctor.value?.name ?? 'Doctor'
        : controller.selectedNetworkDoctor.value?.name ?? 'Doctor';

    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Appointment - $doctorName',
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
                  Obx(() => controller.isOnline
                      ? _buildOnlineSlots()
                      : _buildOfflineSchedule()),
                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.rs),
            child: SafeBottomPadding(
              child: Obx(
                () => ActionButton(
                  text: controller.selectedSlot.value != null || controller.selectedOfflineSlot.value.isNotEmpty ? AppString.kConfirm : 'Select Slot',
                  onPressed: controller.selectedSlot.value != null || controller.selectedOfflineSlot.value.isNotEmpty ? 
                    controller.isOnline
                        ? controller.confirmOnlineSlotSelection
                        : controller.confirmOfflineSlotSelection
                    : null,
                ),
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
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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

  // ─── Online: CommonSlotSelector with API slots ───────────────

  Widget _buildOnlineSlots() {
    return Obx(() {
      final dates = controller.nextSevenDays;
      final currentFull =
          DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
      int dateIndex = dates.indexWhere((d) => d['full'] == currentFull);
      if (dateIndex < 0) dateIndex = 0;

      final availableDates = dates
          .map((d) => <String, String>{'day': d['day']!, 'weekday': d['weekday']!})
          .toList();

      String displayOf(SlotModel s) =>
          s.displayTime.isNotEmpty ? s.displayTime : s.time;

      final isLoading = controller.slotsLoading.value;
      final allSlots = controller.availableSlots;

      List<Map<String, dynamic>> toSlotMaps(Iterable<SlotModel> slots) =>
          slots.map((s) => <String, dynamic>{
                'time': displayOf(s),
                'isDisabled': !s.available,
              }).toList();

      final morning = isLoading ? <Map<String, dynamic>>[] : toSlotMaps(allSlots.where((s) => s.isMorning));
      final afternoon = isLoading ? <Map<String, dynamic>>[] : toSlotMaps(allSlots.where((s) => s.isAfternoon));
      final evening = isLoading ? <Map<String, dynamic>>[] : toSlotMaps(allSlots.where((s) => s.isEvening));

      final sel = controller.selectedSlot.value;
      final selectedTime = sel != null ? displayOf(sel) : '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonSlotSelector(
            monthYearLabel:
                '${DateFormat('MMMM yyyy').format(controller.selectedDate.value)} (IST)',
            availableDates: availableDates,
            selectedDateIndex: dateIndex,
            onDateSelected: (index) {
              final parsed = DateTime.tryParse(dates[index]['full']!);
              if (parsed != null) controller.fetchAvailableSlots(date: parsed);
            },
            selectedTimeSlot: selectedTime,
            onTimeSlotSelected: (display) {
              final match = allSlots.firstWhereOrNull(
                (s) => displayOf(s) == display,
              );
              if (match != null && match.available) controller.selectSlot(match);
            },
            morningSlots: morning,
            afternoonSlots: afternoon,
            eveningSlots: evening,
          ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(48.rs),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (!isLoading && allSlots.isEmpty)
            Padding(
              padding: EdgeInsets.all(32.rs),
              child: Center(
                child: CommonText(
                  AppString.kNoSlotsAvailable,
                  fontSize: 13.rf,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      );
    });
  }

  // ─── Offline: CommonSlotSelector with generated 15-min slots ─

  Widget _buildOfflineSchedule() {
    return Obx(() {
      if (controller.networkSchedulesLoading.value) {
        return Padding(
          padding: EdgeInsets.all(48.rs),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final dates = controller.offlineNextDays;
      final currentFull = DateFormat('yyyy-MM-dd').format(controller.offlineSelectedDate.value);
      int dateIndex = dates.indexWhere((d) => d['full'] == currentFull);
      if (dateIndex < 0) dateIndex = 0;

      final availableDates = dates.map((d) => <String, String>{
        'day': d['date'] as String,
        'weekday': d['weekday'] as String,
      }).toList();

      List<Map<String, dynamic>> toSlotMaps(List<String> slots24) =>
          slots24.map((s) => <String, dynamic>{
            'time': controller.to12HourFormat(s),
          }).toList();

      final selected12h = controller.selectedOfflineSlot.value.isNotEmpty
          ? controller.to12HourFormat(controller.selectedOfflineSlot.value)
          : '';

      return CommonSlotSelector(
        monthYearLabel: '${DateFormat('MMMM yyyy').format(DateTime.now())} (IST)',
        availableDates: availableDates,
        selectedDateIndex: dateIndex,
        onDateSelected: (index) {
          final dt = dates[index]['dateTime'] as DateTime;
          controller.selectOfflineDate(dt);
        },
        selectedTimeSlot: selected12h,
        onTimeSlotSelected: (display12h) {
          final all = controller.offlineAvailableSlots;
          final match = all.firstWhereOrNull(
            (s) => controller.to12HourFormat(s) == display12h,
          );
          if (match != null) controller.selectOfflineTimeSlot(match);
        },
        morningSlots: toSlotMaps(controller.offlineMorningSlots),
        afternoonSlots: toSlotMaps(controller.offlineAfternoonSlots),
        eveningSlots: toSlotMaps(controller.offlineEveningSlots),
      );
    });
  }
}
