import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/lab_test_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class LabTestOverviewScreen extends GetView<LabTestController> {
  const LabTestOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lab = controller.selectedLab;

    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(
        title: 'Cart Overview',
        showBackButton: true,
      ),
      body: Column(
        children: [
          const LocationHeaderBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.rh),
                  _buildAddedItemsSection(lab),
                  SizedBox(height: 24.rh),
                  _buildPhoneNumberSection(),
                  SizedBox(height: 20.rh),
                  _buildAlternatePhoneSection(),
                  SizedBox(height: 20.rh),
                  _buildDateTimeSection(),
                  SizedBox(height: 24.rh),
                  _buildPriceBreakdown(lab),
                  SizedBox(height: 16.rh),
                  _buildFlipCoinsSection(),
                  SizedBox(height: 16.rh),
                  _buildRemarksSection(),
                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildAddedItemsSection(dynamic lab) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => CommonText(
                'Added Items(${controller.cartTests.length})',
                fontSize: 14.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.3,
              )),
          SizedBox(height: 4.rh),
          Obx(() => CommonText(
                'For ${Get.find<MemberController>().selectedMember?.name ?? ''}',
                fontSize: 12.rf,
                color: AppColors.textSecondary,
              )),
          SizedBox(height: 10.rh),
          if (lab != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.rs),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  // Lab header
                  Padding(
                    padding: EdgeInsets.all(12.rs),
                    child: Row(
                      children: [
                        Image.asset(
                          lab.logoPath,
                          width: 80.rw,
                          height: 35.rh,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => CommonText(
                            lab.name,
                            fontSize: 12.rf,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.rw),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.rw,
                            vertical: 2.rh,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.warning),
                            borderRadius: BorderRadius.circular(12.rs),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star,
                                  size: 10.rs, color: AppColors.warning),
                              SizedBox(width: 2.rw),
                              CommonText(
                                lab.rating,
                                fontSize: 10.rf,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColors.borderLight),

                  // Test prices
                  ...lab.testPrices.map((tp) => Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.rs, vertical: 8.rs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CommonText(
                                tp.testName,
                                fontSize: 12.rf,
                                color: AppColors.textPrimary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            CommonText(
                              '₹ ${tp.price.toInt()}',
                              fontSize: 12.rf,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      )),

                  // Collection charges
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.rs, vertical: 8.rs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          'Home Collection Charges',
                          fontSize: 12.rf,
                          color: AppColors.textPrimary,
                        ),
                        CommonText(
                          '₹ ${lab.homeCollectionCharge.toInt()}',
                          fontSize: 12.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  // Total
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.rs, vertical: 8.rs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          'To Pay',
                          fontSize: 13.rf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        CommonText(
                          '₹ ${lab.totalPayable.toInt()}',
                          fontSize: 13.rf,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonText(
                AppString.kPhoneNumber,
                fontSize: 14.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              SizedBox(width: 2.rh),
              CommonText(
                ': +91 9999999999',
                fontSize: 12.rf,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 4.rh),
          CommonText(
            AppString.kBookingUpdatesMessage,
            fontSize: 12.rf,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternatePhoneSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kAlternatePhoneNumber,
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          SizedBox(height: 8.rh),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.rs),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.rw,
                    vertical: 12.rh,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: CommonText(
                    '+91',
                    fontSize: 14.rf,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: AppString.kAlternatePhoneHint,
                      hintStyle: TextStyleCustom.normalStyle(
                        fontSize: 14.rf,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.rw,
                        vertical: 14.rh,
                      ),
                    ),
                    style: TextStyleCustom.normalStyle(
                      fontSize: 12.rf,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kDateAndTime,
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          SizedBox(height: 10.rh),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.rw,
              vertical: 14.rh,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.rs),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => CommonText(
                      '${controller.getFormattedSelectedDate()} | ${controller.selectedTimeSlot.value}',
                      fontSize: 12.rf,
                      color: AppColors.textPrimary,
                    )),
                Icon(Icons.edit, size: 20.rs, color: AppColors.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(dynamic lab) {
    if (lab == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20.rs),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                AppString.kTotalMRP,
                fontSize: 14.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              CommonText(
                '₹ ${lab.totalPayable.toInt()}',
                fontSize: 14.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ],
          ),
          SizedBox(height: 14.rh),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    AppString.kFromWallet,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  SizedBox(height: 2.rh),
                  CommonText(
                    AppString.kWalletLimit('4,600'),
                    fontSize: 10.rf,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              CommonText(
                '₹ ${lab.totalPayable.toInt()}',
                fontSize: 13.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                height: 1.3,
              ),
            ],
          ),
          SizedBox(height: 14.rh),
          Divider(height: 1, color: AppColors.borderLight),
          SizedBox(height: 14.rh),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                AppString.kNetPay,
                fontSize: 14.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              CommonText(
                '₹ 0',
                fontSize: 16.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCoinsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.rw),
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.rs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonText(
                AppString.kFlipCoinsToBeEarned,
                fontSize: 11.rf,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 4.rh),
              SvgPicture.asset(
                AppString.kFlipCoinIcon,
                width: 18.rs,
                height: 18.rs,
              ),
              SizedBox(width: 4.rw),
              CommonText(
                '59',
                fontSize: 16.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              SizedBox(width: 4.rw),
              CommonText(
                AppString.kFlipCoinsWorth('6'),
                fontSize: 12.rf,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ],
          ),
          SizedBox(height: 4.rh),
          CommonText(
            AppString.kFlipCoinsNote,
            fontSize: 11.rf,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.rw),
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.rs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kRemarks,
            fontSize: 13.rf,
            color: AppColors.primary,
          ),
          SizedBox(height: 4.rh),
          CommonText(
            AppString.kOrderCancellationWarning,
            fontSize: 13.rf,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeBottomPadding(
        child: SizedBox(
          width: double.infinity,
          height: 52.rh,
          child: ElevatedButton(
            onPressed: controller.confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.rs),
              ),
            ),
            child: CommonText(
              AppString.kConfirmAndPay,
              fontSize: 15.rf,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
