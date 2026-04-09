import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';
import 'package:flip_health/controllers/medical%20records%20controllers/medical_records_controller.dart';
import 'package:flip_health/controllers/orders%20controllers/orders_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/help_repository.dart';
import 'package:flip_health/data/repositories/medical_records_repository.dart';
import 'package:flip_health/data/repositories/orders_repository.dart';
import 'package:flip_health/views/dashboard/dashboard_home_page.dart';
import 'package:flip_health/views/dashboard/view_more_services.dart';
import 'package:flip_health/views/help/help_screen.dart';
import 'package:flip_health/views/medical_records/medical_records_screen.dart';
import 'package:flip_health/views/orders/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DashboardMainScreen extends StatefulWidget {
  @override
  _DashboardMainScreenState createState() => _DashboardMainScreenState();
}

class _DashboardMainScreenState extends State<DashboardMainScreen> {
  int _currentIndex = 2;

  final _iconPaths = <String>[
    AppString.kIconOrders,
    AppString.kIconServices,
    AppString.kIconHelp,
    '', // Medical Records uses IconData
  ];

  final _labels = <String>[
    AppString.kMyOrders,
    AppString.kServices,
    AppString.kNeedHelp,
    AppString.kMedicalRecords,
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _ensureDependencies();
    _screens = [
      const OrdersScreen(),
      const ServicesScreen(),
      DashboardHomeScreen(),
      const HelpScreen(),
      const MedicalRecordsScreen(),
    ];
  }

  void _ensureDependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<OrdersRepository>()) {
      Get.lazyPut<OrdersRepository>(
          () => OrdersRepository(apiService: Get.find()));
    }
    if (!Get.isRegistered<OrdersController>()) {
      Get.lazyPut<OrdersController>(
          () => OrdersController(repository: Get.find()));
    }
    if (!Get.isRegistered<HelpRepository>()) {
      Get.lazyPut<HelpRepository>(
          () => HelpRepository(apiService: Get.find()));
    }
    if (!Get.isRegistered<HelpController>()) {
      Get.lazyPut<HelpController>(
          () => HelpController(repository: Get.find()));
    }
    if (!Get.isRegistered<MedicalRecordsRepository>()) {
      Get.lazyPut<MedicalRecordsRepository>(
          () => MedicalRecordsRepository(apiService: Get.find()));
    }
    if (!Get.isRegistered<MedicalRecordsController>()) {
      Get.lazyPut<MedicalRecordsController>(
          () => MedicalRecordsController(repository: Get.find()));
    }
  }

  /// Map bottom-nav item index (0-3, excluding center) to screen index (0-4)
  int _screenIndex(int navIndex) {
    // nav: 0=Orders, 1=Services, 2=NeedHelp, 3=MedicalRecords
    // screens: 0=Orders, 1=Services, 2=Home, 3=Help, 4=MedicalRecords
    switch (navIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          elevation: 2,
          onPressed: () => setState(() => _currentIndex = 2),
          child: SvgPicture.asset(
            AppString.kIconHome,
            width: 24,
            height: 24,
            colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: 4,
          tabBuilder: (int index, bool isActive) {
            final color = isActive ? AppColors.primary : AppColors.iconTertiary;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (index == 3)
                  Icon(Icons.medical_information, size: 22, color: color)
                else
                  SvgPicture.asset(
                    _iconPaths[index],
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                const SizedBox(height: 2),
                Text(
                  _labels[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
          activeIndex: _navIndexFromScreen(_currentIndex),
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          backgroundColor: Colors.white,
          splashColor: AppColors.primary.withAlpha(30),
          shadow: Shadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
          height: 60,
          onTap: (navIndex) {
            setState(() => _currentIndex = _screenIndex(navIndex));
          },
        ),
      ),
    );
  }

  /// Reverse map: screen index -> nav index (for highlighting)
  int _navIndexFromScreen(int screenIndex) {
    switch (screenIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return -1; // Home -- no nav item highlighted
    }
  }
}
