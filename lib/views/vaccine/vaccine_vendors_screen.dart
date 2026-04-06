import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/vaccine%20controllers/vaccine_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/dental/widgets/vendor_card.dart';
import 'package:flip_health/views/vaccine/vaccine_slot_selection_screen.dart';

class VaccineVendorsScreen extends GetView<VaccineController> {
  const VaccineVendorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kVaccinationCenter),
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
                    AppString.kNoClinicFound,
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
              ? SafeBottomPadding(
                  child: ActionButton(
                    text: AppString.kContinue,
                    onPressed: () {
                      controller.continueToSlots();
                      Get.to(() => const VaccineSlotSelectionScreen());
                    },
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
