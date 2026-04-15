import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/vision%20controllers/vision_controller.dart';
import 'package:flip_health/controllers/member%20controllers/member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_dialog.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/common_slot_selector.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';
import 'package:flip_health/core/utils/file_preview_dialog.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/views/daignostics/widgets/location_header_bar.dart';

class VisionOverviewScreen extends GetView<VisionController> {
  const VisionOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      bottomSafe: false,
      appBar: CommonAppBar.build(title: AppString.kVisionOverview),
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
                  Obx(() {
                    if (!controller.isEyeCheckup &&
                        controller.prescriptionFiles.isNotEmpty) {
                      return Column(
                        children: [
                          SizedBox(height: 20.rh),
                          Divider(
                              color: AppColors.borderLight, thickness: 0.5),
                          SizedBox(height: 20.rh),
                          _buildPrescriptionSection(),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
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
          SafeBottomPadding(
            child: Obx(() => ActionButton(
                  text: AppString.kConfirm,
                  onPressed: () => _confirmAndBook(),
                  isLoading: controller.confirmBookingLoading.value,
                )),
          ),
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
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: '(1)',
                style: TextStyle(
                  fontSize: 14.rf,
                  fontFamily: 'Poppins',
                  color: AppColors.textPrimary,
                ),
              ),
            ]),
          ),
          SizedBox(height: 12.rh),
          CommonText(
            controller.isEyeCheckup
                ? AppString.kVisionComprehensiveCheckup
                : AppString.kGlassesLens,
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
            final member = mc.selectedMember;
            String phone = (member?.phone ?? '').trim();
            if (phone.isEmpty) {
              final primary =
                  mc.familyMembers.isNotEmpty ? mc.familyMembers.first : null;
              phone = (primary?.phone ?? '').trim();
            }
            if (phone.isNotEmpty && !phone.startsWith('+91')) {
              phone = '+91 $phone';
            }
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
                  text: phone.isNotEmpty ? phone : '-',
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
          CustomTextField(
            label: AppString.kAlternatePhoneNumber,
            hint: AppString.kEnterAlternateNumber,
            controller: controller.alternatePhoneController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16.rw, right: 8.rw, top: 12.rh),
              child: CommonText('+91',
                  fontSize: 14.rf, color: AppColors.textSecondary),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.rw, vertical: 14.rh),
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
                      Icon(Icons.edit_outlined,
                          color: AppColors.info, size: 24.rs),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showSlotEditBottomSheet(BuildContext context) {
    final prevDateIndex = controller.selectedDateIndex.value;
    final prevTimeSlot = controller.selectedTimeSlot.value;
    final prevDisplay = controller.selectedDateTimeDisplay.value;

    Get.bottomSheet(
      isScrollControlled: true,
      isDismissible: false,
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
                onTap: () {
                  controller.selectedDateIndex.value = prevDateIndex;
                  controller.selectedTimeSlot.value = prevTimeSlot;
                  controller.selectedDateTimeDisplay.value = prevDisplay;
                  Get.back();
                },
                child: Container(
                  width: 28.rs,
                  height: 28.rs,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundTertiary),
                  child: Icon(Icons.close,
                      size: 18.rs, color: AppColors.textSecondary),
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
                  onTimeSlotSelected: controller.selectTimeSlot,
                  morningSlots: controller.morningSlots.toList(),
                  afternoonSlots: controller.afternoonSlots.toList(),
                  eveningSlots: controller.eveningSlots.toList(),
                )),
            SizedBox(height: 16.rh),
            Obx(() => controller.selectedTimeSlot.value.isNotEmpty
                ? ActionButton(
                    text: AppString.kConfirm, onPressed: () => Get.back())
                : const SizedBox.shrink()),
          ],
        ),
      ),
    ).whenComplete(() {
      if (controller.selectedTimeSlot.value.isEmpty) {
        controller.selectedDateIndex.value = prevDateIndex;
        controller.selectedTimeSlot.value = prevTimeSlot;
        controller.selectedDateTimeDisplay.value = prevDisplay;
      }
    });
  }

  Widget _buildPrescriptionSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppString.kUploadedPrescriptions,
            fontSize: 14.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 12.rh),
          Obx(() => Wrap(
                spacing: 12.rw,
                runSpacing: 12.rh,
                children: controller.prescriptionFiles.map((file) {
                  return GestureDetector(
                    onTap: () => FilePreviewDialog.show(file),
                    child: Container(
                      width: 60.rs,
                      height: 60.rs,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(8.rs),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.rs),
                        child: FilePickerHelper.buildFilePreview(file),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildPricingSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw),
      child: Column(
        children: [
          _priceRow(AppString.kTotalMRP, '\u20B9 0'),
          SizedBox(height: 8.rh),
          _priceRow(AppString.kFromWallet, '\u20B9 0',
              valueColor: AppColors.error),
          SizedBox(height: 12.rh),
          Divider(color: AppColors.borderLight, thickness: 0.5),
          SizedBox(height: 12.rh),
          _priceRow(AppString.kNetPay, '\u20B9 0', isBold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
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
            CommonText(AppString.kRemarksLabel,
                fontSize: 10.rf, color: AppColors.error),
            SizedBox(height: 4.rh),
            CommonText(AppString.kOrderCannotBeCancelled,
                fontSize: 10.rf, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndBook() async {
    final confirmed = await CommonDialog.confirm(
      title: 'Confirm Booking',
      message: 'Are you sure you want to confirm this vision appointment?',
      confirmText: 'Book Now',
      cancelText: 'Go Back',
    );
    if (confirmed == true) controller.confirmBooking();
  }
}
