import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/vision/vision_overview_screen.dart';

class VisionPrescriptionScreen extends GetView<VisionController> {
  const VisionPrescriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kUploadPrescription),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.rs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.rs),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.rs),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.upload_file,
                            size: 48.rs, color: AppColors.primary),
                        SizedBox(height: 12.rh),
                        CommonText(
                          AppString.kUploadPrescription,
                          fontSize: 16.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 4.rh),
                        CommonText(
                          AppString.kPrescriptionSafe,
                          fontSize: 12.rf,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.rh),
                  Obx(() {
                    if (controller.prescriptionUploading.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.rh),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: controller.pickPrescription,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 20.rh),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.rs),
                          border: Border.all(
                              color: AppColors.primary, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 32.rs, color: AppColors.primary),
                            SizedBox(height: 8.rh),
                            CommonText(
                              'Tap to upload prescription',
                              fontSize: 13.rf,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 32.rh),
                  CommonText(
                    AppString.kUploadedPrescriptions,
                    fontSize: 16.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 16.rh),
                  Obx(() {
                    if (controller.prescriptionFiles.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 40.rh),
                        child: Column(
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 48.rs,
                                color: AppColors.borderLight),
                            SizedBox(height: 12.rh),
                            CommonText(
                              AppString.kNoPrescriptionsYet,
                              fontSize: 14.rf,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.rw,
                        mainAxisSpacing: 12.rh,
                      ),
                      itemCount: controller.prescriptionFiles.length,
                      itemBuilder: (context, index) {
                        final file = controller.prescriptionFiles[index];
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundTertiary,
                                borderRadius:
                                    BorderRadius.circular(12.rs),
                                border: Border.all(
                                    color: AppColors.borderLight),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(4.rs),
                                  child: FilePickerHelper
                                      .buildFilePreview(file),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4.rh,
                              right: 4.rw,
                              child: GestureDetector(
                                onTap: () =>
                                    controller.removePrescription(index),
                                child: Container(
                                  width: 22.rs,
                                  height: 22.rs,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 14.rs),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                  SizedBox(height: 80.rh),
                ],
              ),
            ),
          ),
          Obx(() => controller.prescriptionFiles.isNotEmpty
              ? SafeBottomPadding(
                  child: ActionButton(
                    text: AppString.kContinue,
                    onPressed: () =>
                        Get.to(() => const VisionOverviewScreen()),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
