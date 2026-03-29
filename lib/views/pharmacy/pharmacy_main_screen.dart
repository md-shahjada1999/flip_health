import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/pharmacy%20controllers/pharmacy_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/pharmacy/pharmacy_prescription_screen.dart';

class PharmacyMainScreen extends GetView<PharmacyController> {
  const PharmacyMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: const LocationHeaderBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.rh),
            _buildHeroSection(),
            _buildDeliveryNote(),
            _buildUploadPrescriptionSection(),
            SizedBox(height: 10.rh),
            _buildOTCSection(context),
            _buildFAQSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 220.rh,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Stack(
        children: [
          Positioned(
            top: 8.rh,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  AppString.kFlipHealthDelivery,
                  fontSize: 16.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                SizedBox(height: 24.rh),
                _buildFeatureRow(AppString.kSecureHomeDelivery),
                SizedBox(height: 8.rh),
                _buildFeatureRow(AppString.kDeliveryInHours),
                SizedBox(height: 8.rh),
                _buildFeatureRow(AppString.kContactlessDelivery),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 16.rh,
            child: Container(
              width: 140.rs,
              height: 140.rs,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16.rs),
              ),
              child: Icon(Icons.local_pharmacy, size: 64.rs, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.chevron_right, size: 20.rs, color: AppColors.primary),
        SizedBox(width: 4.rw),
        CommonText(
          text,
          fontSize: 12.rf,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildDeliveryNote() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 8.rh),
      child: CommonText(
        AppString.kMedicineDeliveryNote,
        fontSize: 10.rf,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildUploadPrescriptionSection() {
    return Container(
      color: AppColors.primaryLight,
      padding: EdgeInsets.all(18.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kUploadPrescriptionTitle,
            fontSize: 18.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 8.rh),
          CommonText(
            AppString.kPrescriptionIsSafe,
            fontSize: 10.rf,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 20.rh),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.prescriptionSource.value = 'OTHER';
                    Get.to(() => const PharmacyPrescriptionScreen());
                  },
                  child: _buildUploadCard(
                    AppString.kUploadImage,
                    AppString.kUpload,
                  ),
                ),
              ),
              SizedBox(width: 16.rw),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.prescriptionSource.value = 'FLIPHEALTH';
                    Get.to(() => const PharmacyPrescriptionScreen());
                  },
                  child: _buildUploadCard(
                    AppString.kFlipHealthPrescription,
                    AppString.kSelect,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(String title, String buttonText) {
    return Container(
      height: 120.rh,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.rs),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.rw),
            child: CommonText(
              title,
              fontSize: 12.rf,
              color: AppColors.primary,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 8.rh),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(5.rs),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  buttonText,
                  fontSize: 12.rf,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(width: 4.rw),
                Icon(Icons.file_upload_outlined, size: 18.rs, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTCSection(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      padding: EdgeInsets.all(18.rs),
      child: Row(
        children: [
          Icon(Icons.chevron_right, size: 24.rs, color: AppColors.primary),
          SizedBox(width: 8.rw),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.navigateToOTC,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.rh),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.rs),
                ),
                elevation: 0,
              ),
              child: CommonText(
                AppString.kRequestOTCProducts,
                fontSize: 16.rf,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(18.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kFAQ,
            fontSize: 16.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 10.rh),
          Obx(() => Column(
                children: controller.faqItems.map((faq) {
                  return Theme(
                    data: ThemeData(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      textColor: AppColors.primary,
                      iconColor: AppColors.primary,
                      collapsedTextColor: AppColors.textPrimary,
                      tilePadding: EdgeInsets.zero,
                      title: CommonText(
                        faq.question,
                        fontSize: 14.rf,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.rh),
                          child: CommonText(
                            faq.answer,
                            fontSize: 12.rf,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Divider(color: AppColors.borderLight),
                      ],
                    ),
                  );
                }).toList(),
              )),
          SizedBox(height: 10.rh),
        ],
      ),
    );
  }
}
