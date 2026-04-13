import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/routes/app_routes.dart';

/// Shown after Razorpay verify or direct booking confirmation (online & offline).
class ConsultationPaymentSuccessScreen extends StatelessWidget {
  const ConsultationPaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final m = args is Map
        ? Map<String, dynamic>.from(args)
        : <String, dynamic>{};

    final schedule = m['schedule']?.toString() ?? '—';
    final visitType = m['visit_type']?.toString() ?? '—';
    final doctor = m['doctor_name']?.toString();
    final specialty = m['specialty']?.toString();
    final hospital = m['hospital_name']?.toString();
    final address = m['address']?.toString();
    final purpose = m['purpose']?.toString();
    final appointmentId = m['appointment_id']?.toString();

    final rows = <MapEntry<String, String>>[
      MapEntry(AppString.kSchedule, schedule),
      MapEntry('Visit type', visitType),
      if (appointmentId != null && appointmentId.isNotEmpty)
        MapEntry('Appointment ID', '#$appointmentId'),
      if (doctor != null && doctor.isNotEmpty)
        MapEntry('Doctor', doctor),
      if (specialty != null && specialty.isNotEmpty)
        MapEntry('Specialty', specialty),
      if (hospital != null && hospital.isNotEmpty)
        MapEntry('Hospital / clinic', hospital),
      if (address != null && address.isNotEmpty)
        MapEntry('Location', address),
      if (purpose != null && purpose.isNotEmpty)
        MapEntry('Purpose', purpose),
    ];

    return SafeScreenWrapper(
      bottomSafe: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.rw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 24.rh),
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 88.rs,
                    ),
                    SizedBox(height: 24.rh),
                    CommonText(
                      'Payment successful',
                      fontSize: 22.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.rh),
                    CommonText(
                      'Your appointment is confirmed.',
                      fontSize: 15.rf,
                      height: 1.45,
                      color: AppColors.textTertiary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 28.rh),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.rs),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14.rs),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            'Appointment details',
                            fontSize: 14.rf,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          Divider(height: 20.rh, color: AppColors.divider),
                          for (var i = 0; i < rows.length; i++)
                            _SummaryRow(
                              label: rows[i].key,
                              value: rows[i].value,
                              isLast: i == rows.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeBottomPadding(
              child: ActionButton(
                text: AppString.kDone,
                backgroundColor: AppColors.textPrimary,
                icon: Icons.done_rounded,
                onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128.rw,
            child: CommonText(
              label,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: CommonText(
              value,
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
