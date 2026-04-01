import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/gym%20controllers/gym_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';

class GymOverviewScreen extends GetView<GymController> {
  const GymOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: AppString.kGymOverview),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlanSection(),
                  _divider(),
                  _buildMembersSection(),
                  _divider(),
                  _buildCenterSection(),
                  _divider(),
                  _buildPaymentSection(),
                  SizedBox(height: 16.rh),
                  _buildActivationNote(),
                  SizedBox(height: 16.rh),
                  _buildRemarks(),
                  SizedBox(height: 16.rh),
                  _buildTermsCheckbox(),
                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ),
          Obx(() => controller.termsAccepted.value
              ? ActionButton(
                  text: AppString.kClickToPay,
                  onPressed: controller.confirmBooking,
                )
              : ActionButton(
                  text: AppString.kClickToPay,
                  backgroundColor: AppColors.border,
                  onPressed: () {
                    Get.snackbar(
                      'Required',
                      AppString.kAcceptTermsGym,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.warningLight,
                      colorText: AppColors.textPrimary,
                    );
                  },
                )),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.rh),
        child: Divider(color: AppColors.borderLight, thickness: 0.5),
      );

  Widget _buildPlanSection() {
    final plan = controller.selectedPlan;
    if (plan == null) return const SizedBox.shrink();

    return _AnimatedSection(
      index: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.rw, 20.rh, 24.rw, 12.rh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              AppString.kMembershipPlan,
              fontSize: 14.rf,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12.rh),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.rs),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    plan.tierColor.withValues(alpha: 0.12),
                    plan.tierColor.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.rs),
                border: Border.all(color: plan.tierColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.rs),
                    decoration: BoxDecoration(
                      color: plan.tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.rs),
                    ),
                    child: Icon(Icons.fitness_center, color: plan.tierColor, size: 22.rs),
                  ),
                  SizedBox(width: 14.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CommonText(
                              plan.type,
                              fontSize: 15.rf,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(width: 8.rw),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.rw, vertical: 2.rh),
                              decoration: BoxDecoration(
                                color: plan.tierColor,
                                borderRadius: BorderRadius.circular(4.rs),
                              ),
                              child: CommonText(
                                plan.tier,
                                fontSize: 9.rf,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.rh),
                        CommonText(
                          '${plan.months} ${AppString.kMonths} • ₹${plan.discountedPrice.toInt()} ${AppString.kPerMember}',
                          fontSize: 12.rf,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return _AnimatedSection(
      index: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 12.rh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '${AppString.kSelectedMembers} ',
                      style: TextStyle(
                        fontSize: 14.rf,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextSpan(
                      text: '(${Get.find<MemberController>().selectedMembers.length})',
                      style: TextStyle(
                        fontSize: 14.rf,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ]),
                )),
            SizedBox(height: 12.rh),
            Obx(() => Column(
                  children: Get.find<MemberController>().selectedMembers
                      .map((m) => Padding(
                            padding: EdgeInsets.only(bottom: 10.rh),
                            child: Row(
                              children: [
                                Container(
                                  width: 36.rs,
                                  height: 36.rs,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.rs),
                                  ),
                                  child: Icon(Icons.person, color: AppColors.primary, size: 18.rs),
                                ),
                                SizedBox(width: 12.rw),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        m.name,
                                        fontSize: 14.rf,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      if (m.isSponsored)
                                        CommonText(
                                          AppString.kSponsoredByCompany(m.sponsoredBy ?? ''),
                                          fontSize: 11.rf,
                                          color: AppColors.success,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterSection() {
    return _AnimatedSection(
      index: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 12.rh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              AppString.kCityAndCenter,
              fontSize: 14.rf,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12.rh),
            Obx(() {
              final center = controller.selectedCenter;
              if (center == null) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.rs),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(10.rs),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 20.rs),
                    SizedBox(width: 12.rw),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            center.name,
                            fontSize: 14.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(height: 2.rh),
                          CommonText(
                            '${center.address}, ${center.city}',
                            fontSize: 12.rf,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                    CommonText(
                      '${center.distance} km',
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _AnimatedSection(
      index: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 12.rh),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              AppString.kPaymentDetails,
              fontSize: 14.rf,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 14.rh),
            Obx(() => Column(
                  children: [
                    _paymentRow(AppString.kSubTotal, '₹ ${controller.totalPrice.toInt()}'),
                    SizedBox(height: 8.rh),
                    _paymentRow(AppString.kGST18, '₹ ${controller.gstAmount.toInt()}'),
                    SizedBox(height: 8.rh),
                    _paymentRow(AppString.kWalletDeduction, '- ₹ 0', valueColor: AppColors.success),
                    SizedBox(height: 12.rh),
                    Divider(color: AppColors.borderLight, thickness: 0.5),
                    SizedBox(height: 12.rh),
                    _paymentRow(AppString.kTotalPayable, '₹ ${controller.grandTotal.toInt()}', isBold: true),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _paymentRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(
          label,
          fontSize: isBold ? 16.rf : 14.rf,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        CommonText(
          value,
          fontSize: isBold ? 16.rf : 14.rf,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: valueColor ?? AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildActivationNote() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.rs),
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(10.rs),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.info, size: 20.rs),
            SizedBox(width: 10.rw),
            Expanded(
              child: CommonText(
                AppString.kActivationNote,
                fontSize: 12.rf,
                color: AppColors.info,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarks() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.rs),
        color: AppColors.backgroundTertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              AppString.kRemarksLabel,
              fontSize: 10.rf,
              color: AppColors.error,
            ),
            SizedBox(height: 4.rh),
            CommonText(
              AppString.kOrderCannotBeCancelled,
              fontSize: 10.rf,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Obx(() => GestureDetector(
            onTap: controller.toggleTerms,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22.rs,
                  height: 22.rs,
                  decoration: BoxDecoration(
                    color: controller.termsAccepted.value
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.rs),
                    border: Border.all(
                      color: controller.termsAccepted.value
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: controller.termsAccepted.value
                      ? Icon(Icons.check, color: Colors.white, size: 16.rs)
                      : const SizedBox.shrink(),
                ),
                SizedBox(width: 12.rw),
                Expanded(
                  child: CommonText(
                    AppString.kAcceptTermsGym,
                    fontSize: 13.rf,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class _AnimatedSection extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedSection({required this.index, required this.child});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
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
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: widget.child,
      ),
    );
  }
}
