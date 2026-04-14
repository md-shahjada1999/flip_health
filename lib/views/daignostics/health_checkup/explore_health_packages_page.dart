import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class ExploreHealthPackagesPage extends StatefulWidget {
  const ExploreHealthPackagesPage({super.key});

  @override
  State<ExploreHealthPackagesPage> createState() =>
      _ExploreHealthPackagesPageState();
}

class _ExploreHealthPackagesPageState extends State<ExploreHealthPackagesPage> {
  final controller = Get.find<HealthCheckupsController>();

  @override
  void initState() {
    super.initState();
    controller.fetchVendorPricing();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: 'Select Vendor'),
      body: Column(
        children: [
          const LocationHeaderBar(),
          Expanded(child: _buildBody()),
          Obx(() {
            final vp = controller.vendorPricing.value;
            final pathOk = vp == null ||
                !vp.hasSelectablePathology ||
                controller.selectedPathologyVendor.value != null;
            final radOk = vp == null ||
                !vp.hasSelectableRadiology ||
                controller.selectedRadiologyVendor.value != null;

            return ActionButton(
              text: 'Continue to Slots',
              onPressed: pathOk && radOk
                  ? controller.continueToSlotSelection
                  : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isVendorLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final pricing = controller.vendorPricing.value;
      if (pricing == null) {
        return Center(
          child: FadeIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lotties/Scientist.json',
                  width: 180.rs,
                  height: 180.rs,
                  repeat: true,
                ),
                SizedBox(height: 12.rh),
                CommonText(
                  'No vendors available',
                  fontSize: 15.rf,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 8.rh),
                CommonText(
                  'Try changing your address',
                  fontSize: 13.rf,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16.rs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pricing.hasSelectablePathology) ...[
              _buildSectionTitle(
                  'Pathology Vendors', Icons.science_outlined, Colors.blue),
              SizedBox(height: 12.rh),
              ...pricing.pathologyVendors.asMap().entries.map((e) => FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    delay: Duration(milliseconds: 80 * e.key),
                    child: _VendorCard(
                      vendor: e.value,
                      isSelected: controller
                              .selectedPathologyVendor.value?.id ==
                          e.value.id,
                      onTap: () =>
                          controller.selectPathologyVendor(e.value),
                    ),
                  )),
              SizedBox(height: 24.rh),
            ],
            if (pricing.hasSelectableRadiology) ...[
              _buildSectionTitle(
                  'Radiology Vendors', Icons.monitor_heart_outlined, Colors.orange),
              SizedBox(height: 12.rh),
              ...pricing.radiologyVendors.asMap().entries.map((e) => FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    delay: Duration(milliseconds: 80 * e.key),
                    child: _VendorCard(
                      vendor: e.value,
                      isSelected: controller
                              .selectedRadiologyVendor.value?.id ==
                          e.value.id,
                      onTap: () =>
                          controller.selectRadiologyVendor(e.value),
                    ),
                  )),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.rs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.rs),
          ),
          child: Icon(icon, color: color, size: 20.rs),
        ),
        SizedBox(width: 12.rw),
        CommonText(
          title,
          fontSize: 16.rf,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}

class _VendorCard extends StatelessWidget {
  final AhcVendor vendor;
  final bool isSelected;
  final VoidCallback onTap;

  const _VendorCard({
    required this.vendor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(bottom: 12.rh),
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16.rs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Lottie.asset(
                  'assets/lotties/Scientist.json',
                  width: 44.rs,
                  height: 44.rs,
                  repeat: true,
                ),
                SizedBox(width: 10.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        vendor.name,
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.rh),
                      CommonText(
                        vendor.category.capitalizeFirst ?? '',
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CommonText(
                      '₹${vendor.price.toStringAsFixed(0)}',
                      fontSize: 18.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    CommonText(
                      'Total',
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            if (vendor.packages.isNotEmpty) ...[
              SizedBox(height: 12.rh),
              Divider(color: AppColors.borderLight, height: 1),
              SizedBox(height: 10.rh),
              ...vendor.packages.map((vp) => Padding(
                    padding: EdgeInsets.only(bottom: 6.rh),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14.rs, color: AppColors.textSecondary),
                        SizedBox(width: 6.rw),
                        Expanded(
                          child: CommonText(
                            '${vp.user?.name ?? ''} — ${vp.name}',
                            fontSize: 12.rf,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (vp.free)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.rw, vertical: 2.rh),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.rs),
                            ),
                            child: CommonText(
                              'Free',
                              fontSize: 10.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          )
                        else if (vp.pricing != null)
                          CommonText(
                            '₹${vp.pricing!.b2cPrice.toStringAsFixed(0)}',
                            fontSize: 12.rf,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                      ],
                    ),
                  )),
            ],
            SizedBox(height: 8.rh),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
