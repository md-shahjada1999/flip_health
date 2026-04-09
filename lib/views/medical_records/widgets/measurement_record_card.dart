import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/health_record_model.dart';

class MeasurementRecordCard extends StatefulWidget {
  final HealthRecordModel record;
  final int index;

  const MeasurementRecordCard({
    super.key,
    required this.record,
    required this.index,
  });

  @override
  State<MeasurementRecordCard> createState() => _MeasurementRecordCardState();
}

class _MeasurementRecordCardState extends State<MeasurementRecordCard>
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
    final bmiCat = r.bmiCategory;
    final catColor = _bmiCategoryColor(bmiCat);

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
                    colors: [
                      const Color(0xff5C6BC0),
                      const Color(0xff9FA8DA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.rs),
                ),
                child: Icon(
                  Icons.straighten_rounded,
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
                            r.measurementTypeLabel,
                            fontSize: 13.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (bmiCat.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.rw,
                              vertical: 3.rh,
                            ),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.rs),
                            ),
                            child: CommonText(
                              bmiCat,
                              fontSize: 10.rf,
                              fontWeight: FontWeight.w600,
                              color: catColor,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.rh),
                    Row(
                      children: [
                        if (r.heightValue != null) ...[
                          _MetricChip(
                            icon: Icons.height_rounded,
                            label: '${r.heightValue!.toStringAsFixed(1)} cm',
                            color: const Color(0xff5C6BC0),
                          ),
                          SizedBox(width: 6.rw),
                        ],
                        if (r.weightValue != null) ...[
                          _MetricChip(
                            icon: Icons.fitness_center_rounded,
                            label: '${r.weightValue!.toStringAsFixed(1)} kg',
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.rw),
                        ],
                        if (r.bmiValue != null)
                          _MetricChip(
                            icon: Icons.monitor_weight_rounded,
                            label: 'BMI ${r.bmiValue!.toStringAsFixed(1)}',
                            color: catColor,
                          ),
                      ],
                    ),
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

  Color _bmiCategoryColor(String cat) => switch (cat) {
        'Underweight' => AppColors.info,
        'Normal' => AppColors.success,
        'Overweight' => AppColors.warning,
        'Obese' => AppColors.error,
        _ => AppColors.textSecondary,
      };
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 3.rh),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.rs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.rs, color: color),
          SizedBox(width: 3.rw),
          CommonText(
            label,
            fontSize: 10.rf,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}
