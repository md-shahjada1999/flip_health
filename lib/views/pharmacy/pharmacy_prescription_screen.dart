import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/pharmacy%20controllers/pharmacy_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/pharmacy/pharmacy_order_success_screen.dart';
import 'dart:io';

class PharmacyPrescriptionScreen extends GetView<PharmacyController> {
  const PharmacyPrescriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFlipHealth = controller.prescriptionSource.value == 'FLIPHEALTH';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: isFlipHealth ? AppString.kSelectPrescription : AppString.kUploadPrescriptionTitle,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.rs),
              child: isFlipHealth
                  ? _buildFlipHealthSelection()
                  : _buildFileUploadSection(),
            ),
          ),
          Obx(() => controller.selectedFiles.isNotEmpty
              ? ActionButton(
                  text: AppString.kPlaceOrder,
                  onPressed: () => Get.to(() => const PharmacyOrderSuccessScreen()),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.rs),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, size: 56.rs, color: AppColors.primary),
              SizedBox(height: 12.rh),
              CommonText(
                AppString.kUploadPrescriptionTitle,
                fontSize: 16.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 4.rh),
              CommonText(
                AppString.kPrescriptionIsSafe,
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
              child: _buildUploadButton(
                icon: Icons.photo_library_outlined,
                label: AppString.kUploadFromGallery,
                onTap: controller.pickFromGallery,
              ),
            ),
            SizedBox(width: 16.rw),
            Expanded(
              child: _buildUploadButton(
                icon: Icons.camera_alt_outlined,
                label: AppString.kTakePhoto,
                onTap: controller.pickFromCamera,
              ),
            ),
          ],
        ),
        SizedBox(height: 32.rh),
        CommonText(
          AppString.kSelectedFiles,
          fontSize: 16.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 16.rh),
        Obx(() {
          if (controller.selectedFiles.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40.rh),
              child: Column(
                children: [
                  Icon(Icons.image_not_supported_outlined, size: 48.rs, color: AppColors.borderLight),
                  SizedBox(height: 12.rh),
                  CommonText(AppString.kNoFilesSelected, fontSize: 14.rf, color: AppColors.textSecondary),
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
            itemCount: controller.selectedFiles.length,
            itemBuilder: (context, index) {
              final file = controller.selectedFiles[index];
              return _buildFileCard(file, index);
            },
          );
        }),
      ],
    );
  }

  Widget _buildFlipHealthSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          AppString.kFlipHealthPrescription,
          fontSize: 18.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 16.rh),
        Obx(() {
          if (controller.flipHealthPrescriptions.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.rh),
                child: CommonText(
                  AppString.kNoPrescriptionsYet,
                  fontSize: 14.rf,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.flipHealthPrescriptions.length,
            itemBuilder: (context, index) {
              final prescription = controller.flipHealthPrescriptions[index];
              return _buildPrescriptionItem(prescription);
            },
          );
        }),
      ],
    );
  }

  Widget _buildPrescriptionItem(Map<String, dynamic> prescription) {
    return Obx(() {
      final isSelected = controller.isPrescriptionSelected(prescription['id']);
      return GestureDetector(
        onTap: () => controller.toggleFlipHealthPrescription(prescription['id']),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.rh),
          padding: EdgeInsets.all(16.rs),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40.rs,
                height: 40.rs,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8.rs),
                ),
                child: Icon(Icons.description, color: AppColors.primary, size: 24.rs),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      prescription['name'] ?? '',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 4.rh),
                    CommonText(
                      prescription['date'] ?? '',
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              isSelected
                  ? Icon(Icons.check_circle, color: AppColors.primary, size: 24.rs)
                  : Icon(Icons.radio_button_unchecked, color: AppColors.border, size: 24.rs),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildUploadButton({
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
            onTap: () => controller.removeFile(index),
            child: Container(
              width: 22.rs,
              height: 22.rs,
              decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
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
