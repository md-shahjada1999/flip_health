import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/dental%20controllers/dental_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_dialog.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class DentalOverviewScreen extends GetView<DentalController> {
  const DentalOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kDentalOverview),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LocationHeaderBar(),
                  SizedBox(height: 20.rh),
                  _buildVendorDetails(),
                  SizedBox(height: 20.rh),
                  Divider(color: AppColors.borderLight, thickness: 0.5),
                  SizedBox(height: 20.rh),
                  _buildAddedItems(),
                  SizedBox(height: 20.rh),
                  Divider(color: AppColors.borderLight, thickness: 0.5),
                  SizedBox(height: 20.rh),
                  _buildPhoneSection(),
                  SizedBox(height: 20.rh),
                  _buildDateTimeSection(context),
                  SizedBox(height: 20.rh),
                  Divider(color: AppColors.borderLight, thickness: 0.5),
                  SizedBox(height: 20.rh),
                  _buildPricingSummary(),
                  SizedBox(height: 20.rh),
                  _buildRemarks(),
                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ),
          Obx(() => SafeBottomPadding(
                child: ActionButton(
                  text: AppString.kConfirm,
                  onPressed: () => _confirmAndBook(),
                  isLoading: controller.confirmBookingLoading.value,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildVendorDetails() {
    final vendor = controller.selectedVendor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            vendor?.name ?? '',
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 4.rh),
          CommonText(
            '${vendor?.address ?? ''}, ${vendor?.city ?? ''}',
            fontSize: 10.rf,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddedItems() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: '${AppString.kAddedItems} ',
                style: TextStyle(
                  fontSize: 14.rf,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: '(1)',
                style: TextStyle(
                  fontSize: 14.rf,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ]),
          ),
          SizedBox(height: 12.rh),
          CommonText(
            AppString.kDentalComprehensiveCheckup,
            fontSize: 14.rf,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 4.rh),
          Obx(() => CommonText(
            'For ${Get.find<MemberController>().selectedMember?.name ?? ''}',
            fontSize: 12.rf,
            color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _buildPhoneSection() {
    final mc = Get.find<MemberController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final raw = mc.selectedMember?.phone?.trim() ?? '';
            final display = raw.isEmpty
                ? '—'
                : (raw.startsWith('+') ? raw : '+91 $raw');
            return RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: '${AppString.kPhoneNumber}: ',
                  style: TextStyle(
                    fontSize: 14.rf,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: display,
                  style: TextStyle(
                    fontSize: 14.rf,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ]),
            );
          }),
          SizedBox(height: 4.rh),
          CommonText(
            AppString.kBookingUpdatesNote,
            fontSize: 10.rf,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.rh),
          CommonText(
            AppString.kAlternatePhoneNumber,
            fontSize: 14.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 8.rh),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8.rs),
            ),
            height: 48.rh,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.rw),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    border: Border(right: BorderSide(color: AppColors.border)),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.rs),
                      bottomLeft: Radius.circular(8.rs),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: CommonText('+91', fontSize: 13.rf, color: AppColors.textSecondary),
                ),
                Expanded(
                  child: TextField(
                    controller: controller.alternatePhoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14.rf),
                    decoration: InputDecoration(
                      hintText: AppString.kEnterAlternateNumber,
                      hintStyle: TextStyle(
                        color: AppColors.border,
                        fontSize: 12.rf,
                        fontFamily: 'Poppins',
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.rw),
                      border: InputBorder.none,
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

  Widget _buildDateTimeSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kDateAndTime,
            fontSize: 14.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 8.rh),
          Obx(() => GestureDetector(
                onTap: () => _showSlotEditBottomSheet(context),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8.rs),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 14.rh),
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonText(
                          controller.selectedDateTimeDisplay.value.isNotEmpty
                              ? controller.selectedDateTimeDisplay.value
                              : 'Select date and time',
                          fontSize: 14.rf,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Icon(Icons.edit_outlined, color: AppColors.info, size: 24.rs),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showSlotEditBottomSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.rs)),
        ),
        padding: EdgeInsets.all(18.rs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 28.rs,
                  height: 28.rs,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.backgroundTertiary),
                  child: Icon(Icons.close, size: 18.rs, color: AppColors.textSecondary),
                ),
              ),
            ),
            SizedBox(height: 16.rh),
            Obx(() => CommonSlotSelector(
                  monthYearLabel: controller.monthYearLabel.value,
                  availableDates: controller.availableDates.toList(),
                  selectedDateIndex: controller.selectedDateIndex.value,
                  onDateSelected: controller.selectDate,
                  selectedTimeSlot: controller.selectedTimeSlot.value,
                  onTimeSlotSelected: (time) {
                    controller.selectTimeSlot(time);
                  },
                  morningSlots: controller.morningSlots.toList(),
                  afternoonSlots: controller.afternoonSlots.toList(),
                  eveningSlots: controller.eveningSlots.toList(),
                )),
            SizedBox(height: 16.rh),
            Obx(() => controller.selectedTimeSlot.value.isNotEmpty
                ? ActionButton(
                    text: AppString.kConfirm,
                    onPressed: () => Get.back(),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Column(
        children: [
          _priceRow(AppString.kTotalMRP, '₹ 0'),
          SizedBox(height: 8.rh),
          _priceRow(AppString.kFromWallet, '₹ 0', valueColor: AppColors.error),
          SizedBox(height: 12.rh),
          Divider(color: AppColors.borderLight, thickness: 0.5),
          SizedBox(height: 12.rh),
          _priceRow(AppString.kNetPay, '₹ 0', isBold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(
          label,
          fontSize: isBold ? 16.rf : 14.rf,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        CommonText(
          value,
          fontSize: 16.rf,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: valueColor ?? AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildRemarks() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.rs),
        color: AppColors.backgroundTertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              AppString.kRemarksLabel,
              fontSize: 10.rf,
              color: AppColors.error,
            ),
            SizedBox(height: 4.rh),
            CommonText(
              AppString.kOrderCannotBeCancelled,
              fontSize: 10.rf,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndBook() async {
    final confirmed = await CommonDialog.confirm(
      title: 'Confirm Booking',
      message: 'Are you sure you want to confirm this dental appointment?',
      confirmText: 'Book Now',
      cancelText: 'Go Back',
    );
    if (confirmed == true) controller.confirmBooking();
  }
}
