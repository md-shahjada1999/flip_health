import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/vision/vision_overview_screen.dart';
import 'dart:io';

class VisionPrescriptionScreen extends GetView<VisionController> {
  const VisionPrescriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        Icon(Icons.upload_file, size: 48.rs, color: AppColors.primary),
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadOption(
                          icon: Icons.photo_library_outlined,
                          label: AppString.kUploadFromGallery,
                          onTap: controller.pickFromGallery,
                        ),
                      ),
                      SizedBox(width: 16.rw),
                      Expanded(
                        child: _buildUploadOption(
                          icon: Icons.camera_alt_outlined,
                          label: AppString.kTakePhoto,
                          onTap: controller.pickFromCamera,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.rh),
                  CommonText(
                    AppString.kUploadedPrescriptions,
                    fontSize: 16.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 16.rh),
                  Obx(() {
                    if (controller.uploadedFiles.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 40.rh),
                        child: Column(
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 48.rs, color: AppColors.borderLight),
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.rw,
                        mainAxisSpacing: 12.rh,
                      ),
                      itemCount: controller.uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final file = controller.uploadedFiles[index];
                        return _buildFileCard(file, index);
                      },
                    );
                  }),
                  SizedBox(height: 80.rh),
                ],
              ),
            ),
          ),
          ActionButton(
            text: AppString.kContinue,
            onPressed: () => Get.to(() => const VisionOverviewScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.rh),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.rs, color: AppColors.primary),
            SizedBox(height: 8.rh),
            CommonText(
              label,
              fontSize: 12.rf,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file, int index) {
    final isImage = file['isImage'] == true;
    final path = file['path'] as String? ?? '';

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: isImage && path.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.rs),
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _buildFileFallback(file),
                  ),
                )
              : _buildFileFallback(file),
        ),
        Positioned(
          top: 4.rh,
          right: 4.rw,
          child: GestureDetector(
            onTap: () => controller.removePrescriptionFile(index),
            child: Container(
              width: 22.rs,
              height: 22.rs,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 14.rs),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileFallback(Map<String, dynamic> file) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 32.rs, color: AppColors.textSecondary),
          SizedBox(height: 6.rh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.rw),
            child: CommonText(
              file['name'] ?? '',
              fontSize: 9.rf,
              color: AppColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
