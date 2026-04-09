import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/medical%20records%20models/service_request_model.dart';

class ServiceRequestCard extends StatefulWidget {
  final ServiceRequestModel record;
  final int index;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;

  const ServiceRequestCard({
    super.key,
    required this.record,
    required this.index,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
  });

  @override
  State<ServiceRequestCard> createState() => _ServiceRequestCardState();
}

class _ServiceRequestCardState extends State<ServiceRequestCard>
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
    final statusColor = _statusColor(r.statusLabel);

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
                    colors: [widget.gradientStart, widget.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.rs),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22.rs),
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
                            r.serviceName.isNotEmpty
                                ? r.serviceName
                                : r.typeLabel,
                            fontSize: 13.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.rw),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.rw,
                            vertical: 3.rh,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.rs),
                          ),
                          child: CommonText(
                            r.statusLabel,
                            fontSize: 10.rf,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    if (r.serviceArea != null &&
                        r.serviceArea!.isNotEmpty) ...[
                      SizedBox(height: 4.rh),
                      CommonText(
                        r.serviceArea!,
                        fontSize: 11.rf,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 6.rh),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 13.rs, color: AppColors.textSecondary),
                        SizedBox(width: 4.rw),
                        Expanded(
                          child: CommonText(
                            r.displayBookingTime.isNotEmpty
                                ? r.displayBookingTime
                                : r.displayDate,
                            fontSize: 11.rf,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.rh),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.rw,
                            vertical: 2.rh,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.rs),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 11.rs,
                                color: AppColors.info,
                              ),
                              SizedBox(width: 3.rw),
                              CommonText(
                                r.visitTypeLabel,
                                fontSize: 9.rf,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ],
                          ),
                        ),
                        if (r.isAssigned) ...[
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_rounded,
                                    size: 11.rs, color: AppColors.success),
                                SizedBox(width: 3.rw),
                                CommonText(
                                  'Assigned',
                                  fontSize: 9.rf,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Color _statusColor(String label) => switch (label) {
        'Active' => AppColors.success,
        'Completed' => AppColors.info,
        'Pending' => AppColors.warning,
        'Cancelled' => AppColors.error,
        _ => AppColors.textSecondary,
      };
}
