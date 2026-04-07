import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/profile%20controllers/profile_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/core/utils/common_dialog.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/profile/widgets/profile_action_card.dart';
import 'package:flip_health/views/profile/widgets/profile_info_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ProfileController controller = Get.find<ProfileController>();
  late final AnimationController _animController;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;
  late final Animation<double> _infoFade;
  late final Animation<double> _bmiFade;
  late final Animation<Offset> _bmiSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _headerScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    _infoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );
    _bmiFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );
    _bmiSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOutCubic),
      ),
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
    return ResponsiveWidget(builder: (context, screenType) {
      return SafeScreenWrapper(
        appBar: CommonAppBar.build(title: AppString.kProfileTitle),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.rw),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.rh),
              _buildAvatarSection(),
              SizedBox(height: 28.rh),
              _buildInfoSection(),
              SizedBox(height: 24.rh),
              _buildBMICard(),
              SizedBox(height: 28.rh),
              _buildQuickAccessSection(),
              SizedBox(height: 24.rh),
              _buildLogoutButton(),
              SizedBox(height: 32.rh),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAvatarSection() {
    return FadeTransition(
      opacity: _headerFade,
      child: ScaleTransition(
        scale: _headerScale,
        child: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: controller.pickProfilePhoto,
                child: Stack(
                  children: [
                    Obx(() => Container(
                          width: 100.rs,
                          height: 100.rs,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: controller.hasProfileImage
                                ? null
                                : const LinearGradient(
                                    colors: AppColors.primaryGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 3,
                            ),
                            image: controller.hasProfileImage
                                ? DecorationImage(
                                    image: FileImage(
                                      File(controller.profileImagePath.value),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.hasProfileImage
                              ? null
                              : Center(
                                  child: CommonText(
                                    controller.initials,
                                    fontSize: 32.rf,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32.rs,
                        height: 32.rs,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 16.rs,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.rh),
              Obx(() => CommonText(
                    controller.fullName,
                    fontSize: 20.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              SizedBox(height: 4.rh),
              GestureDetector(
                onTap: controller.pickProfilePhoto,
                child: CommonText(
                  AppString.kEditPhoto,
                  fontSize: 13.rf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return FadeTransition(
      opacity: _infoFade,
      child: Container(
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Obx(() => Column(
              children: [
                ProfileInfoTile(
                  icon: Icons.person_outline_rounded,
                  label: AppString.kName,
                  value: controller.fullName,
                ),
                Divider(color: AppColors.borderLight, height: 1),
                ProfileInfoTile(
                  icon: Icons.phone_outlined,
                  label: AppString.kPhone,
                  value: controller.phone.value.isNotEmpty
                      ? controller.phone.value
                      : AppString.kNotAvailable,
                ),
                Divider(color: AppColors.borderLight, height: 1),
                ProfileInfoTile(
                  icon: Icons.email_outlined,
                  label: AppString.kEmail,
                  value: controller.email.value.isNotEmpty
                      ? controller.email.value
                      : AppString.kNotAvailable,
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildBMICard() {
    return FadeTransition(
      opacity: _bmiFade,
      child: SlideTransition(
        position: _bmiSlide,
        child: Obx(() {
          final hasBmi = controller.bmiValue.value > 0;
          return Container(
            padding: EdgeInsets.all(18.rs),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  controller.bmiColor.value.withValues(alpha: 0.1),
                  controller.bmiColor.value.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.rs),
              border: Border.all(
                color: controller.bmiColor.value.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.rs),
                      decoration: BoxDecoration(
                        color:
                            controller.bmiColor.value.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.rs),
                      ),
                      child: Icon(
                        Icons.monitor_heart_outlined,
                        size: 22.rs,
                        color: controller.bmiColor.value,
                      ),
                    ),
                    SizedBox(width: 12.rw),
                    CommonText(
                      AppString.kHealthOverview,
                      fontSize: 16.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
                SizedBox(height: 18.rh),
                Row(
                  children: [
                    Expanded(
                      child: _BmiStatItem(
                        label: AppString.kBMI,
                        value: hasBmi
                            ? controller.bmiValue.value.toStringAsFixed(1)
                            : '--',
                        color: controller.bmiColor.value,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 44.rh,
                      color: controller.bmiColor.value.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _BmiStatItem(
                        label: AppString.kBMICategory,
                        value: hasBmi
                            ? controller.bmiCategory.value
                            : AppString.kNotAvailable,
                        color: controller.bmiColor.value,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          AppString.kQuickAccess,
          fontSize: 17.rf,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 14.rh),
        ProfileActionCard(
          index: 0,
          svgIcon: AppString.kIconMyAppointments,
          title: AppString.kMedicalRecords,
          subtitle: AppString.kViewMedicalRecords,
          onTap: () {
            Get.snackbar(
              AppString.kMedicalRecords,
              'Coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        SizedBox(height: 10.rh),
        ProfileActionCard(
          index: 1,
          svgIcon: AppString.kIconMyPrescriptions,
          title: AppString.kMyPrescriptions,
          subtitle: AppString.kViewPrescriptions,
          onTap: () {
            Get.snackbar(
              AppString.kMyPrescriptions,
              'Coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        SizedBox(height: 10.rh),
        ProfileActionCard(
          index: 2,
          svgIcon: AppString.kIconLabReports,
          title: AppString.kLabReports,
          subtitle: AppString.kViewLabReports,
          onTap: () {
            Get.snackbar(
              AppString.kLabReports,
              'Coming soon',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return FadeTransition(
      opacity: _bmiFade,
      child: GestureDetector(
        onTap: () async {
          final confirmed = await CommonDialog.show(
            title: AppString.kLogout,
            message: 'Are you sure you want to log out?',
            type: DialogType.warning,
            confirmText: 'Logout',
            cancelText: 'Cancel',
            icon: Icons.logout_rounded,
          );
          if (confirmed == true) controller.logout();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.rh),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(14.rs),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 20.rs,
                color: AppColors.error,
              ),
              SizedBox(width: 8.rw),
              CommonText(
                AppString.kLogout,
                fontSize: 15.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BmiStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BmiStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonText(
          value,
          fontSize: 24.rf,
          fontWeight: FontWeight.w800,
          color: color,
        ),
        SizedBox(height: 4.rh),
        CommonText(
          label,
          fontSize: 12.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
