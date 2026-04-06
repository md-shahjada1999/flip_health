import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';

class HelpTicketDetailScreen extends StatefulWidget {
  const HelpTicketDetailScreen({super.key});

  @override
  State<HelpTicketDetailScreen> createState() => _HelpTicketDetailScreenState();
}

class _HelpTicketDetailScreenState extends State<HelpTicketDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HelpController>();
    final ticket = controller.selectedTicket.value;

    if (ticket == null) {
      return SafeScreenWrapper(
        appBar: CommonAppBar.build(title: AppString.kTicketDetails),
        body: Center(
          child: CommonText(
            AppString.kNoTicketsYet,
            fontSize: 14.rf,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final isOpen = ticket.status == 'open';
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt);

    return SafeScreenWrapper(
      appBar: CommonAppBar.build(title: AppString.kTicketDetails),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
        child: Column(
          children: [
            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.0,
              intervalEnd: 0.25,
              child: _StatusBanner(isOpen: isOpen),
            ),
            SizedBox(height: 16.rh),

            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.15,
              intervalEnd: 0.45,
              child: _SectionCard(
                title: AppString.kTicketDetails,
                child: Column(
                  children: [
                    _InfoRow(
                      label: AppString.kTicketId,
                      value: ticket.id,
                    ),
                    _InfoRow(
                      label: AppString.kOrderStatus,
                      value: isOpen ? AppString.kOpenTickets : AppString.kClosedTickets,
                      valueColor: isOpen ? AppColors.success : AppColors.textSecondary,
                    ),
                    _InfoRow(
                      label: AppString.kOrderDate,
                      value: dateStr,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.rh),

            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.3,
              intervalEnd: 0.6,
              child: _SectionCard(
                title: AppString.kIssueDescription,
                child: CommonText(
                  ticket.message,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 12.rh),

            _AnimatedSection(
              animation: _animController,
              intervalStart: 0.45,
              intervalEnd: 0.75,
              child: _FeedbackSection(ticket: ticket, controller: controller),
            ),
            SizedBox(height: 24.rh),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool isOpen;
  const _StatusBanner({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.infoLight : AppColors.successLight,
        borderRadius: BorderRadius.circular(14.rs),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? Icons.schedule_rounded : Icons.check_circle_rounded,
            color: isOpen ? AppColors.info : AppColors.success,
            size: 28.rs,
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  isOpen ? 'Ticket Open' : 'Ticket Closed',
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: isOpen ? AppColors.info : AppColors.success,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  isOpen
                      ? AppString.kTeamGetBack
                      : 'This ticket has been resolved',
                  fontSize: 12.rf,
                  color: isOpen ? AppColors.info : AppColors.success,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final SupportTicket ticket;
  final HelpController controller;

  const _FeedbackSection({required this.ticket, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isOpen = ticket.status == 'open';

    if (isOpen) {
      return _SectionCard(
        title: AppString.kGiveFeedback,
        child: CommonText(
          'Feedback can be submitted after the ticket is resolved.',
          fontSize: 12.rf,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    if (ticket.feedback != null) {
      return _SectionCard(
        title: AppString.kGiveFeedback,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (i) {
                  return Icon(
                    i < (ticket.rating ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 22.rs,
                    color: i < (ticket.rating ?? 0)
                        ? AppColors.warning
                        : AppColors.iconDisabled,
                  );
                }),
                SizedBox(width: 8.rw),
                CommonText(
                  '${ticket.rating ?? 0}/5',
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            SizedBox(height: 8.rh),
            CommonText(
              ticket.feedback!,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      );
    }

    final selectedRating = 0.obs;
    return _SectionCard(
      title: AppString.kRateExperience,
      child: Column(
        children: [
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starIndex = i + 1;
                  return GestureDetector(
                    onTap: () => selectedRating.value = starIndex,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.rw),
                      child: AnimatedScale(
                        scale: starIndex <= selectedRating.value ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          starIndex <= selectedRating.value
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 32.rs,
                          color: starIndex <= selectedRating.value
                              ? AppColors.warning
                              : AppColors.iconDisabled,
                        ),
                      ),
                    ),
                  );
                }),
              )),
          SizedBox(height: 4.rh),
          ActionButton(
            text: AppString.kSubmit,
            icon: Icons.check_rounded,
            padding: EdgeInsets.symmetric(vertical: 12.rh),
            onPressed: () {
              if (selectedRating.value == 0) {
                Get.snackbar(
                  'Required',
                  'Please select a rating',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
                return;
              }
              controller.submitFeedback(ticket.id, selectedRating.value, null);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          Divider(height: 20.rh, color: AppColors.divider),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.rw,
            child: CommonText(
              label,
              fontSize: 12.rf,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: CommonText(
              value,
              fontSize: 12.rf,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final Animation<double> animation;
  final double intervalStart;
  final double intervalEnd;
  final Widget child;

  const _AnimatedSection({
    required this.animation,
    required this.intervalStart,
    required this.intervalEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
