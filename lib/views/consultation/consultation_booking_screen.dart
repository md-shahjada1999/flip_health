import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ConsultationBookingScreen extends GetView<ConsultationController> {
  const ConsultationBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: AppString.kBookAppointment,
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
                  _buildDoctorCard(),
                  SizedBox(height: 20.rh),
                  _buildFeeBreakdown(),
                  SizedBox(height: 20.rh),
                  _buildPatientSection(),
                  SizedBox(height: 20.rh),
                  _buildDateTimeSection(),
                  SizedBox(height: 20.rh),
                  _buildDisclaimerSection(),
                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.rs),
            child: ActionButton(
              text: AppString.kConfirm,
              onPressed: controller.confirmBooking,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    final doctor = controller.selectedDoctor.value;
    if (doctor == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.rs,
                height: 56.rs,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.rs),
                ),
                child: doctor.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.rs),
                        child: Image.asset(doctor.imageUrl!, fit: BoxFit.cover),
                      )
                    : Icon(Icons.person, color: AppColors.primary, size: 28.rs),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      doctor.name,
                      fontSize: 15.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 2.rh),
                    CommonText(
                      doctor.qualification,
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                    ),
                    if (doctor.isCashless) ...[
                      SizedBox(height: 6.rh),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.rw, vertical: 3.rh),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.rs),
                        ),
                        child: CommonText(
                          AppString.kCashlessAvailable,
                          fontSize: 10.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
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
              _buildInfoTag(Icons.work_outline, doctor.experience),
              SizedBox(width: 8.rw),
              _buildInfoTag(
                  Icons.local_hospital_outlined, doctor.hospitalName),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
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
                label,
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

  Widget _buildFeeBreakdown() {
    final doctor = controller.selectedDoctor.value;
    final fee = doctor?.consultationFee ?? 0;

    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildFeeRow(AppString.kDoctorsFee, '₹${fee.toStringAsFixed(0)}'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.rh),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          _buildFeeRow(AppString.kTotalAmount, '₹${fee.toStringAsFixed(0)}',
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(
          label,
          fontSize: 13.rf,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        CommonText(
          value,
          fontSize: 14.rf,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ],
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
                  controller.selectedMember?.name ?? '',
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, size: 18.rs, color: AppColors.primary),
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
                Obx(() => CommonText(
                      '${controller.getFormattedSelectedDate()}, ${controller.selectedTimeSlot.value}',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, size: 18.rs, color: AppColors.primary),
        ],
      ),
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
}
