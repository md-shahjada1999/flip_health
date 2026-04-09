import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/lab_test_record_model.dart';

class LabTestRecordCard extends StatefulWidget {
  final LabTestRecordModel record;
  final VoidCallback onTap;
  final int index;

  const LabTestRecordCard({
    super.key,
    required this.record,
    required this.onTap,
    required this.index,
  });

  @override
  State<LabTestRecordCard> createState() => _LabTestRecordCardState();
}

class _LabTestRecordCardState extends State<LabTestRecordCard>
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
                _LabIcon(category: r.category),
                SizedBox(width: 12.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              r.displayTitle,
                              fontSize: 13.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.rw),
                          _StatusChip(label: r.statusLabel),
                        ],
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
                            r.displayDate,
                            fontSize: 11.rf,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                          if (r.collectionSlotTime != null &&
                              r.collectionSlotTime!.isNotEmpty) ...[
                            CommonText(
                              '  •  ${r.collectionSlotTime}',
                              fontSize: 11.rf,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.rh),
                      Row(
                        children: [
                          _VisitTypeBadge(isHomePickup: r.isHomePickup),
                          if (r.sponsored) ...[
                            SizedBox(width: 6.rw),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.rw,
                                vertical: 2.rh,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.rs),
                              ),
                              child: CommonText(
                                'Sponsored',
                                fontSize: 9.rf,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (r.totalParameters > 0)
                            CommonText(
                              '${r.totalParameters} params',
                              fontSize: 10.rf,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
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

class _LabIcon extends StatelessWidget {
  final String category;
  const _LabIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final isRadiology = category.toLowerCase() == 'radiology';
    final colors = isRadiology
        ? [const Color(0xff7C4DFF), const Color(0xffB388FF)]
        : AppColors.infoGradient;
    final icon = isRadiology
        ? Icons.monitor_heart_rounded
        : Icons.biotech_rounded;

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
      child: Icon(icon, color: Colors.white, size: 22.rs),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Confirmed' => AppColors.success,
      'Active' => AppColors.info,
      'Pending' => AppColors.warning,
      'Collected' => AppColors.info,
      'Reported' => AppColors.success,
      'Cancelled' => AppColors.error,
      _ => AppColors.textSecondary,
    };
    final bgColor = switch (label) {
      'Confirmed' => AppColors.successLight,
      'Active' => AppColors.infoLight,
      'Pending' => AppColors.warningLight,
      'Collected' => AppColors.infoLight,
      'Reported' => AppColors.successLight,
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

class _VisitTypeBadge extends StatelessWidget {
  final bool isHomePickup;
  const _VisitTypeBadge({required this.isHomePickup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
      decoration: BoxDecoration(
        color: isHomePickup
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.rs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHomePickup ? Icons.home_rounded : Icons.location_on_rounded,
            size: 11.rs,
            color: isHomePickup ? AppColors.primary : AppColors.info,
          ),
          SizedBox(width: 3.rw),
          CommonText(
            isHomePickup ? 'Home Pickup' : 'Self Visit',
            fontSize: 9.rf,
            fontWeight: FontWeight.w600,
            color: isHomePickup ? AppColors.primary : AppColors.info,
          ),
        ],
      ),
    );
  }
}
