import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/consultation%20controllers/consultation_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/common/family_member_dropdown.dart';
import 'package:flip_health/views/common/member_selection_screen.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class ConsultationOverviewScreen extends GetView<ConsultationController> {
  const ConsultationOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.preselectedFlow.value) {
      return _buildMemberSelectionFlow();
    }
    return _buildFullOverview();
  }

  // ─── Preselected flow: member selection (same pattern as dental) ──

  Widget _buildMemberSelectionFlow() {
    final mc = Get.find<MemberController>();

    return CommonMemberSelectionScreen(
      title: controller.appBarTitle,
      onContinue: (selected) {
        if (selected.isEmpty) return;
        mc.selectUser(selected.first.id);
        controller.continuePreselectedFlow();
      },
    );
  }

  // ─── Full overview (no arguments — both flow cards) ─────────

  Widget _buildFullOverview() {
    return SafeScreenWrapper(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const BackButton(),
            const Expanded(child: LocationHeaderBar()),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.rh),
            _buildMemberDropdown(),
            SizedBox(height: 16.rh),
            _buildHeroBanner(),
            SizedBox(height: 20.rh),
            _buildFlowCards(),
            SizedBox(height: 24.rh),
            _buildFAQSection(),
            SizedBox(height: 32.rh),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberDropdown() {
    final mc = Get.find<MemberController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Obx(
        () => FamilyMemberDropdown(
          label: AppString.kOrderingFor,
          showRequiredMark: false,
          members: mc.familyMembers,
          isLoading: mc.isLoading.value,
          selectedMemberId: mc.selectedUserId.value,
          onSelected: (m) => mc.selectUser(m.id),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.rw),
      padding: EdgeInsets.all(20.rs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.rs),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  AppString.kConsultTopDoctors,
                  fontSize: 18.rf,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                SizedBox(height: 6.rh),
                CommonText(
                  'Online or at a nearby hospital',
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/png/doctors_consult.png',
            height: 70.rh,
            width: 70.rw,
            errorBuilder: (_, __, ___) => Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
              size: 48.rs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Column(
        children: [
          _FlowCard(
            icon: Icons.videocam_outlined,
            color: AppColors.primary,
            title: AppString.kOnlineConsultation,
            description: AppString.kOnlineConsultationDesc,
            onTap: () {
              final mc = Get.find<MemberController>();
              if (mc.selectedUserId.value.isEmpty) {
                _showMemberWarning();
                return;
              }
              controller.startOnlineFlow();
            },
          ),
          SizedBox(height: 14.rh),
          _FlowCard(
            icon: Icons.local_hospital_outlined,
            color: AppColors.success,
            title: AppString.kAtHospital,
            description: AppString.kAtHospitalConsultDesc,
            onTap: () {
              final mc = Get.find<MemberController>();
              if (mc.selectedUserId.value.isEmpty) {
                _showMemberWarning();
                return;
              }
              controller.startOfflineFlow();
            },
          ),
        ],
      ),
    );
  }

  void _showMemberWarning() {
    Get.snackbar(
      'Select Member',
      'Please select a family member first',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: EdgeInsets.all(16.rs),
      borderRadius: 12.rs,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'q': AppString.kConsultationFAQ1,
        'a': AppString.kConsultationFAQ1Answer,
      },
      {
        'q': AppString.kConsultationFAQ2,
        'a': AppString.kConsultationFAQ2Answer,
      },
      {
        'q': AppString.kConsultationFAQ3,
        'a': AppString.kConsultationFAQ3Answer,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.rs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.rs),
                ),
                child: Icon(Icons.help_outline, color: AppColors.primary, size: 18.rs),
              ),
              SizedBox(width: 10.rw),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    AppString.kFAQ,
                    fontSize: 16.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  CommonText(
                    'Common questions answered',
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.rh),
          ...faqs.asMap().entries.map((entry) {
            final i = entry.key;
            final faq = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 10.rh),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.rs),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 2.rh),
                  childrenPadding: EdgeInsets.fromLTRB(14.rw, 0, 14.rw, 14.rh),
                  leading: Container(
                    width: 28.rs,
                    height: 28.rs,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.rs),
                    ),
                    child: CommonText(
                      '${i + 1}',
                      fontSize: 13.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  title: CommonText(
                    faq['q']!,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.rs),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8.rs),
                      ),
                      child: CommonText(
                        faq['a']!,
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FlowCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 12.rs,
              offset: Offset(0, 4.rs),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52.rs,
              height: 52.rs,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.rs),
              ),
              child: Icon(icon, color: color, size: 26.rs),
            ),
            SizedBox(width: 14.rw),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    title,
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 4.rh),
                  CommonText(
                    description,
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    height: 1.4,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24.rs),
          ],
        ),
      ),
    );
  }
}
