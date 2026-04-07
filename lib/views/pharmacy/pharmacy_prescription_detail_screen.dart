import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/pharmacy%20controllers/pharmacy_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/pharmacy%20models/flip_health_prescription_model.dart';

class PharmacyPrescriptionDetailScreen extends GetView<PharmacyController> {
  const PharmacyPrescriptionDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: AppString.kPrescriptionDetail),
      body: Obx(() {
        if (controller.detailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final prescription = controller.prescriptionDetail.value;
        if (prescription == null) {
          return Center(
            child: CommonText(
              'Failed to load prescription',
              fontSize: 14.rf,
              color: AppColors.textSecondary,
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(prescription),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.rw, 16.rh, 20.rw, 20.rh),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (prescription.appointment != null)
                            _buildAppointmentInfo(prescription.appointment!),
                          if (prescription.appointment != null)
                            SizedBox(height: 16.rh),
                          _buildMedicinesSection(prescription.details),
                          if (prescription.notes.isNotEmpty) ...[
                            SizedBox(height: 16.rh),
                            _buildNotesSection(prescription.notes),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeBottomPadding(
              child: Obx(() => ActionButton(
                    text: AppString.kSelectAndOrder,
                    isLoading: controller.isOrdering.value,
                    onPressed: controller.isOrdering.value
                        ? () {}
                        : () => controller.placeOrderFromDetail(
                            prescription.appointmentId),
                  )),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeroBanner(FlipHealthPrescription prescription) {
    final doctor = prescription.appointment?.doctor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.primary.withValues(alpha: 0.02),
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 8.rh),
          Image.asset(
            AppString.kPrescriptionDetailImage,
            height: 120.rh,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.rh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.rw),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.rs),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.rs),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.rs,
                    height: 50.rs,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.rs),
                    ),
                    child: Icon(Icons.person_outlined,
                        size: 26.rs, color: AppColors.primary),
                  ),
                  SizedBox(width: 14.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          doctor != null
                              ? 'Dr. ${doctor.name}'
                              : 'Unknown Doctor',
                          fontSize: 16.rf,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        if (doctor?.speciality != null) ...[
                          SizedBox(height: 2.rh),
                          CommonText(
                            doctor!.speciality!.name,
                            fontSize: 13.rf,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                        SizedBox(height: 6.rh),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.rw, vertical: 3.rh),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundTertiary,
                                borderRadius: BorderRadius.circular(6.rs),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 11.rs,
                                      color: AppColors.textSecondary),
                                  SizedBox(width: 4.rw),
                                  CommonText(
                                    prescription.createdAtDate,
                                    fontSize: 11.rf,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.rw),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.rw, vertical: 3.rh),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundTertiary,
                                borderRadius: BorderRadius.circular(6.rs),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.medication_outlined,
                                      size: 11.rs,
                                      color: AppColors.textSecondary),
                                  SizedBox(width: 4.rw),
                                  CommonText(
                                    '${prescription.medicineCount} ${AppString.kMedicineCount}',
                                    fontSize: 11.rf,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo(PrescriptionAppointment appointment) {
    final items = <_InfoEntry>[];
    if (appointment.symptoms.isNotEmpty) {
      items.add(_InfoEntry(AppString.kSymptoms, appointment.symptoms));
    }
    if (appointment.diagnosis.isNotEmpty) {
      items.add(_InfoEntry(AppString.kDiagnosis, appointment.diagnosis));
    }
    if (appointment.recommendation.isNotEmpty) {
      items.add(
          _InfoEntry(AppString.kRecommendation, appointment.recommendation));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildInfoRow(items[i].label, items[i].value),
            if (i < items.length - 1) ...[
              SizedBox(height: 8.rh),
              Divider(color: AppColors.borderLight, height: 1),
              SizedBox(height: 8.rh),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 11.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 4.rh),
        CommonText(
          value,
          fontSize: 13.rf,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildMedicinesSection(PrescriptionDetails details) {
    final allMeds = [...details.chronic, ...details.others];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medication_outlined,
                size: 20.rs, color: AppColors.primary),
            SizedBox(width: 8.rw),
            CommonText(
              AppString.kMedicines,
              fontSize: 16.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12.rs),
              ),
              child: CommonText(
                '${allMeds.length}',
                fontSize: 12.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.rh),
        ...allMeds.map((med) => _buildMedicineCard(med)),
      ],
    );
  }

  Widget _buildMedicineCard(MedicineItem medicine) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.rh),
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 3.rh),
                decoration: BoxDecoration(
                  color: medicine.isChronic
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6.rs),
                ),
                child: CommonText(
                  medicine.type.isNotEmpty ? medicine.type : AppString.kTablet,
                  fontSize: 10.rf,
                  fontWeight: FontWeight.w600,
                  color:
                      medicine.isChronic ? AppColors.warning : AppColors.primary,
                ),
              ),
              if (medicine.isChronic) ...[
                SizedBox(width: 6.rw),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.rs),
                  ),
                  child: CommonText(
                    AppString.kChronic,
                    fontSize: 9.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.rh),
          CommonText(
            medicine.name,
            fontSize: 15.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 10.rh),
          Row(
            children: [
              if (medicine.days.isNotEmpty && medicine.days != '0')
                _buildPill(
                  Icons.timer_outlined,
                  '${medicine.days} ${AppString.kDays}',
                ),
              if (medicine.weekly.isNotEmpty && medicine.weekly != '0') ...[
                SizedBox(width: 8.rw),
                _buildPill(
                  Icons.repeat,
                  '${medicine.weekly} ${AppString.kTimesPerWeek}',
                ),
              ],
            ],
          ),
          SizedBox(height: 10.rh),
          _buildDosageRow(medicine),
        ],
      ),
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 4.rh),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8.rs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.rs, color: AppColors.textSecondary),
          SizedBox(width: 4.rw),
          CommonText(text,
              fontSize: 11.rf, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDosageRow(MedicineItem medicine) {
    return Row(
      children: [
        if (medicine.hasMorning)
          _buildDoseChip(AppString.kMorning, medicine.morning,
              Icons.wb_sunny_outlined, AppColors.warning),
        if (medicine.hasAfternoon) ...[
          SizedBox(width: 6.rw),
          _buildDoseChip(AppString.kAfternoon, medicine.afternoon,
              Icons.wb_cloudy_outlined, AppColors.info),
        ],
        if (medicine.hasNight) ...[
          SizedBox(width: 6.rw),
          _buildDoseChip(AppString.kNight, medicine.night,
              Icons.nightlight_outlined, AppColors.textSecondary),
        ],
      ],
    );
  }

  Widget _buildDoseChip(
      String label, String detail, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.rh, horizontal: 6.rw),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.rs),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14.rs, color: color),
            SizedBox(height: 2.rh),
            CommonText(
              label,
              fontSize: 9.rf,
              fontWeight: FontWeight.w600,
              color: color,
              textAlign: TextAlign.center,
            ),
            CommonText(
              detail,
              fontSize: 8.rf,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.rs),
        border:
            Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sticky_note_2_outlined,
                  size: 16.rs, color: AppColors.warning),
              SizedBox(width: 6.rw),
              CommonText(
                AppString.kNotes,
                fontSize: 13.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ],
          ),
          SizedBox(height: 8.rh),
          CommonText(
            notes,
            fontSize: 13.rf,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _InfoEntry {
  final String label;
  final String value;
  const _InfoEntry(this.label, this.value);
}
