import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/dashboard%20controllers/dashboard_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/dashboard/widgets/dash_board_searchbar.dart';
import 'package:flip_health/views/dashboard/widgets/dashboard_banner.dart';
import 'package:flip_health/views/dashboard/widgets/dashboard_header.dart';
import 'package:flip_health/views/dashboard/widgets/service_grid.dart';
import 'package:flip_health/views/dashboard/widgets/view_more_button.dart';

class DashboardHomeScreen extends StatefulWidget {
  @override
  _DashboardHomeScreenState createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {

  

final DashboardController _dashboardController = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      builder: (context, screenType) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Header
              DashboardHeader(
                address: "Ishrout, 7th floor, Plot No. 25, ...",
                onAddressPressed: () {
                  // Handle address selection
                },
                onCalendarPressed: () {
                  // Handle calendar tap
                },
                onProfilePressed: () {
                  // Handle profile tap
                },
              ),
              
              RSizedBox.vertical(20),
              
              // Search Bar
              DashboardSearchBar(
                controller: _dashboardController.searchController,
                onChanged: (value) {
                  // Handle search
                },
                onVoicePressed: () {
                  // Handle voice search
                },
              ),
              
              RSizedBox.vertical(12),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Services Grid
                      ServicesGrid(services: _dashboardController.services),
                      
                      RSizedBox.vertical(16),
                      
                      // View More Button
                      ViewMoreButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.allServices);
                        },
                      ),
                      
                      RSizedBox.vertical(24),
                      
                      // Nutrition Banner
                      NutritionBanner(
                        onJoinPressed: () {
                          // Handle join webinar
                        },
                      ),
                      
                      RSizedBox.vertical(24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
   _dashboardController.searchController.dispose();
    super.dispose();
  }
}