import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';

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
                    onPressed: controller.isOnline
                        ? controller.bookOnlineAppointment
                        : controller.bookOfflineAppointment,
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
                  AppString.kDateAndTime,
                  fontSize: 12.rf,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 4.rh),
                CommonText(
                  controller.isOnline
                      ? '${controller.formattedSelectedDate}, ${controller.selectedTimeDisplay}'
                      : '${controller.offlineDayDisplay}, ${controller.offlineTimeDisplay}',
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
          Icon(Icons.schedule_outlined, size: 18.rs, color: AppColors.primary),
        ],
      ),
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
