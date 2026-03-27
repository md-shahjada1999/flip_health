import 'package:flutter/material.dart';
import 'package:flip_health/views/dashboard/dashboard_home_page.dart';
import 'package:flip_health/views/dashboard/widgets/bottom_nav_bar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/model/dashboard%20models/service_model.dart';
import 'package:flip_health/views/dashboard/widgets/dash_board_searchbar.dart';
import 'package:flip_health/views/dashboard/widgets/dashboard_banner.dart';
import 'package:flip_health/views/dashboard/widgets/dashboard_header.dart';
import 'package:flip_health/views/dashboard/widgets/service_grid.dart';
import 'package:flip_health/views/dashboard/widgets/view_more_button.dart';

class DashboardMainScreen extends StatefulWidget {
  @override
  _DashboardMainScreenState createState() => _DashboardMainScreenState();
}

class _DashboardMainScreenState extends State<DashboardMainScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(body:  DashboardBottomNav(),));
    
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
