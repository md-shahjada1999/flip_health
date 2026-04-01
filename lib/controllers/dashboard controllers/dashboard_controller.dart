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
          Get.back();
          Get.toNamed(AppRoutes.labTests);
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

  void onTapDentalCard() {
    Get.toNamed(AppRoutes.dental);
  }

  void onTapVisionCard(BuildContext context) {
    final items = [
      ServiceCardData(
        iconPath: 'assets/svg/eyecheck.svg',
        title: 'Eye Checkup',
        subtitle: 'Comprehensive eye examination',
        onTap: () {
          Get.back();
          Get.toNamed(AppRoutes.vision, arguments: 'eye_checkup');
        },
        subtitleIconPath: AppString.kIconFreeHealthCheckups,
      ),
      ServiceCardData(
        iconPath: 'assets/svg/Lens.svg',
        title: 'Glasses/Lens',
        subtitle: 'Browse glasses & contact lenses',
        onTap: () {
          Get.back();
          Get.toNamed(AppRoutes.vision, arguments: 'glasses_lens');
        },
        subtitleIconPath: AppString.kIconFreeHealthCheckups,
      ),
    ];

    CommonBottomSheet.show(
      context: context,
      title: AppString.kVision,
      items: items,
      maxHeight: ResponsiveHelper.screenHeight * 0.65,
    );
  }

  void onTapPharmacyCard() {
    Get.toNamed(AppRoutes.pharmacy);
  }

  void onTapConsultationCard(BuildContext context) {
    final items = [
      ServiceCardData(
        iconPath: AppString.kIconConsultation,
        title: 'At Hospital',
        subtitle: 'Book Your OPD Consultations Here',
        onTap: () {
          Get.back();
          Get.toNamed(AppRoutes.consultation, arguments: 'hospital');
        },
        subtitleIconPath: AppString.kIconFreeHealthCheckups,
      ),
      ServiceCardData(
        iconPath: AppString.kVirtualIcon,
        title: 'Virtual',
        subtitle: 'Connecting Care, Virtually Everywhere',
        onTap: () {
          Get.back();
          Get.toNamed(AppRoutes.consultation, arguments: 'virtual');
        },
        subtitleIconPath: AppString.kIconFreeHealthCheckups,
      ),
    ];

    CommonBottomSheet.show(
      context: context,
      title: AppString.kConsultation,
      items: items,
      maxHeight: ResponsiveHelper.screenHeight * 0.65,
    );
  }
}
