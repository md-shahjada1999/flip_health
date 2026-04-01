import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/dental/widgets/vendor_card.dart';
import 'package:flip_health/views/vision/vision_slot_selection_screen.dart';

class VisionVendorsScreen extends GetView<VisionController> {
  const VisionVendorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: controller.vendorListTitle),
      body: Column(
        children: [
          const LocationHeaderBar(),
          Expanded(
            child: Obx(() {
              if (controller.vendorsLoading.value) {
                return Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.vendors.isEmpty) {
                return Center(
                  child: CommonText(
                    controller.isEyeCheckup
                        ? 'No hospitals found at this location'
                        : 'No stores found at this location',
                    fontSize: 14.rf,
                    color: AppColors.textSecondary,
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(18.rs),
                itemCount: controller.vendors.length,
                itemBuilder: (context, index) {
                  final vendor = controller.vendors[index];
                  return Obx(() => VendorCard(
                        vendor: vendor,
                        isSelected: controller.selectedVendorId.value == vendor.id,
                        onTap: () => controller.selectVendor(vendor.id),
                      ));
                },
              );
            }),
          ),
          Obx(() => controller.selectedVendorId.value.isNotEmpty
              ? ActionButton(
                  text: AppString.kContinue,
                  onPressed: () {
                    controller.continueToSlots();
                    Get.to(() => const VisionSlotSelectionScreen());
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
