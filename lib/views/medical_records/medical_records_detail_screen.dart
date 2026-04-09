import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/medical%20records%20models/consultation_record_model.dart';

class MedicalRecordsDetailScreen extends StatefulWidget {
  final ConsultationRecordModel record;
  const MedicalRecordsDetailScreen({super.key, required this.record});

  @override
  State<MedicalRecordsDetailScreen> createState() =>
      _MedicalRecordsDetailScreenState();
}

class _MedicalRecordsDetailScreenState
    extends State<MedicalRecordsDetailScreen>
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
      appBar: CommonAppBar.build(title: 'Consultation Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
        child: Column(
          children: [
            _AnimatedSection(
              animation: _animController,
              start: 0.0,
              end: 0.25,
              child: _StatusBanner(record: r),
            ),
            SizedBox(height: 14.rh),
            _AnimatedSection(
              animation: _animController,
              start: 0.1,
              end: 0.4,
              child: _DoctorCard(record: r),
            ),
            SizedBox(height: 12.rh),
            _AnimatedSection(
              animation: _animController,
              start: 0.25,
              end: 0.6,
              child: _AppointmentCard(record: r),
            ),
            if (r.purpose != null && r.purpose!.isNotEmpty) ...[
              SizedBox(height: 12.rh),
              _AnimatedSection(
                animation: _animController,
                start: 0.4,
                end: 0.75,
                child: _InfoCard(
                  title: 'Purpose',
                  child: CommonText(
                    r.purpose!,
                    fontSize: 13.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            SizedBox(height: 12.rh),
            _AnimatedSection(
              animation: _animController,
              start: 0.5,
              end: 0.85,
              child: _AdditionalInfoCard(record: r),
            ),
            SizedBox(height: 24.rh),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final ConsultationRecordModel record;
  const _StatusBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    final label = record.statusLabel;
    final isCompleted = label == 'Completed';
    final isUpcoming = label == 'Upcoming';
    final isCancelled = label == 'Cancelled';

    final color = isCompleted
        ? AppColors.success
        : isUpcoming
            ? AppColors.info
            : isCancelled
                ? AppColors.error
                : AppColors.warning;
    final bgColor = isCompleted
        ? AppColors.successLight
        : isUpcoming
            ? AppColors.infoLight
            : isCancelled
                ? AppColors.errorLight
                : AppColors.warningLight;
    final icon = isCompleted
        ? Icons.check_circle_rounded
        : isUpcoming
            ? Icons.schedule_rounded
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
                  record.isOnline
                      ? 'Online Consultation'
                      : 'In-Person Consultation',
                  fontSize: 12.rf,
                  color: color,
                  fontWeight: FontWeight.w400,
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

class _DoctorCard extends StatelessWidget {
  final ConsultationRecordModel record;
  const _DoctorCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final initial = record.doctorName.isNotEmpty
        ? record.doctorName[0].toUpperCase()
        : 'D';

    return _InfoCard(
      title: 'Doctor',
      child: Row(
        children: [
          Container(
            width: 50.rs,
            height: 50.rs,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.infoGradient,
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
                  record.doctorName,
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
                if (record.specialties.isNotEmpty) ...[
                  SizedBox(height: 2.rh),
                  CommonText(
                    record.specialties.join(', '),
                    fontSize: 11.rf,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final ConsultationRecordModel record;
  const _AppointmentCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Appointment Details',
      child: Column(
        children: [
          _DetailRow(label: 'Date', value: record.displayDate),
          _DetailRow(label: 'Time', value: record.displayTime),
          _DetailRow(
            label: 'Type',
            value: record.isOnline ? 'Online' : 'In-Person',
          ),
          if (record.source.isNotEmpty)
            _DetailRow(label: 'Source', value: record.source),
          if (record.language != null && record.language!.isNotEmpty)
            _DetailRow(label: 'Language', value: record.language!),
          if (record.invoiceId != null && record.invoiceId!.isNotEmpty)
            _DetailRow(
              label: 'Invoice ID',
              value: record.invoiceId!,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _AdditionalInfoCard extends StatelessWidget {
  final ConsultationRecordModel record;
  const _AdditionalInfoCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Session Info',
      child: Column(
        children: [
          _DetailRow(
            label: 'Patient Joined',
            value: record.isPatientJoined == 1 ? 'Yes' : 'No',
          ),
          _DetailRow(
            label: 'Doctor Joined',
            value: record.isDocJoined == 1 ? 'Yes' : 'No',
          ),
          if (record.callEndedBy != null && record.callEndedBy!.isNotEmpty)
            _DetailRow(
              label: 'Call Ended By',
              value: record.callEndedBy!,
              isLast: true,
            ),
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
