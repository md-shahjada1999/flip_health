import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/medical%20records%20models/prescription_record_model.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final PrescriptionRecordModel record;
  const PrescriptionDetailScreen({super.key, required this.record});

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;

    return SafeScreenWrapper(
      appBar: CommonAppBar.build(title: 'Prescription Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
        child: Column(
          children: [
            _AnimatedSection(
              animation: _animController,
              start: 0.0,
              end: 0.2,
              child: _StatusBanner(record: r),
            ),
            SizedBox(height: 14.rh),
            _AnimatedSection(
              animation: _animController,
              start: 0.08,
              end: 0.35,
              child: _DoctorCard(record: r),
            ),
            SizedBox(height: 12.rh),
            _AnimatedSection(
              animation: _animController,
              start: 0.18,
              end: 0.5,
              child: _MedicinesCard(
                title: 'Medicines',
                medicines: r.otherMedicines,
              ),
            ),
            if (r.chronicMedicines.isNotEmpty) ...[
              SizedBox(height: 12.rh),
              _AnimatedSection(
                animation: _animController,
                start: 0.28,
                end: 0.6,
                child: _MedicinesCard(
                  title: 'Chronic Medicines',
                  medicines: r.chronicMedicines,
                  isChronic: true,
                ),
              ),
            ],
            if (r.notes.isNotEmpty) ...[
              SizedBox(height: 12.rh),
              _AnimatedSection(
                animation: _animController,
                start: 0.38,
                end: 0.7,
                child: _InfoCard(
                  title: 'Doctor Notes',
                  child: CommonText(
                    r.notes,
                    fontSize: 13.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            if (_hasAppointmentInfo(r)) ...[
              SizedBox(height: 12.rh),
              _AnimatedSection(
                animation: _animController,
                start: 0.48,
                end: 0.8,
                child: _AppointmentInfoCard(record: r),
              ),
            ],
            if (r.recommendation != null && r.recommendation!.trim().isNotEmpty) ...[
              SizedBox(height: 12.rh),
              _AnimatedSection(
                animation: _animController,
                start: 0.58,
                end: 0.9,
                child: _InfoCard(
                  title: 'Recommendation',
                  child: CommonText(
                    r.recommendation!.trim(),
                    fontSize: 12.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            SizedBox(height: 24.rh),
          ],
        ),
      ),
    );
  }

  bool _hasAppointmentInfo(PrescriptionRecordModel r) {
    return (r.purpose != null && r.purpose!.trim().isNotEmpty) ||
        (r.diagnosis != null && r.diagnosis!.trim().isNotEmpty);
  }
}

// ──────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final PrescriptionRecordModel record;
  const _StatusBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    final label = record.statusLabel;
    final isActive = label == 'Active';
    final isCancelled = label == 'Cancelled';

    final color = isActive
        ? AppColors.success
        : isCancelled
            ? AppColors.error
            : AppColors.textSecondary;
    final bgColor = isActive
        ? AppColors.successLight
        : isCancelled
            ? AppColors.errorLight
            : AppColors.backgroundSecondary;
    final icon = isActive
        ? Icons.check_circle_rounded
        : isCancelled
            ? Icons.cancel_rounded
            : Icons.info_rounded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.rs),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28.rs),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  label,
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  '${record.totalMedicines} ${record.totalMedicines == 1 ? 'medicine' : 'medicines'} prescribed',
                  fontSize: 12.rf,
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
          if (record.isChronic)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.rs),
              ),
              child: CommonText(
                'Chronic',
                fontSize: 10.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final PrescriptionRecordModel record;
  const _DoctorCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final initial = record.doctorName.isNotEmpty
        ? record.doctorName[0].toUpperCase()
        : 'D';

    return _InfoCard(
      title: 'Prescribed By',
      child: Row(
        children: [
          Container(
            width: 50.rs,
            height: 50.rs,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff26A69A), Color(0xff80CBC4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.rs),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 20.rf,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Dr. ${record.doctorName}',
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                if (record.doctorSpeciality.isNotEmpty) ...[
                  SizedBox(height: 2.rh),
                  CommonText(
                    record.doctorSpeciality,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ],
                SizedBox(height: 4.rh),
                Row(
                  children: [
                    if (record.doctorExperience != null) ...[
                      Icon(Icons.work_outline_rounded,
                          size: 13.rs, color: AppColors.textTertiary),
                      SizedBox(width: 3.rw),
                      CommonText(
                        '${record.doctorExperience} yrs',
                        fontSize: 11.rf,
                        color: AppColors.textTertiary,
                      ),
                    ],
                    if (record.doctorRating != null) ...[
                      SizedBox(width: 10.rw),
                      Icon(Icons.star_rounded,
                          size: 14.rs, color: AppColors.warning),
                      SizedBox(width: 2.rw),
                      CommonText(
                        record.doctorRating!.toStringAsFixed(1),
                        fontSize: 11.rf,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _MedicinesCard extends StatelessWidget {
  final String title;
  final List<MedicineItem> medicines;
  final bool isChronic;

  const _MedicinesCard({
    required this.title,
    required this.medicines,
    this.isChronic = false,
  });

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      return _InfoCard(
        title: title,
        child: CommonText(
          'No medicines listed',
          fontSize: 12.rf,
          color: AppColors.textSecondary,
        ),
      );
    }

    return _InfoCard(
      title: title,
      child: Column(
        children: List.generate(medicines.length, (i) {
          final med = medicines[i];
          final isLast = i == medicines.length - 1;
          return _MedicineTile(
            medicine: med,
            index: i,
            isChronic: isChronic,
            isLast: isLast,
          );
        }),
      ),
    );
  }
}

class _MedicineTile extends StatelessWidget {
  final MedicineItem medicine;
  final int index;
  final bool isChronic;
  final bool isLast;

  const _MedicineTile({
    required this.medicine,
    required this.index,
    required this.isChronic,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final typeIcon = switch (medicine.type.toLowerCase()) {
      'tablet' => Icons.medication_rounded,
      'injection' => Icons.vaccines_rounded,
      'syrup' => Icons.local_drink_rounded,
      'drops' => Icons.water_drop_rounded,
      _ => Icons.medication_rounded,
    };

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10.rh),
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        color: isChronic
            ? AppColors.warning.withValues(alpha: 0.06)
            : AppColors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10.rs),
        border: isChronic
            ? Border.all(color: AppColors.warning.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.rs,
                height: 34.rs,
                decoration: BoxDecoration(
                  color: isChronic
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.rs),
                ),
                child: Icon(
                  typeIcon,
                  size: 18.rs,
                  color: isChronic ? AppColors.warning : AppColors.primary,
                ),
              ),
              SizedBox(width: 10.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      medicine.name,
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 2.rh),
                    Row(
                      children: [
                        CommonText(
                          medicine.type,
                          fontSize: 10.rf,
                          color: AppColors.textSecondary,
                        ),
                        if (medicine.durationText.isNotEmpty)
                          CommonText(
                            '  •  ${medicine.durationText}',
                            fontSize: 10.rf,
                            color: AppColors.textTertiary,
                          ),
                        if (medicine.weeklyText.isNotEmpty)
                          CommonText(
                            '  •  ${medicine.weeklyText}',
                            fontSize: 10.rf,
                            color: AppColors.textTertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (medicine.timings.isNotEmpty) ...[
            SizedBox(height: 8.rh),
            Wrap(
              spacing: 6.rw,
              runSpacing: 4.rh,
              children: medicine.timings.map((t) {
                final isMorning = t.toLowerCase().contains('breakfast');
                final isAfternoon = t.toLowerCase().contains('lunch');
                final isNight = t.toLowerCase().contains('dinner');
                final icon = isMorning
                    ? Icons.wb_sunny_rounded
                    : isAfternoon
                        ? Icons.wb_cloudy_rounded
                        : isNight
                            ? Icons.nightlight_round
                            : Icons.schedule_rounded;
                final chipColor = isMorning
                    ? AppColors.warning
                    : isAfternoon
                        ? AppColors.info
                        : isNight
                            ? const Color(0xff7C4DFF)
                            : AppColors.textSecondary;

                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.rw, vertical: 4.rh),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.rs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 12.rs, color: chipColor),
                      SizedBox(width: 4.rw),
                      CommonText(
                        t,
                        fontSize: 9.rf,
                        fontWeight: FontWeight.w500,
                        color: chipColor,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _AppointmentInfoCard extends StatelessWidget {
  final PrescriptionRecordModel record;
  const _AppointmentInfoCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Appointment Info',
      child: Column(
        children: [
          if (record.purpose != null && record.purpose!.trim().isNotEmpty)
            _DetailRow(label: 'Purpose', value: record.purpose!.trim()),
          if (record.diagnosis != null && record.diagnosis!.trim().isNotEmpty)
            _DetailRow(label: 'Diagnosis', value: record.diagnosis!.trim()),
          _DetailRow(label: 'Date', value: record.createdAtDate, isLast: true),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Shared building blocks
// ──────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          Divider(height: 20.rh, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.rw,
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
              fontSize: 12.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final Animation<double> animation;
  final double start;
  final double end;
  final Widget child;
  const _AnimatedSection({
    required this.animation,
    required this.start,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
