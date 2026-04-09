import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/consultation_record_model.dart';

class ConsultationRecordCard extends StatefulWidget {
  final ConsultationRecordModel record;
  final VoidCallback onTap;
  final int index;

  const ConsultationRecordCard({
    super.key,
    required this.record,
    required this.onTap,
    required this.index,
  });

  @override
  State<ConsultationRecordCard> createState() => _ConsultationRecordCardState();
}

class _ConsultationRecordCardState extends State<ConsultationRecordCard>
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
                _DoctorAvatar(name: r.doctorName),
                SizedBox(width: 12.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              r.doctorName,
                              fontSize: 14.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _StatusChip(label: r.statusLabel),
                        ],
                      ),
                      SizedBox(height: 3.rh),
                      if (r.doctorSpeciality.isNotEmpty)
                        CommonText(
                          r.doctorSpeciality,
                          fontSize: 12.rf,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                            '${r.displayDate}  •  ${r.displayTime}',
                            fontSize: 11.rf,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                          const Spacer(),
                          _CommunicationBadge(isOnline: r.isOnline),
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

class _DoctorAvatar extends StatelessWidget {
  final String name;
  const _DoctorAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    final colors = _gradientForName(name);

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
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 18.rf,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  List<Color> _gradientForName(String name) {
    final gradients = [
      AppColors.primaryGradient,
      AppColors.successGradient,
      AppColors.infoGradient,
      [const Color(0xff7C4DFF), const Color(0xffB388FF)],
      [const Color(0xffFF6D00), const Color(0xffFFAB40)],
    ];
    final index = name.hashCode.abs() % gradients.length;
    return gradients[index];
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Completed' => AppColors.success,
      'Upcoming' => AppColors.info,
      'Pending' => AppColors.warning,
      'Missed' => AppColors.textSecondary,
      'Cancelled' => AppColors.error,
      _ => AppColors.textSecondary,
    };
    final bgColor = switch (label) {
      'Completed' => AppColors.successLight,
      'Upcoming' => AppColors.infoLight,
      'Pending' => AppColors.warningLight,
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

class _CommunicationBadge extends StatelessWidget {
  final bool isOnline;
  const _CommunicationBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.info.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.rs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.videocam_rounded : Icons.local_hospital_rounded,
            size: 11.rs,
            color: isOnline ? AppColors.info : AppColors.success,
          ),
          SizedBox(width: 3.rw),
          CommonText(
            isOnline ? 'Online' : 'In-Person',
            fontSize: 9.rf,
            fontWeight: FontWeight.w600,
            color: isOnline ? AppColors.info : AppColors.success,
          ),
        ],
      ),
    );
  }
}
