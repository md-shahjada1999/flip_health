import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/dashboard%20controllers/dashboard_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/address_selection_sheet.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/dashboard/widgets/dash_board_searchbar.dart';
import 'package:flip_health/views/dashboard/widgets/dashboard_banner.dart';
import 'package:flip_health/views/dashboard/widgets/dashboard_header.dart';
import 'package:flip_health/views/dashboard/widgets/service_grid.dart';
import 'package:flip_health/views/dashboard/widgets/view_more_button.dart';

class DashboardHomeScreen extends StatelessWidget {
  DashboardHomeScreen({super.key});

  final DashboardController _dashboardController =
      Get.find<DashboardController>();
  final AddressController _addressController = Get.find<AddressController>();

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      builder: (context, screenType) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Obx(() => DashboardHeader(
                    address: _addressController.displayAddress,
                    onAddressPressed: () {
                      AddressSelectionSheet.show(context);
                    },
                    onCalendarPressed: () {},
                    onProfilePressed: () {},
                  )),
              RSizedBox.vertical(20),
              DashboardSearchBar(
                controller: _dashboardController.searchController,
                onChanged: (value) {},
                onVoicePressed: () {},
              ),
              RSizedBox.vertical(12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ServicesGrid(
                          services: _dashboardController.services),
                      RSizedBox.vertical(16),
                      ViewMoreButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.allServices);
                        },
                      ),
                      RSizedBox.vertical(24),
                      NutritionBanner(onJoinPressed: () {}),
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
}
