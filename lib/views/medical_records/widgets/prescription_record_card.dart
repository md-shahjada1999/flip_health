import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/prescription_record_model.dart';

class PrescriptionRecordCard extends StatefulWidget {
  final PrescriptionRecordModel record;
  final VoidCallback onTap;
  final int index;

  const PrescriptionRecordCard({
    super.key,
    required this.record,
    required this.onTap,
    required this.index,
  });

  @override
  State<PrescriptionRecordCard> createState() =>
      _PrescriptionRecordCardState();
}

class _PrescriptionRecordCardState extends State<PrescriptionRecordCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final delay = (widget.index * 0.08).clamp(0.0, 0.5);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(curved);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curved);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final medicines = r.allMedicines;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.rh),
            padding: EdgeInsets.all(14.rs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.rs),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _PrescriptionIcon(isChronic: r.isChronic),
                SizedBox(width: 12.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              'Dr. ${r.doctorName}',
                              fontSize: 13.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.rw),
                          _StatusChip(label: r.statusLabel),
                        ],
                      ),
                      if (r.doctorSpeciality.isNotEmpty) ...[
                        SizedBox(height: 2.rh),
                        CommonText(
                          r.doctorSpeciality,
                          fontSize: 11.rf,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                      SizedBox(height: 6.rh),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13.rs,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.rw),
                          CommonText(
                            r.createdAtDate,
                            fontSize: 11.rf,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.rh),
                      Row(
                        children: [
                          _MedicineCountBadge(count: r.totalMedicines),
                          if (r.isChronic) ...[
                            SizedBox(width: 6.rw),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.rw,
                                vertical: 2.rh,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.rs),
                              ),
                              child: CommonText(
                                'Chronic',
                                fontSize: 9.rf,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (medicines.isNotEmpty)
                            Flexible(
                              child: CommonText(
                                medicines.first.name,
                                fontSize: 10.rf,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.rw),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.rs,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionIcon extends StatelessWidget {
  final bool isChronic;
  const _PrescriptionIcon({required this.isChronic});

  @override
  Widget build(BuildContext context) {
    final colors = isChronic
        ? [AppColors.warning, const Color(0xffFFB300)]
        : [const Color(0xff26A69A), const Color(0xff80CBC4)];

    return Container(
      width: 46.rs,
      height: 46.rs,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.rs),
      ),
      child: Icon(
        Icons.medication_rounded,
        color: Colors.white,
        size: 22.rs,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Active' => AppColors.success,
      'Inactive' => AppColors.textSecondary,
      'Cancelled' => AppColors.error,
      _ => AppColors.textSecondary,
    };
    final bgColor = switch (label) {
      'Active' => AppColors.successLight,
      'Inactive' => AppColors.backgroundSecondary,
      'Cancelled' => AppColors.errorLight,
      _ => AppColors.backgroundSecondary,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 3.rh),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.rs),
      ),
      child: CommonText(
        label,
        fontSize: 10.rf,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class _MedicineCountBadge extends StatelessWidget {
  final int count;
  const _MedicineCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.rs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medication_liquid_rounded,
            size: 11.rs,
            color: AppColors.primary,
          ),
          SizedBox(width: 3.rw),
          CommonText(
            '$count ${count == 1 ? 'medicine' : 'medicines'}',
            fontSize: 9.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
