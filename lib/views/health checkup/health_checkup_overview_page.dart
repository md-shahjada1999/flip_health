import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/health_checkup_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/font_style.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';

class HealthCheckupOverviewScreen extends StatelessWidget {
  const HealthCheckupOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HealthCheckupsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(
        title: AppString.kHealthCheckupsTitle,
        showBackButton: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.rw),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 6.rh),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderDark, width: 0.7),
                borderRadius: BorderRadius.circular(20.rs),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(AppString.kShoppingBagIcon, width: 12.rs),
                  SizedBox(width: 4.rw),
                  CommonText(
                    AppString.kMyOrders,
                    fontSize: 10.rf,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Location Header
          _buildLocationHeader(),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.rh),

                  // Added Items Section
                  _buildAddedItemsSection(controller),

                  SizedBox(height: 24.rh),

                  // Phone Number Section
                  _buildPhoneNumberSection(controller),

                  SizedBox(height: 20.rh),

                  // Alternate Phone Number Section
                  _buildAlternatePhoneSection(controller),

                  SizedBox(height: 20.rh),

                  // Date and Time Section
                  _buildDateTimeSection(controller),

                  SizedBox(height: 24.rh),

                  // Price Breakdown Section
                  _buildPriceBreakdown(controller),

                  SizedBox(height: 16.rh),

                  // Flip Coins Section
                  _buildFlipCoinsSection(controller),

                  SizedBox(height: 16.rh),

                  // Remarks Section
                  _buildRemarksSection(),

                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ),

          // Bottom Confirm Button
          _buildBottomButton(controller),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 12.rh),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20.rs,
          ),
          SizedBox(width: 8.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  AppString.kHome,
                  fontSize: 14.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        'Isprout, 7th floor, Plot No: 25, Divyasree trinity,',
                        fontSize: 12.rf,
                        color: AppColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16.rs,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedItemsSection(HealthCheckupsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            '${AppString.kAddedItems}(1)',
            fontSize: 14.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
          SizedBox(height: 10.rh),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      AppString.kEmployeeAnnualHealthCheckup,
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    SizedBox(height: 4.rh),
                    CommonText(
                      AppString.kForPatient('Kalyan'),
                      fontSize: 11.rf,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              CommonText(
                '₹ 4,000',
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

  Widget _buildPhoneNumberSection(HealthCheckupsController controller) {
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

  Widget _buildAlternatePhoneSection(HealthCheckupsController controller) {
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
                        color: AppColors.textSecondary.withOpacity(0.5),
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

  Widget _buildDateTimeSection(HealthCheckupsController controller) {
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
                CommonText(
                  'April 10, 2024 | 2PM-3PM',
                  fontSize: 12.rf,
                  color: AppColors.textPrimary,
                ),
                Icon(
                  Icons.edit,
                  size: 20.rs,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(HealthCheckupsController controller) {
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
          // Total MRP
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
                '₹ 4,000',
                fontSize: 14.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ],
          ),
          SizedBox(height: 10.rh),

          // Home Collection Charges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                AppString.kHomeCollectionCharges,
                fontSize: 12.rf,
                color: AppColors.textPrimary,
              ),
              CommonText(
                '₹ 80',
                fontSize: 12.rf,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 10.rh),

          // From Wallet
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
                '₹ 4,000',
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

          // Net Pay
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
              Row(
                children: [
                  CommonText(
                    '₹ 4,080',
                    fontSize: 12.rf,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                  SizedBox(width: 8.rw),
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
        ],
      ),
    );
  }

  Widget _buildFlipCoinsSection(HealthCheckupsController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.rw),
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withOpacity(0.3),
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
              Container(
                width: 20.rs,
                height: 20.rs,
                child: Center(
                  child: SvgPicture.asset(
                    AppString.kFlipCoinIcon,
                    width: 18.rs,
                    height: 18.rs,
                  ),
                ),
              ),
              SizedBox(width: 4.rw),
              CommonText(
                '400',
                fontSize: 16.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              SizedBox(width: 4.rw),
              CommonText(
                AppString.kFlipCoinsWorth('40'),
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
      width: double.infinity ,
      margin: EdgeInsets.symmetric(horizontal: 20.rw),
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withOpacity(0.5),
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

  Widget _buildBottomButton(HealthCheckupsController controller) {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price Display
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.rw,
              vertical: 12.rh,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.rs),
            ),
            child: Row(
              children: [
                CommonText(
                  '₹',
                  fontSize: 18.rf,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.3,
                ),
                SizedBox(width: 4.rw),
                CommonText(
                  '1000',
                  fontSize: 18.rf,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.rw),

          // Confirm Button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                controller.confirmBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16.rh),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.rs),
                ),
              ),
              child: CommonText(
                AppString.kConfirmAndPay,
                fontSize: 15.rf,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
