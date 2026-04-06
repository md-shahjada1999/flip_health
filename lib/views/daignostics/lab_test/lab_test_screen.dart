import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/heath%20checkup%20models/lab_test_model.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/daignostics/widgets/my_orders_button.dart';

class LabTestScreen extends GetView<LabTestController> {
  const LabTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      appBar: CommonAppBar.build(
        title: 'Lab Tests',
        showBackButton: true,
        actions: [const MyOrdersButton()],
      ),
      body: Column(
        children: [
          const LocationHeaderBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.rh),
                  _buildSearchBar(),
                  SizedBox(height: 24.rh),
                  _buildPopularLabTests(),
                  SizedBox(height: 24.rh),
                  _buildTopLabsSection(),
                  SizedBox(height: 40.rh),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rs),
      child: GestureDetector(
        onTap: controller.goToSearchScreen,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.rs, vertical: 14.rs),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(color: AppColors.borderLight),
            
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.textTertiary, size: 22.rs),
              SizedBox(width: 12.rw),
              Expanded(
                child: CommonText(
                  'Search and book lab tests',
                  fontSize: 14.rf,
                  color: AppColors.textQuaternary,
                ),
              ),
              Icon(Icons.mic, color: AppColors.primary, size: 22.rs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularLabTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.rs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                'Popular Lab Tests',
                fontSize: 18.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              SizedBox(height: 4.rh),
              CommonText(
                'Best in class service rating',
                fontSize: 11.rf,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.rh),
        SizedBox(
          height: 140.rh,
          child: Obx(() => PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.85),
                itemCount: controller.popularPackages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 16.rw : 8.rw,
                      right: 8.rw,
                    ),
                    child: _buildPackageCard(controller.popularPackages[index]),
                  );
                },
              )),
        ),
      ],
    );
  }

  Widget _buildPackageCard(LabPackageModel package) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.rs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  package.name,
                  fontSize: 12.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1,
                  maxLines: 2,
                ),
                SizedBox(height: 8.rh),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      CommonText(
                        "See what's included",
                        fontSize: 10.rf,
                        color: AppColors.accent,
                        decoration: TextDecoration.underline,
                        style: const TextStyle(
                          decorationColor: AppColors.accent,
                          decorationThickness: 1.5,
                        ),
                      ),
                      SizedBox(width: 4.rw),
                      Icon(Icons.arrow_forward_ios,
                          size: 8.rs, color: AppColors.accent),
                    ],
                  ),
                ),
                SizedBox(height: 8.rh),
                Row(
                  children: [
                    CommonText(
                      '₹ ${package.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      fontSize: 16.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                    SizedBox(width: 4.rw),
                    CommonText(
                      '·',
                      fontSize: 18.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.rs,
                          vertical: 8.rs,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.rs),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: CommonText(
                          'Add to cart',
                          fontSize: 10.rf,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6.rh, horizontal: 16.rw),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(11.rs),
                bottomRight: Radius.circular(11.rs),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppString.kHomeIcon,
                  width: 8.rw,
                  height: 8.rh,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.rw),
                CommonText(
                  'Home Collection',
                  fontSize: 8.rf,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLabsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            'Top Labs, Trusted Care',
            fontSize: 16.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          SizedBox(height: 16.rh),
          Container(
            padding: EdgeInsets.all(16.rs),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.rs),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: AppColors.warning, size: 28.rs),
                    SizedBox(width: 8.rw),
                    CommonText(
                      '4.5 Avg. user rating',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ],
                ),
                SizedBox(height: 16.rh),
                _buildFeatureRow(
                  Icons.access_time,
                  'Reports within 48 hours',
                  AppColors.warning,
                ),
                SizedBox(height: 10.rh),
                _buildFeatureRow(
                  Icons.bolt,
                  'Instant confirmation',
                  AppColors.primary,
                ),
                SizedBox(height: 10.rh),
                _buildFeatureRow(
                  Icons.check,
                  'From the comfort of your home',
                  AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 16.rs, color: iconColor),
        SizedBox(width: 12.rw),
        CommonText(
          text,
          fontSize: 13.rf,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
