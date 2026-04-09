import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/health_record_model.dart';

class MedicineRecordCard extends StatefulWidget {
  final HealthRecordModel record;
  final int index;

  const MedicineRecordCard({
    super.key,
    required this.record,
    required this.index,
  });

  @override
  State<MedicineRecordCard> createState() => _MedicineRecordCardState();
}

class _MedicineRecordCardState extends State<MedicineRecordCard>
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

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
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
              Container(
                width: 46.rs,
                height: 46.rs,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: r.isChronic
                        ? [AppColors.warning, const Color(0xffFFB300)]
                        : [const Color(0xff26A69A), const Color(0xff80CBC4)],
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
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CommonText(
                            r.medicineName,
                            fontSize: 14.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (r.isChronic)
                          Container(
                            margin: EdgeInsets.only(left: 6.rw),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.rw,
                              vertical: 3.rh,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20.rs),
                            ),
                            child: CommonText(
                              'Chronic',
                              fontSize: 10.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                    if (r.doseDisplay.isNotEmpty) ...[
                      SizedBox(height: 4.rh),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.rw,
                              vertical: 3.rh,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.rs),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.science_rounded,
                                    size: 12.rs, color: AppColors.primary),
                                SizedBox(width: 4.rw),
                                CommonText(
                                  'Dose: ${r.doseDisplay}',
                                  fontSize: 10.rf,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 4.rh),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13.rs,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.rw),
                        CommonText(
                          r.displayDateTime,
                          fontSize: 11.rf,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w400,
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
    );
  }
}
