import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';

class TicketCard extends StatefulWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;
  final VoidCallback? onFeedbackTap;
  final int index;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onFeedbackTap,
    required this.index,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard>
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

    final delay = (widget.index * 0.12).clamp(0.0, 0.6);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(curved);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
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
    final ticket = widget.ticket;
    final isOpen = ticket.status == 'open';
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt);
    final showFeedback = !isOpen && ticket.feedback == null;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.rs,
                      height: 8.rs,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOpen ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.rw),
                    Expanded(
                      child: CommonText(
                        ticket.id,
                        fontSize: 11.rf,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.rw,
                        vertical: 3.rh,
                      ),
                      decoration: BoxDecoration(
                        color: isOpen ? AppColors.successLight : AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(20.rs),
                      ),
                      child: CommonText(
                        isOpen ? AppString.kOpenTickets : AppString.kClosedTickets,
                        fontSize: 10.rf,
                        fontWeight: FontWeight.w600,
                        color: isOpen ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.rh),
                CommonText(
                  ticket.message,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.rh),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13.rs,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.rw),
                    Expanded(
                      child: CommonText(
                        dateStr,
                        fontSize: 11.rf,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (showFeedback)
                      GestureDetector(
                        onTap: widget.onFeedbackTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.rw,
                            vertical: 4.rh,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20.rs),
                          ),
                          child: CommonText(
                            AppString.kGiveFeedback,
                            fontSize: 10.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (!isOpen && ticket.feedback != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14.rs,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 2.rw),
                          CommonText(
                            '${ticket.rating ?? 0}/5',
                            fontSize: 11.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
