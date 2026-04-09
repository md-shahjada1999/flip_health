import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/health_record_model.dart';

class VitalRecordCard extends StatefulWidget {
  final HealthRecordModel record;
  final int index;

  const VitalRecordCard({
    super.key,
    required this.record,
    required this.index,
  });

  @override
  State<VitalRecordCard> createState() => _VitalRecordCardState();
}

class _VitalRecordCardState extends State<VitalRecordCard>
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
    final vitalColor = _vitalColor(r.type);

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
              _VitalIcon(type: r.type, color: vitalColor),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CommonText(
                            r.vitalTypeLabel,
                            fontSize: 13.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.rw, vertical: 4.rh),
                          decoration: BoxDecoration(
                            color: vitalColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.rs),
                          ),
                          child: CommonText(
                            r.displayValue,
                            fontSize: 12.rf,
                            fontWeight: FontWeight.w700,
                            color: vitalColor,
                          ),
                        ),
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
                    if (r.source != null && r.source!.isNotEmpty) ...[
                      SizedBox(height: 4.rh),
                      CommonText(
                        'Source: ${r.source}',
                        fontSize: 10.rf,
                        color: AppColors.textSecondary,
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

  Color _vitalColor(String? type) => switch (type?.toUpperCase()) {
        'HR' => AppColors.error,
        'O2' => AppColors.info,
        'TEMP' => AppColors.warning,
        'BP' => const Color(0xff7C4DFF),
        'RR' => AppColors.success,
        'SUGAR' => AppColors.primary,
        _ => AppColors.textSecondary,
      };
}

class _VitalIcon extends StatelessWidget {
  final String? type;
  final Color color;
  const _VitalIcon({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type?.toUpperCase()) {
      'HR' => Icons.favorite_rounded,
      'O2' => Icons.air_rounded,
      'TEMP' => Icons.thermostat_rounded,
      'BP' => Icons.speed_rounded,
      'RR' => Icons.waves_rounded,
      'SUGAR' => Icons.bloodtype_rounded,
      _ => Icons.monitor_heart_rounded,
    };

    return Container(
      width: 46.rs,
      height: 46.rs,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.rs),
      ),
      child: Icon(icon, color: Colors.white, size: 22.rs),
    );
  }
}
