import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/health_record_model.dart';

class MoodRecordCard extends StatefulWidget {
  final HealthRecordModel record;
  final int index;

  const MoodRecordCard({
    super.key,
    required this.record,
    required this.index,
  });

  @override
  State<MoodRecordCard> createState() => _MoodRecordCardState();
}

class _MoodRecordCardState extends State<MoodRecordCard>
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
    final moodColor = _moodColor(r.moodValue);

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
                width: 50.rs,
                height: 50.rs,
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.rs),
                ),
                child: Center(
                  child: Text(
                    r.moodEmoji,
                    style: TextStyle(fontSize: 26.rf),
                  ),
                ),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CommonText(
                          r.moodLabel,
                          fontSize: 14.rf,
                          fontWeight: FontWeight.w600,
                          color: moodColor,
                        ),
                        const Spacer(),
                        _MoodIndicator(value: r.moodValue, color: moodColor),
                      ],
                    ),
                    SizedBox(height: 6.rh),
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

  Color _moodColor(int value) => switch (value) {
        1 => AppColors.error,
        2 => const Color(0xffFF7043),
        3 => AppColors.warning,
        4 => const Color(0xff66BB6A),
        5 => AppColors.success,
        _ => AppColors.textSecondary,
      };
}

class _MoodIndicator extends StatelessWidget {
  final int value;
  final Color color;
  const _MoodIndicator({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return Container(
          width: 8.rs,
          height: 8.rs,
          margin: EdgeInsets.only(right: i < 4 ? 3.rw : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : color.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}
