import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_health/views/dashboard/dashboard_home_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const DashboardBottomNav({
    Key? key,
    this.currentIndex = 0,
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
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, -5),
      ),
    ],
  ),
  onItemSelected: (index) {
    onTap?.call(index);
  },
  navBarStyle: NavBarStyle.style16,
 navBarHeight: 50.rh + MediaQuery.of(context).padding.bottom,

);

  }

  List<Widget> _buildScreens() {
    // Return your actual screen widgets here
    return [
      DashboardHomeScreen(), // Home Screen
      Container(), // Services Screen
      Container(), // Pharmacy Screen
      Container(), // Orders Screen
      Container(), // Help Screen
    ];
  }

 List<PersistentBottomNavBarItem> _navBarItems() {
  return [
    PersistentBottomNavBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 8.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppString.kIconHome,
              width: 20.rw,
              height: 20.rh,
              color: AppColors.primary,
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kHome,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.2,
            ),
          ],
        ),
      ),
      inactiveIcon: Padding(
        padding: EdgeInsets.only(top: 8.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppString.kIconHome,
              width: 20.rw,
              height: 20.rh,
              color: AppColors.iconTertiary,
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kHome,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.iconTertiary,
              height: 1.2,
            ),
          ],
        ),
      ),
      title: "",
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.iconTertiary,
    ),
    PersistentBottomNavBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 8.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppString.kIconServices,
              width: 20.rw,
              height: 20.rh,
              color: AppColors.primary,
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kServices,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.2,
            ),
          ],
        ),
      ),
      inactiveIcon: Padding(
        padding: EdgeInsets.only(top: 8.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppString.kIconServices,
              width: 20.rw,
              height: 20.rh,
              color: AppColors.iconTertiary,
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kServices,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.iconTertiary,
              height: 1.2,
            ),
          ],
        ),
      ),
      title: "",
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.iconTertiary,
    ),
    PersistentBottomNavBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 6.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30.rw,
              height: 30.rh,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.rw),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppString.kIconPharmacy,
                  width: 18.rw,
                  height: 18.rh,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kPharmacy,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
              height: 1.2,
            ),
          ],
        ),
      ),
      title: "",
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.primary,
    ),
    PersistentBottomNavBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 8.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppString.kIconOrders,
              width: 20.rw,
              height: 20.rh,
              color: AppColors.primary,
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kMyOrders,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.2,
            ),
          ],
        ),
      ),
      inactiveIcon: Padding(
        padding: EdgeInsets.only(top: 8.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppString.kIconOrders,
              width: 20.rw,
              height: 20.rh,
              color: AppColors.iconTertiary,
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kMyOrders,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.iconTertiary,
              height: 1.2,
            ),
          ],
        ),
      ),
      title: "",
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.iconTertiary,
    ),
    PersistentBottomNavBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 8.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppString.kIconHelp,
              width: 20.rw,
              height: 20.rh,
              color: AppColors.primary,
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kNeedHelp,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.2,
            ),
          ],
        ),
      ),
      inactiveIcon: Padding(
        padding: EdgeInsets.only(top: 8.rh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppString.kIconHelp,
              width: 20.rw,
              height: 20.rh,
              color: AppColors.iconTertiary,
            ),
            SizedBox(height: 3.rh),
            CommonText(
              AppString.kNeedHelp,
              fontSize: 8.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.iconTertiary,
              height: 1.2,
            ),
          ],
        ),
      ),
      title: "",
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.iconTertiary,
    ),
  ];
}
}
