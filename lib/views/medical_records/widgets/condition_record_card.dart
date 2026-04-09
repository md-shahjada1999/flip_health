import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/condition_record_model.dart';

class ConditionRecordCard extends StatefulWidget {
  final ConditionRecordModel record;
  final int index;

  const ConditionRecordCard({
    super.key,
    required this.record,
    required this.index,
  });

  @override
  State<ConditionRecordCard> createState() => _ConditionRecordCardState();
}

class _ConditionRecordCardState extends State<ConditionRecordCard>
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
                    colors: r.isOngoing
                        ? [AppColors.error, const Color(0xffEF5350)]
                        : [AppColors.success, const Color(0xff66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.rs),
                ),
                child: Icon(
                  Icons.medical_services_rounded,
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
                            r.conditionLabel,
                            fontSize: 14.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.rw,
                            vertical: 3.rh,
                          ),
                          decoration: BoxDecoration(
                            color: r.isOngoing
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.rs),
                          ),
                          child: CommonText(
                            r.isOngoing ? 'Ongoing' : 'Resolved',
                            fontSize: 10.rf,
                            fontWeight: FontWeight.w600,
                            color:
                                r.isOngoing ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.rh),
                    if (r.displaySince.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 13.rs, color: AppColors.textSecondary),
                          SizedBox(width: 4.rw),
                          CommonText(
                            'Since ${r.displaySince}',
                            fontSize: 11.rf,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    if (r.note.isNotEmpty) ...[
                      SizedBox(height: 4.rh),
                      Row(
                        children: [
                          Icon(Icons.note_rounded,
                              size: 13.rs, color: AppColors.textSecondary),
                          SizedBox(width: 4.rw),
                          Expanded(
                            child: CommonText(
                              r.note,
                              fontSize: 11.rf,
                              color: AppColors.textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (r.history.isNotEmpty) ...[
                      SizedBox(height: 4.rh),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.rw, vertical: 2.rh),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.rs),
                        ),
                        child: CommonText(
                          'History: ${r.history}',
                          fontSize: 10.rf,
                          fontWeight: FontWeight.w500,
                          color: AppColors.info,
                        ),
                      ),
                    ],
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
