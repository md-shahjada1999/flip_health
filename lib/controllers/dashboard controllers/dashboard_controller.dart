import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_bottom_sheet.dart';
import 'package:flip_health/model/dashboard%20models/service_model.dart';
import 'package:flip_health/routes/app_routes.dart';

class DashboardController extends GetxController {
//all text editing controllers
  final TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;


  List<ServiceModel> get services => [
    ServiceModel(
      title: AppString.kDiagnostics,
      subtitle: AppString.kSameDaySlotBooking,
      badgeText: AppString.kUpTo20OffDiagnostics,
      imagePath: AppString.kDashboardMicroscope,
      onPressed: () {
        onTapDaignosticsCard(Get.context!);
      },
    ),
    
  ];
//on tap function for view more button
  void onTapDaignosticsCard(BuildContext context) {
    final items = [
      ServiceCardData(
        iconPath: AppString.kIconDiagnostics,
        title: AppString.kHealthCheckups,
        subtitle: AppString.kHealthCheckupsSubtitle,
        onTap: () {
          Get.back();
          Get.toNamed(AppRoutes.healthCheckups);
        },
        subtitleIconPath: AppString.kIconFreeHealthCheckups,
      ),
      ServiceCardData(
        iconPath: AppString.kIconLabTests,
        title: AppString.kLabTests,
        subtitle: AppString.kLabTestsSubtitle,
        onTap: () {
          // Handle Lab Tests tap
          Navigator.pop(context);
        },
        subtitleIconPath: AppString.kIconFullSponsored,
      ),
    ];

    CommonBottomSheet.show(
      context: context,
      title: AppString.kDiagnostics,
      items: items,
      maxHeight: ResponsiveHelper.screenHeight * 0.65,
    );
  }
  }
