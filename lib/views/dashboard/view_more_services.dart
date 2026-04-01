// ====================
// SERVICES SCREEN WITH MODERN TAB BAR & ANIMATIONS
// ====================
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/core/utils/service_type_sheet.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/help_repository.dart';
import 'package:flip_health/views/help/help_screen.dart';
import 'package:get/get.dart' hide ResponsiveScreen;

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animation when screen loads
    _animationController.forward();

    // Restart animation when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: "",
      ),
      body: Column(
        children: [
          // Modern Tab Bar
          _buildModernTabBar(),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesTab(),
                _buildOPDClaimsTab(),
                _buildAccountManagementTab(),
                _buildHelpSupportTab(),
                _buildMedicalRecordsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Tab Bar with Pill Design

// Modern Tab Bar matching the design
  Widget _buildModernTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.rs),
      height: 70.rh,
      decoration: BoxDecoration(
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.black,
            width: 1,
          ),
          insets: EdgeInsets.symmetric(horizontal: 12.rs),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: 10.rf,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10.rf,
          fontWeight: FontWeight.w500,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 10.rs),
        padding: EdgeInsets.zero,
        tabs: [
          _buildModernTab(
            icon: AppString.kIconServicesTabBar,
            label: AppString.kTabBarServices,
            index: 0,
          ),
          _buildModernTab(
            icon: AppString.kIconOPDClaims,
            label: AppString.kOPDClaims,
            index: 1,
          ),
          _buildModernTab(
            icon: AppString.kIconAccountManagement,
            label: AppString.kAccountManagement,
            index: 2,
          ),
          _buildModernTab(
            icon: AppString.kIconHelpSupport,
            label: AppString.kHelpSupport,
            index: 3,
          ),
          _buildModernTab(
            icon: AppString.kIconMedicalRecords,
            label: AppString.kMedicalRecords,
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildModernTab({
    required String icon,
    required String label,
    required int index,
  }) {
    final isSelected = _tabController.index == index;

    return Tab(
      height: 60.rh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            height: 20.rh,
            width: 20.rw,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.black : AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 6.rh),
          CommonText(
            label,
            fontSize: 10.rf,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.black : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  int _getTabIndex(String label) {
    switch (label) {
      case AppString.kIconServicesTabBar:
        return 0;
      case AppString.kOPDClaims:
        return 1;
      case AppString.kAccountManagement:
        return 2;
      case AppString.kHelpSupport:
        return 3;
      case AppString.kMedicalRecords:
        return 4;
      default:
        return 0;
    }
  }

  // Services Tab
  Widget _buildServicesTab() {
    return SingleChildScrollView(
      child: ResponsiveScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RSizedBox.vertical(24),

            // Animated Title
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                )),
                child: RText(
                  AppString.kServices,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),

            RSizedBox.vertical(24),

            // Animated Services Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.isSmallScreen ? 2 : 3,
              crossAxisSpacing: 10.rs,
              mainAxisSpacing: 10.rs,
              childAspectRatio: ResponsiveHelper.isSmallScreen ? 1.0 : 0.86,
              children: [
                _buildAnimatedCard(
                  index: 0,
                  child: ServiceCard(
                    icon: AppString.kIconDiagnostics,
                    title: AppString.kBookDiagnostics,
                    subtitle: AppString.kBookDiagnosticsSubtitle,
                    onTap: () => ServiceTypeSheet.show(
                      title: AppString.kSelectServiceType,
                      options: [
                        ServiceOption(
                          title: AppString.kHealthCheckupsOption,
                          subtitle: AppString.kHealthCheckupsOptionDesc,
                          svgPath: AppString.kIconFreeHealthCheckups,
                          onTap: () => Get.toNamed(AppRoutes.healthCheckups),
                        ),
                        ServiceOption(
                          title: AppString.kLabTestsOption,
                          subtitle: AppString.kLabTestsOptionDesc,
                          svgPath: AppString.kIconLabTests,
                          onTap: () => Get.toNamed(AppRoutes.labTests),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  index: 1,
                  child: ServiceCard(
                    icon: AppString.kIconConsultation,
                    title: AppString.kBookConsultation,
                    subtitle: AppString.kBookConsultationSubtitle,
                    onTap: () => ServiceTypeSheet.show(
                      title: AppString.kSelectServiceType,
                      options: [
                        ServiceOption(
                          title: AppString.kAtHospitalConsultation,
                          subtitle: AppString.kAtHospitalDesc,
                          svgPath: AppString.kIconConsultation,
                          onTap: () => Get.toNamed(AppRoutes.consultation, arguments: 'hospital'),
                        ),
                        ServiceOption(
                          title: AppString.kVirtualConsultation,
                          subtitle: AppString.kVirtualDesc,
                          svgPath: AppString.kVirtualIcon,
                          onTap: () => Get.toNamed(AppRoutes.consultation, arguments: 'virtual'),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  index: 2,
                  child: ServiceCard(
                    icon: AppString.kIconDental,
                    title: AppString.kDentalServices,
                    subtitle: AppString.kDentalServicesSubtitle,
                    onTap: () => ServiceTypeSheet.show(
                      title: AppString.kSelectServiceType,
                      options: [
                        ServiceOption(
                          title: AppString.kAtHospitalDental,
                          subtitle: AppString.kAtHospitalDentalDesc,
                          svgPath: AppString.kIconDental,
                          onTap: () => Get.toNamed(AppRoutes.dental, arguments: 'hospital'),
                        ),
                        ServiceOption(
                          title: AppString.kVirtualDental,
                          subtitle: AppString.kVirtualDentalDesc,
                          svgPath: AppString.kVirtualIcon,
                          onTap: () => Get.toNamed(AppRoutes.dental, arguments: 'virtual'),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  index: 3,
                  child: ServiceCard(
                    icon: AppString.kIconPrescribedPharmacy,
                    title: AppString.kPrescribedPharmacy,
                    subtitle: AppString.kPrescribedPharmacySubtitle,
                    onTap: () => ServiceTypeSheet.show(
                      title: AppString.kSelectServiceType,
                      options: [
                        ServiceOption(
                          title: AppString.kPrescribedPharmacyOption,
                          subtitle: AppString.kPrescribedPharmacyDesc,
                          svgPath: AppString.kIconPrescribedPharmacy,
                          onTap: () => Get.toNamed(AppRoutes.pharmacy, arguments: 'prescribed'),
                        ),
                        ServiceOption(
                          title: AppString.kOTCProducts,
                          subtitle: AppString.kOTCProductsDesc,
                          svgPath: AppString.kIconPrescribedPharmacy,
                          onTap: () => Get.toNamed(AppRoutes.pharmacy, arguments: 'otc'),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  index: 4,
                  child: ServiceCard(
                    icon: AppString.kIconVaccination,
                    title: AppString.kVaccinationServices,
                    subtitle: AppString.kVaccinationServicesSubtitle,
                    onTap: () => Get.toNamed(AppRoutes.vaccine),
                  ),
                ),
                _buildAnimatedCard(
                  index: 5,
                  child: ServiceCard(
                    icon: AppString.kIconVision,
                    title: AppString.kVisionServices,
                    subtitle: AppString.kVisionServicesSubtitle,
                    onTap: () => ServiceTypeSheet.show(
                      title: AppString.kSelectServiceType,
                      options: [
                        ServiceOption(
                          title: AppString.kEyeCheckup,
                          subtitle: AppString.kEyeCheckupDesc,
                          svgPath: 'assets/svg/eyecheck.svg',
                          onTap: () => Get.toNamed(AppRoutes.vision, arguments: 'eye_checkup'),
                        ),
                        ServiceOption(
                          title: AppString.kGlassesLens,
                          subtitle: AppString.kGlassesLensDesc,
                          svgPath: 'assets/svg/Lens.svg',
                          onTap: () => Get.toNamed(AppRoutes.vision, arguments: 'glasses_lens'),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildAnimatedCard(
                 index: 6,
                 child: ServiceCard(
                   icon: AppString.kIconMentalWellness,
                   title: AppString.kMentalWellness,
                   subtitle: AppString.kMentalWellnessSubtitle,
                   onTap: () => Get.toNamed(AppRoutes.mentalWellness),
                 ),
               ),
                _buildAnimatedCard(
                  index: 7,
                  child: ServiceCard(
                    icon: AppString.kIconChronicManagement,
                    title: AppString.kChronicManagement,
                    subtitle: AppString.kChronicManagementSubtitle,
                    showBadge: true,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 8,
                  child: ServiceCard(
                    icon: AppString.kIconNutrition,
                    title: AppString.kNutritionServices,
                    subtitle: AppString.kNutritionServicesSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 9,
                  child: ServiceCard(
                    icon: AppString.kIconGymFitness,
                    title: AppString.kGymFitness,
                    subtitle: AppString.kGymFitnessSubtitle,
                    onTap: () => Get.toNamed(AppRoutes.gym),
                  ),
                ),
              ],
            ),

            RSizedBox.vertical(24),
          ],
        ),
      ),
    );
  }

  // OPD Claims Tab
  Widget _buildOPDClaimsTab() {
    return SingleChildScrollView(
      child: ResponsiveScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RSizedBox.vertical(24),
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                )),
                child: RText(
                  AppString.kOPDClaims,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            RSizedBox.vertical(24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.isSmallScreen ? 2 : 3,
              crossAxisSpacing: 12.rs,
              mainAxisSpacing: 12.rs,
              childAspectRatio: ResponsiveHelper.isSmallScreen ? 1.0 : 0.86,
              children: [
                _buildAnimatedCard(
                  index: 0,
                  child: ServiceCard(
                    icon: AppString.kIconClaims,
                    title: AppString.kClaims,
                    subtitle: AppString.kClaimsSubtitle,
                    onTap: () => Get.toNamed(AppRoutes.claims),
                  ),
                ),
                _buildAnimatedCard(
                 index: 1,
                 child: ServiceCard(
                   icon: AppString.kIconBankDetails,
                   title: AppString.kBankDetails,
                   subtitle: AppString.kBankDetailsSubtitle,
                   onTap: () => Get.toNamed(AppRoutes.bankDetails),
                 ),
               ),
                _buildAnimatedCard(
                  index: 2,
                  child: ServiceCard(
                    icon: AppString.kIconCalendar,
                    title: AppString.kOPDWallet,
                    subtitle: AppString.kOPDWalletSubtitle,
                    onTap: () => Get.toNamed(AppRoutes.wallet),
                  ),
                ),
              ],
            ),
            RSizedBox.vertical(24),
          ],
        ),
      ),
    );
  }

  // Account Management Tab
  Widget _buildAccountManagementTab() {
    return SingleChildScrollView(
      child: ResponsiveScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RSizedBox.vertical(24),
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                )),
                child: RText(
                  AppString.kAccountManagement,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            RSizedBox.vertical(24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.isSmallScreen ? 2 : 3,
              crossAxisSpacing: 12.rs,
              mainAxisSpacing: 12.rs,
              childAspectRatio: ResponsiveHelper.isSmallScreen ? 1.0 : 0.86,
              children: [
                _buildAnimatedCard(
                  index: 0,
                  child: ServiceCard(
                    icon: AppString.kIconProfileSerices,
                    title: AppString.kProfile,
                    subtitle: AppString.kProfileSubtitle,
                    onTap: () {
                      Get.toNamed(AppRoutes.profile);
                    },
                  ),
                ),
                _buildAnimatedCard(
                  index: 1,
                  child: ServiceCard(
                    icon: AppString.kIconSubscriptions,
                    title: AppString.kSubscriptions,
                    subtitle: AppString.kSubscriptionsSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 2,
                  child: ServiceCard(
                    icon: AppString.kIconFamilyAccounts,
                    title: AppString.kFamilyAccounts,
                    subtitle: AppString.kFamilyAccountsSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 3,
                  child: ServiceCard(
                    icon: AppString.kIconAddressBook,
                    title: AppString.kAddressBook,
                    subtitle: AppString.kAddressBookSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 4,
                  child: ServiceCard(
                    icon: AppString.kIconOrdersServices,
                    title: AppString.kOrders,
                    subtitle: AppString.kOrdersSubtitle,
                    onTap: () => Get.toNamed(AppRoutes.orders),
                  ),
                ),
                _buildAnimatedCard(
                  index: 5,
                  child: ServiceCard(
                    icon: AppString.kIconSetPassword,
                    title: AppString.kSetPassword,
                    subtitle: AppString.kSetPasswordSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 6,
                  child: ServiceCard(
                    icon: AppString.kIconDeleteAccount,
                    title: AppString.kDeleteAccount,
                    subtitle: AppString.kDeleteAccountSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 7,
                  child: ServiceCard(
                    icon: AppString.kIconInvoices,
                    title: AppString.kInvoices,
                    subtitle: AppString.kInvoicesSubtitle,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            RSizedBox.vertical(24),
          ],
        ),
      ),
    );
  }

  // Help & Support Tab
  Widget _buildHelpSupportTab() {
    return SingleChildScrollView(
      child: ResponsiveScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RSizedBox.vertical(24),
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                )),
                child: RText(
                  AppString.kHelpSupport,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            RSizedBox.vertical(24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.isSmallScreen ? 2 : 3,
              crossAxisSpacing: 12.rs,
              mainAxisSpacing: 12.rs,
              childAspectRatio: 0.9,
              children: [
                _buildAnimatedCard(
                  index: 0,
                  child: ServiceCard(
                    icon: AppString.kIconSupport,
                    title: AppString.kSupport,
                    subtitle: AppString.kSupportSubtitle,
                    onTap: () {
                      if (!Get.isRegistered<ApiService>()) {
                        Get.lazyPut<ApiService>(() => ApiService());
                      }
                      if (!Get.isRegistered<HelpRepository>()) {
                        Get.lazyPut<HelpRepository>(() => HelpRepository(apiService: Get.find()));
                      }
                      if (!Get.isRegistered<HelpController>()) {
                        Get.lazyPut<HelpController>(() => HelpController(repository: Get.find()));
                      }
                      Get.to(() => const HelpScreen());
                    },
                  ),
                ),
                _buildAnimatedCard(
                  index: 1,
                  child: ServiceCard(
                    icon: AppString.kIconFAQ,
                    title: AppString.kFAQ,
                    subtitle: AppString.kFAQSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 2,
                  child: ServiceCard(
                    icon: AppString.kIconTC,
                    title: AppString.kTC,
                    subtitle: AppString.kTCSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 3,
                  child: ServiceCard(
                    icon: AppString.kIconPrivacyPolicies,
                    title: AppString.kPrivacyPolicies,
                    subtitle: AppString.kPrivacyPoliciesSubtitle,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            RSizedBox.vertical(24),
          ],
        ),
      ),
    );
  }

  // Medical Records Tab
  Widget _buildMedicalRecordsTab() {
    return SingleChildScrollView(
      child: ResponsiveScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RSizedBox.vertical(24),
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                )),
                child: RText(
                  AppString.kMedicalRecords,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            RSizedBox.vertical(24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.isSmallScreen ? 2 : 3,
              crossAxisSpacing: 12.rs,
              mainAxisSpacing: 12.rs,
              childAspectRatio: ResponsiveHelper.isSmallScreen ? 1.0 : 0.86,
              children: [
                _buildAnimatedCard(
                  index: 0,
                  child: ServiceCard(
                    icon: AppString.kIconMyAppointments,
                    title: AppString.kMyAppointments,
                    subtitle: AppString.kMyAppointmentsSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 1,
                  child: ServiceCard(
                    icon: AppString.kIconLabReports,
                    title: AppString.kLabReports,
                    subtitle: AppString.kLabReportsSubtitle,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 2,
                  child: ServiceCard(
                    icon: AppString.kIconMyPrescriptions,
                    title: AppString.kMyPrescriptions,
                    subtitle: AppString.kMyPrescriptionsSubtitle,
                    showBadge: true,
                    onTap: () {},
                  ),
                ),
                _buildAnimatedCard(
                  index: 3,
                  child: ServiceCard(
                    icon: AppString.kIconActivities,
                    title: AppString.kActivities,
                    subtitle: AppString.kActivitiesSubtitle,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            RSizedBox.vertical(24),
          ],
        ),
      ),
    );
  }

  // Animated Card Wrapper with Staggered Animation
  Widget _buildAnimatedCard({required int index, required Widget child}) {
    final delay = Duration(milliseconds: 50 * index);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delayedValue = Curves.easeOutCubic.transform(
          (_animationController.value - (0.05 * index)).clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, 30 * (1 - delayedValue)),
          child: Opacity(
            opacity: delayedValue,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ====================
// COMMON SERVICE CARD WIDGET WITH HOVER EFFECT
// ====================
class ServiceCard extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool showBadge;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showBadge = false,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _hoverController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _hoverController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          final scale = 1.0 - (_hoverController.value * 0.05);

          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(16.rs),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: _isPressed ? 12 : 6,
                    offset: Offset(0, _isPressed ? 2 : 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(10.rs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon with badge
                  Stack(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.rs),
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              borderRadius: BorderRadius.circular(12.rs),
                            ),
                            child: SvgPicture.asset(
                              widget.icon,
                              height: 20.rh,
                              width: 20.rw,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Spacer(),
                          if (widget.showBadge)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.rs,
                                vertical:1.rs,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.textPrimary,
                                   
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8.rs),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CommonText(
                                'New',
                                color: Colors.white,
                                fontSize: 7.rf,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Title
                  RText(
                    widget.title,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  RSizedBox.vertical(6),

                  // Subtitle
                  RText(
                    widget.subtitle,
                    fontSize: 8,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    lineHeight: 1.3,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
