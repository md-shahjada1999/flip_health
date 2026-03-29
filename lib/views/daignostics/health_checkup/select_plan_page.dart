import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';

class SelectPlanPage extends StatelessWidget {
  const SelectPlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthCheckupsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: AppString.kHealthCheckupsTitle,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        return Column(
          children: [
            // Location Header
            _buildLocationHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.rh),

                    // Health Package Card
                    _buildHealthPackageCard(),
                  ],
                ),
              ),
            ),

            // Bottom Continue Button
            _buildBottomButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 12.rh),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20.rs,
          ),
          SizedBox(width: 8.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Home',
                  fontSize: 14.rf,
                  color: AppColors.textPrimary,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        'Isprout, 7th floor, Plot No: 25, Divyasree trinity,',
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16.rs,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPackageCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.rw),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Free badge
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.rs, vertical: 6.rs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonText(
                    'Flip health AHC 2025-2026',
                    fontSize: 15.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.rw,
                    vertical: 2.rh,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12.rs),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppString.kIconFreeHealthCheckups,
                        width: 10.rw,
                        height: 10.rh,
                        color: AppColors.textOnPrimary,
                      ),
                      SizedBox(width: 4.rw),
                      CommonText(
                        'Free',
                        fontSize: 10.rf,
                        color: AppColors.textOnPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // See what's included link
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.rw),
            child: GestureDetector(
              onTap: () {
                // Navigate to package details
              },
              child: Row(
                children: [
                  CommonText(
                    'See what\'s included',
                    fontSize: 12.rf,
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                    style: TextStyle(
                      decorationColor: AppColors.accent,
                      decorationThickness: 1.5,
                    ),
                  ),
                  SizedBox(width: 4.rw),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.rs,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.rh),

          // Features
          Container(
            margin: EdgeInsets.symmetric(horizontal: 14.rw),
            height: 25.rh,width: 220.rw,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xffF4F4F4),
                Color(0xff000000),
              ]),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
               
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      Icon( Icons.info_outline,color: AppColors.primary,size: 12,),
                      CommonText(
                        'This test requires fasting for 12 hours',
                        fontSize: 10.rf,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //   child: Container(
          //     decoration: BoxDecoration(
          //         border: Border.all(color: AppColors.borderLight, width: 1)),
          //     child: _buildFeatureItem(
          //       Icons.info_outline,
          //       'This test requires fasting for 12 hours',
          //       AppColors.warning,
          //     ),
          //   ),
          // ),
          SizedBox(height: 12.rh),

          _buildFeatureItem(
            Icons.access_time,
            'Reports within 48 hours',
            AppColors.warning.withOpacity(0.7),
            AppString.reportsOntimeIcon,
          ),
          _buildFeatureItem(
            Icons.bolt,
            'Instant confirmation',
            AppColors.primary,
            null,
          ),
          _buildFeatureItem(
            Icons.check,
            'From the comfort of your home',
            AppColors.success,
            null,
          ),

          SizedBox(height: 4.rh),

          // Home Collection Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2.rh,horizontal: 17.rw),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.rs),
                bottomRight: Radius.circular(12.rs),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(AppString.kHomeIcon,
                    width: 10.rw, height: 10.rh, color: Colors.white),
                SizedBox(width: 8.rw),
                CommonText(
                  'Home Collection',
                  fontSize: 9.rf,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color iconColor, String? svgPath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 4.rh),
      child: Row(
        children: [
          svgPath != null
              ? SvgPicture.asset(
                  svgPath,
                  width: 10.rw,
                  height: 10.rh,
                  color: iconColor,
                )
              :
          Icon(
            icon,
            size: 12.rs,
            color: iconColor,
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: CommonText(
              text,
              fontSize: 10.rf,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(HealthCheckupsController controller) {
    return ActionButton(
        text: "Continue", onPressed: controller.continueWithPlanSelection);
  }
}
