import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/pharmacy%20controllers/pharmacy_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_dialog.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';
import 'package:flip_health/views/pharmacy/pharmacy_prescription_screen.dart';
import 'package:flip_health/views/common/family_member_dropdown.dart';

class PharmacyMainScreen extends GetView<PharmacyController> {
  const PharmacyMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            BackButton(),
            Expanded(child: LocationHeaderBar()),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.rh),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.rw),
              child: Obx(
                () => FamilyMemberDropdown(
                  label: AppString.kOrderingFor,
                  showRequiredMark: false,
                  members: controller.members,
                  isLoading: controller.membersLoading.value,
                  selectedMemberId: controller.selectedMemberId.value,
                  onSelected: controller.selectMember,
                ),
              ),
            ),
            SizedBox(height: 16.rh),
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
      height: 160 .rh,
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
            top: 0,
            right: 0,
            child: Container(
              width: 140.rs,
              height: 140.rs,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16.rs),
              ),
              child: Image.asset(AppString.kMedicineDeliveryImage),
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
        CommonText(text, fontSize: 12.rf, color: AppColors.textPrimary),
      ],
    );
  }

  Widget _buildDeliveryNote() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 4.rh),
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
            children: [
              Expanded(
                child: _buildIllustrationCard(
                  title: AppString.kUploadImage,
                  buttonText: AppString.kUpload,
                  imagePath: AppString.kUploadPrescriptionImage,
                  onTap: () {
                    controller.prescriptionSource.value = 'OTHER';
                    controller.resetUploadState();
                    Get.to(() => const PharmacyPrescriptionScreen());
                  },
                ),
              ),
              SizedBox(width: 14.rw),
              Expanded(
                child: _buildIllustrationCard(
                  title: AppString.kFlipHealthPrescription,
                  buttonText: AppString.kSelect,
                  imagePath: AppString.kFlipHealthPrescriptionImage,
                  onTap: () {
                    controller.prescriptionSource.value = 'FLIPHEALTH';
                    controller.resetFlipHealthState();
                    controller.fetchPrescriptions();
                    Get.to(() => const PharmacyPrescriptionScreen());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationCard({
    required String title,
    required String buttonText,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.rw,
        height: 200.rh,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.rs),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.rs)),
              child: Image.asset(
                imagePath,
                height: 100.rh,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
                Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.rw, vertical: 10.rh),
              child: Column(
                children: [
                  CommonText(
                    title,
                    fontSize: 12.rf,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                  ),
              
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.rh),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.rs),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText(
                          buttonText,
                          fontSize: 12.rf,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(width: 4.rw),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14.rs, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTCSection(BuildContext context) {
    return GestureDetector(
      onTap: controller.isOrdering.value ? null : _handleOTCOrder,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18.rw),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.rs),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(14.rs)),
              child: Image.asset(
                AppString.kOTCProductsImage,
                height: 100.rh,
                width: 110.rw,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 12.rw),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.rh),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      AppString.kRequestOTCProducts,
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 4.rh),
                    CommonText(
                      'No prescription needed',
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 10.rh),
                    Obx(() => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.rw, vertical: 8.rh),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8.rs),
                          ),
                          child: controller.isOrdering.value
                              ? SizedBox(
                                  height: 16.rs,
                                  width: 16.rs,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CommonText(
                                      'Order Now',
                                      fontSize: 12.rf,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    SizedBox(width: 4.rw),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: 14.rs, color: Colors.white),
                                  ],
                                ),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.rw),
          ],
        ),
      ),
    );
  }

  void _handleOTCOrder() async {
    final confirmed = await CommonDialog.confirm(
      title: AppString.kRequestOTCProducts,
      message: AppString.kOTCOrderConfirm,
      confirmText: 'Place Order',
      icon: Icons.shopping_bag_outlined,
    );
    if (confirmed == true) {
      controller.placeOTCOrder();
    }
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
