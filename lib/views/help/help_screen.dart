import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';
import 'package:flip_health/views/help/widgets/quick_action_card.dart';
import 'package:flip_health/views/help/widgets/ticket_card.dart';
import 'package:flip_health/views/help/help_ticket_detail_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HelpController>();

    return SafeScreenWrapper(
      appBar: CommonAppBar.build(
        title: AppString.kHelpSupport,
        showBackButton: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRaiseTicketSheet(context, controller),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add_rounded, color: Colors.white, size: 20.rs),
        label: CommonText(
          AppString.kRaiseTicket,
          fontSize: 13.rf,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.rw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.rh),
            _QuickActionsGrid(),
            SizedBox(height: 24.rh),
            CommonText(
              AppString.kYourTickets,
              fontSize: 16.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 12.rh),
            _SegmentedToggle(controller: controller),
            SizedBox(height: 14.rh),
            _TicketsList(controller: controller),
            SizedBox(height: 80.rh),
          ],
        ),
      ),
    );
  }

  void _showRaiseTicketSheet(BuildContext context, HelpController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20.rw,
          right: 20.rw,
          top: 16.rh,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.rh,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.rw,
                  height: 4.rh,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.rs),
                  ),
                ),
              ),
              SizedBox(height: 16.rh),
              CommonText(
                AppString.kOpenATicket,
                fontSize: 18.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 4.rh),
              CommonText(
                AppString.kTeamGetBack,
                fontSize: 12.rf,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 20.rh),
              CustomTextField(
                label: AppString.kDescribeYourIssue,
                hint: AppString.kIssueHint,
                controller: controller.issueController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 8.rh),
              Obx(() => ActionButton(
                    text: AppString.kSubmit,
                    isLoading: controller.isSubmitting.value,
                    icon: Icons.send_rounded,
                    onPressed: () {
                      final text = controller.issueController.text;
                      if (text.trim().isEmpty) {
                        Get.snackbar(
                          'Required',
                          'Please describe your issue',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                        return;
                      }
                      controller.createTicket(text);
                    },
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(AppString.kIconFAQ, AppString.kFAQ, AppString.kFAQSubtitle),
      _QuickAction(AppString.kIconSupport, AppString.kContactSupport, AppString.kContactSupportSubtitle),
      _QuickAction(AppString.kIconTC, AppString.kTC, AppString.kTCSubtitle),
      _QuickAction(AppString.kIconPrivacyPolicies, AppString.kPrivacyPolicies, AppString.kPrivacyPoliciesSubtitle),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.rh,
        crossAxisSpacing: 10.rw,
        childAspectRatio: 1.3,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) {
        final a = actions[i];
        return QuickActionCard(
          iconPath: a.icon,
          title: a.title,
          subtitle: a.subtitle,
          index: i,
          onTap: () {
            Get.snackbar(
              a.title,
              'Coming soon',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          },
        );
      },
    );
  }
}

class _QuickAction {
  final String icon;
  final String title;
  final String subtitle;
  const _QuickAction(this.icon, this.title, this.subtitle);
}

class _SegmentedToggle extends StatelessWidget {
  final HelpController controller;
  const _SegmentedToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOpen = controller.isOpenSelected.value;
      return Container(
        padding: EdgeInsets.all(3.rs),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12.rs),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: '${AppString.kOpenTickets} (${controller.openTickets.length})',
                isSelected: isOpen,
                onTap: () => controller.toggleFilter(true),
              ),
            ),
            Expanded(
              child: _ToggleChip(
                label: '${AppString.kClosedTickets} (${controller.closedTickets.length})',
                isSelected: !isOpen,
                onTap: () => controller.toggleFilter(false),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 10.rh),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10.rs),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: CommonText(
            label,
            fontSize: 13.rf,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TicketsList extends StatelessWidget {
  final HelpController controller;
  const _TicketsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOpen = controller.isOpenSelected.value;
      final tickets = controller.currentTickets;

      if (tickets.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 40.rh),
          child: Column(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 52.rs,
                color: AppColors.iconDisabled,
              ),
              SizedBox(height: 12.rh),
              CommonText(
                isOpen ? AppString.kNoActiveTicket : AppString.kNoClosedTicket,
                fontSize: 14.rf,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        key: ValueKey(isOpen),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tickets.length,
        itemBuilder: (_, i) {
          final ticket = tickets[i];
          return TicketCard(
            ticket: ticket,
            index: i,
            onTap: () {
              controller.selectTicket(ticket);
              Get.to(() => const HelpTicketDetailScreen());
            },
            onFeedbackTap: ticket.status == 'closed' && ticket.feedback == null
                ? () => _showFeedbackSheet(context, controller, ticket)
                : null,
          );
        },
      );
    });
  }

  void _showFeedbackSheet(
    BuildContext context,
    HelpController controller,
    SupportTicket ticket,
  ) {
    final selectedRating = 0.obs;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20.rw,
          right: 20.rw,
          top: 16.rh,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.rh,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.rw,
                height: 4.rh,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.rs),
                ),
              ),
            ),
            SizedBox(height: 16.rh),
            CommonText(
              AppString.kRateExperience,
              fontSize: 18.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 20.rh),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    return GestureDetector(
                      onTap: () => selectedRating.value = starIndex,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.rw),
                        child: Icon(
                          starIndex <= selectedRating.value
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 36.rs,
                          color: starIndex <= selectedRating.value
                              ? AppColors.warning
                              : AppColors.iconDisabled,
                        ),
                      ),
                    );
                  }),
                )),
            SizedBox(height: 8.rh),
            ActionButton(
              text: AppString.kSubmit,
              icon: Icons.check_rounded,
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
                Get.back();
                controller.submitFeedback(ticket.id, selectedRating.value, null);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
