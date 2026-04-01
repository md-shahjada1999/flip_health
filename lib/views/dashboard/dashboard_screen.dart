import 'package:flutter/material.dart';
import 'package:flip_health/views/dashboard/widgets/bottom_nav_bar.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class DashboardMainScreen extends StatefulWidget {
  @override
  _DashboardMainScreenState createState() => _DashboardMainScreenState();
}

class _DashboardMainScreenState extends State<DashboardMainScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 2);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(body: DashboardBottomNav()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
