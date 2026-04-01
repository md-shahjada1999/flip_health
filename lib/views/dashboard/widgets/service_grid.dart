import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ResponsiveScreen;
import 'package:flip_health/controllers/dashboard%20controllers/dashboard_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/model/dashboard%20models/service_model.dart';
import 'package:flip_health/views/dashboard/widgets/service_card.dart';

class ServicesGrid extends StatelessWidget {
  final List<ServiceModel> services;

  const ServicesGrid({
    Key? key,
    required this.services,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    // Calculate card dimensions
    double cardWidth = (ResponsiveHelper.screenWidth - (20 * 2).rs - 12.rs) / 2;
    double cardHeight = 130.rh;

    return ResponsiveScreen(
      child: Column(
        children: [
          // Large service card (Diagnostics) - Full width with service options
          if (services.isNotEmpty)
            ServiceCard(
              title: services[0].title,
              subtitle: services[0].subtitle,
              badgeText: services[0].badgeText,
              imagePath: services[0].imagePath,
              backgroundColor: services[0].backgroundColor,
              onPressed: services[0].onPressed,
              isLarge: true,
              showServiceOptions: true,
              
            ),

          RSizedBox.vertical(12),

          // First Row: Consultation and Dental
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: CommonDashboardServiceCard(
                  title: AppString.kConsultation,
                  subtitle: AppString.kInstantAppointment,
                  badgeText: AppString.k10Mins,
                  imagePath: AppString.kDashboardDoctor,
                  hasGradientBorder: true,
                  badgeBackgroundColor: AppColors.textPrimary,
                  featureRows: [
                    ServiceFeatureRow(
                      features: [
                        ServiceFeature(
                          iconPath: AppString.kVirtualIcon,
                          label: AppString.kVirtual,
                          iconColor: Colors.green.shade600,
                        ),
                        ServiceFeature(
                          iconPath: AppString.kCenterIcon,
                          label: AppString.kAtCenterService,
                          iconColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                  onPressed: () => Get.find<DashboardController>().onTapConsultationCard(context),
                ),
              ),
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: CommonDashboardServiceCard(
                  title: AppString.kDental,
                  subtitle: AppString.kLoremIpsum,
                  badgeText: AppString.kUpTo30Off,
                  imagePath: AppString.kDashboardDental,
                  // borderColor: Colors.blue,
                  onPressed: () => Get.find<DashboardController>().onTapDentalCard(),
                  isImageSvg: false,
                ),
              ),
            ],
          ),

          RSizedBox.vertical(12),

          // Second Row: Vision and Pharmacy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: CommonDashboardServiceCard(
                  title: AppString.kVision,
                  badgeText: AppString.kUpTo20Off,
                  imagePath: AppString.kDashboardGlasses,
                  // borderColor: Colors.purple,
                  onPressed: () => Get.find<DashboardController>().onTapVisionCard(context),
                ),
              ),
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: CommonDashboardServiceCard(
                  title: AppString.kPharmacy,
                  badgeText: AppString.kUpTo20Off,
                  imagePath: AppString.kDashboardPharmacy,
                  // borderColor: Colors.green,
                  onPressed: () => Get.find<DashboardController>().onTapPharmacyCard(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
