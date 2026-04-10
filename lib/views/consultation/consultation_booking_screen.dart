import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_dialog.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/consultation%20models/slot_model.dart';

class ConsultationBookingScreen extends GetView<ConsultationController> {
  const ConsultationBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: AppString.kConfirmBooking,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.rs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  SizedBox(height: 20.rh),
                  _buildPatientSection(),
                  SizedBox(height: 20.rh),
                  _buildDateTimeSection(),
                  SizedBox(height: 20.rh),
                  _buildPurposeField(),
                  SizedBox(height: 20.rh),
                  _buildDisclaimerSection(),
                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.rs),
            child: SafeBottomPadding(
              child: Obx(() => ActionButton(
                    text: AppString.kConfirmBooking,
                    isLoading: controller.isBooking.value,
                    onPressed: () => _confirmAndBook(),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kBookingSummary,
            fontSize: 15.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 14.rh),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52.rs,
                height: 52.rs,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.rs),
                ),
                child: Icon(
                  controller.isOnline
                      ? Icons.videocam_outlined
                      : Icons.local_hospital_outlined,
                  color: AppColors.primary,
                  size: 26.rs,
                ),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      _doctorName,
                      fontSize: 15.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 2.rh),
                    CommonText(
                      _doctorQualification,
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                    ),
                    if (_specialityDisplay.isNotEmpty) ...[
                      SizedBox(height: 2.rh),
                      CommonText(
                        _specialityDisplay,
                        fontSize: 11.rf,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.rh),
          Row(
            children: [
              _buildInfoChip(
                Icons.calendar_today_outlined,
                controller.isOnline
                    ? controller.formattedSelectedDate
                    : controller.offlineDayDisplay,
              ),
              SizedBox(width: 8.rw),
              _buildInfoChip(
                Icons.access_time_outlined,
                controller.isOnline
                    ? controller.selectedTimeDisplay
                    : controller.offlineTimeDisplay,
              ),
            ],
          ),
          if (!controller.isOnline && _hospitalName.isNotEmpty) ...[
            SizedBox(height: 10.rh),
            Row(children: [
              _buildInfoChip(Icons.local_hospital_outlined, _hospitalName),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 6.rh),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.rs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.rs, color: AppColors.textSecondary),
            SizedBox(width: 4.rw),
            Flexible(
              child: CommonText(
                text,
                fontSize: 11.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSection() {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  AppString.kPatient,
                  fontSize: 12.rf,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 4.rh),
                Obx(() => CommonText(
                      Get.find<MemberController>().selectedMember?.name ?? '',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
              ],
            ),
          ),
          Icon(Icons.person_outline, size: 18.rs, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return GestureDetector(
      onTap: () => _showSlotSheet(Get.context!),
      child: Container(
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    AppString.kDateAndTime,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 4.rh),
                  Obx(() => CommonText(
                        controller.isOnline
                            ? '${controller.formattedSelectedDate}, ${controller.selectedTimeDisplay}'
                            : '${controller.offlineDayDisplay}, ${controller.offlineTimeDisplay}',
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(6.rs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.rs),
              ),
              child: Icon(Icons.edit_calendar_outlined,
                  size: 18.rs, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndBook() async {
    final confirmed = await CommonDialog.confirm(
      title: 'Confirm Booking',
      message:
          'Are you sure you want to book this appointment? This action cannot be undone.',
      confirmText: 'Book Now',
      cancelText: 'Go Back',
    );
    if (confirmed == true) {
      if (controller.isOnline) {
        controller.bookOnlineAppointment();
      } else {
        controller.bookOfflineAppointment();
      }
    }
  }

  void _showSlotSheet(BuildContext context) {
    Get.bottomSheet(
      _SlotBottomSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPurposeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          AppString.kPurpose,
          fontSize: 13.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 8.rh),
        TextField(
          controller: controller.purposeController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppString.kPurposeHint,
            hintStyle: TextStyle(
              fontSize: 13.rf,
              fontFamily: 'Poppins',
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(14.rs),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.rs),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(12.rs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kDisclaimer,
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 10.rh),
          _buildDisclaimerPoint(1, AppString.kDisclaimerFees),
          SizedBox(height: 8.rh),
          _buildDisclaimerPoint(2, AppString.kDisclaimerRegistration),
        ],
      ),
    );
  }

  Widget _buildDisclaimerPoint(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          '$number.',
          fontSize: 12.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        SizedBox(width: 8.rw),
        Expanded(
          child: CommonText(
            text,
            fontSize: 12.rf,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────

  String get _doctorName => controller.isOnline
      ? controller.selectedOnlineDoctor.value?.name ?? ''
      : controller.selectedNetworkDoctor.value?.name ?? '';

  String get _doctorQualification => controller.isOnline
      ? controller.selectedOnlineDoctor.value?.qualification ?? ''
      : controller.selectedNetworkDoctor.value?.qualification ?? '';

  String get _specialityDisplay {
    if (controller.isOnline) {
      return controller.selectedOnlineDoctor.value?.specialityName ?? '';
    }
    return controller.selectedOfflineSpeciality.value?.name ?? '';
  }

  String get _hospitalName {
    if (controller.isOnline) return '';
    return controller.selectedNetworkDoctor.value?.network?.name ?? '';
  }
}

// ---------------------------------------------------------------------------
// Slot selection bottom sheet (reuses CommonSlotSelector)
// ---------------------------------------------------------------------------

class _SlotBottomSheet extends StatelessWidget {
  final ConsultationController controller;
  const _SlotBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.rh),
          Container(
            width: 40.rw,
            height: 4.rh,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2.rs),
            ),
          ),
          SizedBox(height: 14.rh),
          CommonText(
            'Change Slot',
            fontSize: 16.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 12.rh),
          Flexible(
            child: SingleChildScrollView(
              child: controller.isOnline
                  ? _buildOnlineSlots()
                  : _buildOfflineSlots(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.rw, 8.rh, 16.rw, 12.rh),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final hasSlot = controller.isOnline
                      ? controller.selectedSlot.value != null
                      : controller.selectedOfflineSlot.value.isNotEmpty;
                  return ElevatedButton(
                    onPressed: hasSlot ? () => Get.back() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.rh),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.rs),
                      ),
                    ),
                    child: CommonText(
                      'Confirm Slot',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Online slots ──────────────────────────────────────────────

  Widget _buildOnlineSlots() {
    return Obx(() {
      final dates = controller.nextSevenDays;
      final currentFull =
          DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
      int dateIndex = dates.indexWhere((d) => d['full'] == currentFull);
      if (dateIndex < 0) dateIndex = 0;

      final availableDates = dates
          .map((d) =>
              <String, String>{'day': d['day']!, 'weekday': d['weekday']!})
          .toList();

      String displayOf(SlotModel s) =>
          s.displayTime.isNotEmpty ? s.displayTime : s.time;

      final isLoading = controller.slotsLoading.value;
      final allSlots = controller.availableSlots;

      List<Map<String, dynamic>> toSlotMaps(Iterable<SlotModel> slots) =>
          slots
              .map((s) => <String, dynamic>{
                    'time': displayOf(s),
                    'isDisabled': !s.available,
                  })
              .toList();

      final morning = isLoading
          ? <Map<String, dynamic>>[]
          : toSlotMaps(allSlots.where((s) => s.isMorning));
      final afternoon = isLoading
          ? <Map<String, dynamic>>[]
          : toSlotMaps(allSlots.where((s) => s.isAfternoon));
      final evening = isLoading
          ? <Map<String, dynamic>>[]
          : toSlotMaps(allSlots.where((s) => s.isEvening));

      final sel = controller.selectedSlot.value;
      final selectedTime = sel != null ? displayOf(sel) : '';

      return Column(
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
              if (match != null && match.available) {
                controller.selectSlot(match);
              }
            },
            morningSlots: morning,
            afternoonSlots: afternoon,
            eveningSlots: evening,
          ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(32.rs),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (allSlots.isEmpty)
            Padding(
              padding: EdgeInsets.all(24.rs),
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

  // ─── Offline slots ─────────────────────────────────────────────

  Widget _buildOfflineSlots() {
    return Obx(() {
      if (controller.networkSchedulesLoading.value) {
        return Padding(
          padding: EdgeInsets.all(32.rs),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final dates = controller.offlineNextDays;
      final currentFull =
          DateFormat('yyyy-MM-dd').format(controller.offlineSelectedDate.value);
      int dateIndex = dates.indexWhere((d) => d['full'] == currentFull);
      if (dateIndex < 0) dateIndex = 0;

      final availableDates = dates
          .map((d) => <String, String>{
                'day': d['date'] as String,
                'weekday': d['weekday'] as String,
              })
          .toList();

      List<Map<String, dynamic>> toSlotMaps(List<String> slots24) => slots24
          .map((s) =>
              <String, dynamic>{'time': controller.to12HourFormat(s)})
          .toList();

      final selected12h = controller.selectedOfflineSlot.value.isNotEmpty
          ? controller.to12HourFormat(controller.selectedOfflineSlot.value)
          : '';

      return CommonSlotSelector(
        monthYearLabel:
            '${DateFormat('MMMM yyyy').format(DateTime.now())} (IST)',
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
