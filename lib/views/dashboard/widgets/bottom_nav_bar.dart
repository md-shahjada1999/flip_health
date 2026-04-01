import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/views/dashboard/dashboard_home_page.dart';
import 'package:flip_health/views/dashboard/view_more_services.dart';
import 'package:flip_health/views/orders/orders_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/controllers/orders%20controllers/orders_controller.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/data/repositories/help_repository.dart';
import 'package:flip_health/data/repositories/orders_repository.dart';
import 'package:flip_health/views/help/help_screen.dart';
import 'package:get/get.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const DashboardBottomNav({
    Key? key,
    this.currentIndex = 2,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: PersistentTabController(initialIndex: currentIndex),
      screens: _buildScreens(),
      items: _navBarItems(),
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(0),
        colorBehindNavBar: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      onItemSelected: (index) {
        onTap?.call(index);
      },
      navBarStyle: NavBarStyle.style16,
      navBarHeight: 56,
    );
  }

  List<Widget> _buildScreens() {
    return [
      _ordersTab(),
      const ServicesScreen(),
      DashboardHomeScreen(),
      Container(), // Medical Records placeholder
      _helpTab(),
    ];
  }

  Widget _ordersTab() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<OrdersRepository>()) {
      Get.lazyPut<OrdersRepository>(() => OrdersRepository(apiService: Get.find()));
    }
    if (!Get.isRegistered<OrdersController>()) {
      Get.lazyPut<OrdersController>(() => OrdersController(repository: Get.find()));
    }
    return const OrdersScreen();
  }

  Widget _helpTab() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<HelpRepository>()) {
      Get.lazyPut<HelpRepository>(() => HelpRepository(apiService: Get.find()));
    }
    if (!Get.isRegistered<HelpController>()) {
      Get.lazyPut<HelpController>(() => HelpController(repository: Get.find()));
    }
    return const HelpScreen();
  }

  Widget _svgIcon(String path, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: SvgPicture.asset(
        path,
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    const labelStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 10);

    return [
      // My Orders
      PersistentBottomNavBarItem(
        icon: _svgIcon(AppString.kIconOrders, AppColors.primary),
        inactiveIcon: _svgIcon(AppString.kIconOrders, AppColors.iconTertiary),
        title: AppString.kMyOrders,
        textStyle: labelStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: const Color.fromARGB(255, 53, 49, 49),
      ),

      // Services
      PersistentBottomNavBarItem(
        icon: _svgIcon(AppString.kIconServices, AppColors.primary),
        inactiveIcon: _svgIcon(AppString.kIconServices, AppColors.iconTertiary),
        title: AppString.kServices,
        textStyle: labelStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.iconTertiary,
      ),

      // Home (center floating button)
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          AppString.kIconHome,
          width: 22,
          height: 22,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        title: AppString.kHome,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
        activeColorPrimary: AppColors.primary,
        activeColorSecondary: AppColors.textPrimary,
        inactiveColorPrimary: AppColors.textPrimary,
      ),

      // Medical Records
      PersistentBottomNavBarItem(
        icon: Icon(Icons.medical_information, ),
       //_svgIcon(AppString.kIconMedicalRecords, AppColors.primary),
        inactiveIcon:  Icon(Icons.medical_information, color: AppColors.iconTertiary),
        // _svgIcon(AppString.kIconMedicalRecords, AppColors.iconTertiary),
        title: AppString.kMedicalRecords,
        iconSize: 30,
        textStyle: labelStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.iconTertiary,
      ),

      // Need Help
      PersistentBottomNavBarItem(
        icon: _svgIcon(AppString.kIconHelp, AppColors.primary),
        inactiveIcon: _svgIcon(AppString.kIconHelp, AppColors.iconTertiary),
        title: AppString.kNeedHelp,
        textStyle: labelStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.iconTertiary,
      ),
    ];
  }
}
