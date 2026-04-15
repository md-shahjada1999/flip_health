import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';

class SelectPlanPage extends StatefulWidget {
  const SelectPlanPage({super.key});

  @override
  State<SelectPlanPage> createState() => _SelectPlanPageState();
}

class _SelectPlanPageState extends State<SelectPlanPage> {
  final controller = Get.find<HealthCheckupsController>();

  @override
  void initState() {
    super.initState();
    if (controller.selectedMembers.isNotEmpty) {
      controller.fetchPackagesForMember(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: 'Select Package'),
      body: Column(
        children: [
          _buildMemberTabs(),
          Expanded(child: _buildPackageList()),
          Obx(() => ActionButton(
                text: 'Continue',
                isLoading: controller.isVendorLoading.value,
                onPressed: controller.allMembersHavePackage &&
                        !controller.isVendorLoading.value
                    ? () => controller.continueToVendorSelection()
                    : null,
              )),
        ],
      ),
    );
  }

  Widget _buildMemberTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final members = controller.selectedMembers;
        final activeIdx = controller.activeMemberTab.value;
        final selMap = Map<String, int>.from(controller.memberPackageMap);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
          child: Row(
            children: List.generate(members.length, (i) {
              final m = members[i];
              final isActive = i == activeIdx;
              final hasPackage = selMap.containsKey(m.id);
              final initial = m.name.isNotEmpty ? m.name[0].toUpperCase() : '?';

              return Padding(
                padding: EdgeInsets.only(right: 10.rw),
                child: GestureDetector(
                  onTap: () => controller.fetchPackagesForMember(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.only(
                        left: 6.rw, right: 14.rw, top: 6.rh, bottom: 6.rh),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(colors: [
                              AppColors.textPrimary,
                              AppColors.textPrimary.withValues(alpha: 0.85),
                            ])
                          : null,
                      color: isActive ? null : Colors.white,
                      borderRadius: BorderRadius.circular(28.rs),
                      border: Border.all(
                        color: isActive
                            ? Colors.transparent
                            : hasPackage
                                ? AppColors.success.withValues(alpha: 0.5)
                                : AppColors.borderLight,
                        width: 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.textPrimary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 28.rs,
                          height: 28.rs,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.2)
                                : hasPackage
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.backgroundSecondary,
                          ),
                          child: Center(
                            child: hasPackage && !isActive
                                ? Icon(Icons.check,
                                    size: 14.rs, color: AppColors.success)
                                : CommonText(
                                    initial,
                                    fontSize: 12.rf,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                          ),
                        ),
                        SizedBox(width: 8.rw),
                        CommonText(
                          m.firstName.isNotEmpty ? m.firstName : m.name,
                          fontSize: 13.rf,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : AppColors.textPrimary,
                        ),
                        if (hasPackage && isActive) ...[
                          SizedBox(width: 6.rw),
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 15.rs),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildPackageList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final packages = controller.currentPackages;

      if (packages.isEmpty) {
        return Center(
          child: FadeIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lotties/Chemistry Lab.json',
                  width: 180.rs,
                  height: 180.rs,
                  repeat: true,
                ),
                SizedBox(height: 12.rh),
                CommonText(
                  'No packages available',
                  fontSize: 15.rf,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
      }

      final activeMember = controller.selectedMembers.isNotEmpty
          ? controller.selectedMembers[controller.activeMemberTab.value]
          : null;

      final selectionMap = Map<String, int>.from(controller.memberPackageMap);

      return ListView.builder(
        padding: EdgeInsets.all(16.rs),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final pkg = packages[index];
          final isSelected = activeMember != null &&
              selectionMap[activeMember.id] == pkg.id;

          return FadeInUp(
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: 50 * index),
            child: _PackageCard(
              package: pkg,
              isSelected: isSelected,
              onTap: () {
                if (activeMember != null) {
                  controller.selectPackageForMember(activeMember.id, pkg.id);
                }
              },
              onSeeInclusions: pkg.pricing != null && pkg.pricing!.id > 0
                  ? () => controller.openPackageInclusions(pkg.pricing!.id)
                  : null,
            ),
          );
        },
      );
    });
  }
}

class _PackageCard extends StatelessWidget {
  final DiagnosticsPackage package;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onSeeInclusions;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
    this.onSeeInclusions,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.only(bottom: 12.rh),
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Lottie.asset(
                  'assets/lotties/Chemistry Lab.json',
                  width: 48.rs,
                  height: 48.rs,
                  repeat: true,
                ),
                SizedBox(width: 10.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        package.name,
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.rh),
                      Wrap(
                        spacing: 8.rw,
                        runSpacing: 4.rh,
                        children: [
                          _infoChip(Icons.local_dining_outlined,
                              package.fastingLabel),
                          if (package.tatLabel.isNotEmpty)
                            _infoChip(Icons.schedule, package.tatLabel),
                          _categoryChip(package.category),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.rw),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28.rs,
                  height: 28.rs,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.backgroundSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16.rs)
                      : null,
                ),
              ],
            ),
          ),
          if (onSeeInclusions != null) ...[
            SizedBox(height: 12.rh),
            GestureDetector(
              onTap: onSeeInclusions,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  CommonText(
                    AppString.kSeeWhatsIncluded,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.rw),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.rs,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.rs, color: AppColors.textSecondary),
        SizedBox(width: 4.rw),
        CommonText(text,
            fontSize: 11.rf,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500),
      ],
    );
  }

  Widget _categoryChip(String category) {
    final color = category == 'pathology'
        ? Colors.blue
        : category == 'radiology'
            ? Colors.orange
            : AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 2.rh),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.rs),
      ),
      child: CommonText(
        category.capitalizeFirst ?? category,
        fontSize: 10.rf,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
