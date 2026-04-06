import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/gym%20controllers/gym_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/gym/gym_member_selection_screen.dart';

class GymMembershipScreen extends GetView<GymController> {
  const GymMembershipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kGymMembership),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            Expanded(
              child: controller.membershipPlans.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.rw,
                        vertical: 10.rh,
                      ),
                      itemCount: controller.membershipPlans.length,
                      itemBuilder: (context, index) {
                        return _MembershipCard(
                          plan: controller.membershipPlans[index],
                          index: index,
                        );
                      },
                    ),
            ),
            if (controller.selectedPlanIndex.value >= 0)
              SafeBottomPadding(
                child: ActionButton(
                  text: AppString.kContinue,
                  onPressed: () =>
                      Get.to(() => const GymMemberSelectionScreen()),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _MembershipCard extends StatefulWidget {
  final MembershipPlan plan;
  final int index;

  const _MembershipCard({required this.plan, required this.index});

  @override
  State<_MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<_MembershipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GymController>();
    final plan = widget.plan;
    final gstAmount = (plan.discountedPrice * 0.18).round();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Obx(() {
          final isSelected = controller.selectedPlanIndex.value == widget.index;
          final isExpanded = controller.isExpanded(widget.index);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(bottom: 16.rh),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.rs),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Banner card with background image
                GestureDetector(
                  onTap: () => controller.selectPlan(widget.index),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 160.rh),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.rs),
                        topRight: Radius.circular(18.rs),
                        bottomLeft: isExpanded
                            ? Radius.zero
                            : Radius.circular(18.rs),
                        bottomRight: isExpanded
                            ? Radius.zero
                            : Radius.circular(18.rs),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(17.rs),
                        topRight: Radius.circular(17.rs),
                        bottomLeft: isExpanded
                            ? Radius.zero
                            : Radius.circular(17.rs),
                        bottomRight: isExpanded
                            ? Radius.zero
                            : Radius.circular(17.rs),
                      ),
                      child: Stack(
                        children: [
                          // Background Image
                          Positioned.fill(
                            child: Image.asset(
                              plan.backgroundImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[900]!,
                                        Colors.grey[800]!,
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Gradient overlay for text readability
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black,
                                    Colors.black.withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.45, 0.87],
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.rw,
                              vertical: 14.rh,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${plan.type} ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.rf,
                                                fontWeight: FontWeight.w300,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            TextSpan(
                                              text: plan.tier,
                                              style: TextStyle(
                                                color: plan.tierColor,
                                                fontSize: 18.rf,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' ${AppString.kMembership}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.rf,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.rw),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      width: 26.rs,
                                      height: 26.rs,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.black,
                                              size: 16.rs,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.rh),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${plan.months}',
                                            style: TextStyle(
                                              color: plan.tierColor,
                                              fontSize: 26.rf,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ${AppString.kMonths}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.rf,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 6.rh),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '₹ ${plan.originalPrice.toInt()}+',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 11.rf,
                                                  fontFamily: 'Poppins',
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  decorationColor: Colors.white
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          '₹ ${plan.discountedPrice.toInt()}',
                                                      style: TextStyle(
                                                        color: plan.tierColor,
                                                        fontSize: 18.rf,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '/${AppString.kPerMember}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11.rf,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '(+$gstAmount ${AppString.kTaxesAndFees})',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 8.rf,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => controller
                                              .toggleExpanded(widget.index),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: 8.rw,
                                            ),
                                            child: Text(
                                              AppString.kViewBenefits,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11.rf,
                                                fontFamily: 'Poppins',
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
                ),

                // Expandable benefits section
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(17.rs),
                        bottomRight: Radius.circular(17.rs),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            20.rw,
                            16.rh,
                            20.rw,
                            12.rh,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${plan.type} ',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16.rf,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    TextSpan(
                                      text: plan.tier,
                                      style: TextStyle(
                                        color: plan.tierColor,
                                        fontSize: 16.rf,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ${AppString.kBenefits}',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16.rf,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    controller.toggleExpanded(widget.index),
                                child: Container(
                                  width: 28.rs,
                                  height: 28.rs,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundTertiary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18.rs,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.rw, 0, 20.rw, 16.rh),
                          child: Column(
                            children: plan.benefits
                                .map(
                                  (benefit) => Padding(
                                    padding: EdgeInsets.only(bottom: 12.rh),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24.rs,
                                          height: 24.rs,
                                          decoration: const BoxDecoration(
                                            color: AppColors.success,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16.rs,
                                          ),
                                        ),
                                        SizedBox(width: 12.rw),
                                        CommonText(
                                          benefit,
                                          fontSize: 15.rf,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
