import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';

class AddClaimStep2 extends GetView<ClaimsController> {
  const AddClaimStep2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBillsSection(),
          SizedBox(height: 24.rh),
          _buildDocumentsSection(),
          SizedBox(height: 32.rh),
          _buildNavigationButtons(),
          SizedBox(height: 20.rh),
        ],
      ),
    );
  }

  Widget _buildBillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppString.kMedicalBills, Icons.receipt_outlined),
        SizedBox(height: 12.rh),
        Obx(() => Column(
              children: [
                ...controller.bills.asMap().entries.map((entry) => _buildBillCard(entry.key, entry.value)),
                _buildAddBillButton(),
              ],
            )),
      ],
    );
  }

  Widget _buildBillCard(int index, ClaimBill bill) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.rh),
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.rs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.rs),
            ),
            child: Icon(Icons.receipt_outlined, size: 20.rs, color: AppColors.primary),
          ),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText('Bill #${bill.billNumber}', fontSize: 14.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                SizedBox(height: 2.rh),
                CommonText(
                  '${bill.clinicName} • ${bill.billDate}',
                  fontSize: 11.rf,
                  color: AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CommonText('₹${bill.billAmount.toStringAsFixed(0)}', fontSize: 15.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          SizedBox(width: 8.rw),
          GestureDetector(
            onTap: () => controller.removeBill(index),
            child: Container(
              padding: EdgeInsets.all(6.rs),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.close, size: 16.rs, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBillButton() {
    return GestureDetector(
      onTap: () => _showAddBillSheet(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.rs),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14.rs),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22.rs),
            SizedBox(width: 8.rw),
            CommonText(AppString.kAddMedicalBill, fontSize: 14.rf, fontWeight: FontWeight.w600, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showAddBillSheet() {
    controller.billNumberController.clear();
    controller.billDateController.clear();
    controller.billAmountController.clear();
    controller.clinicNameController.clear();
    controller.clinicAddressController.clear();
    controller.doctorNameController.clear();
    controller.doctorRegController.clear();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.rh),
              width: 40.rw,
              height: 4.rh,
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2.rs)),
            ),
            Padding(
              padding: EdgeInsets.all(20.rs),
              child: Row(
                children: [
                  CommonText(AppString.kAddMedicalBill, fontSize: 18.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(6.rs),
                      decoration: BoxDecoration(color: AppColors.backgroundTertiary, shape: BoxShape.circle),
                      child: Icon(Icons.close, size: 20.rs, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.borderLight),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.rs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetField(
                      label: AppString.kBillNumber,
                      hint: 'Enter bill number',
                      controller: controller.billNumberController,
                      prefixIcon: Icons.tag,
                    ),
                    SizedBox(height: 16.rh),
                    _buildSheetField(
                      label: AppString.kBillDate,
                      hint: 'Select bill date',
                      controller: controller.billDateController,
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: Get.context!,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
                            child: child!,
                          ),
                        );
                        if (date != null) {
                          controller.billDateController.text = '${date.day}/${date.month}/${date.year}';
                        }
                      },
                    ),
                    SizedBox(height: 16.rh),
                    _buildSheetField(
                      label: AppString.kBillAmount,
                      hint: 'Enter bill amount',
                      controller: controller.billAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                      prefixIcon: Icons.currency_rupee,
                    ),
                    SizedBox(height: 16.rh),
                    _buildSheetField(
                      label: AppString.kClinicName,
                      hint: 'Enter clinic / hospital name',
                      controller: controller.clinicNameController,
                      prefixIcon: Icons.local_hospital_outlined,
                    ),
                    SizedBox(height: 16.rh),
                    _buildSheetField(
                      label: AppString.kClinicAddress,
                      hint: 'Enter clinic address',
                      controller: controller.clinicAddressController,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 16.rh),
                    _buildSheetField(
                      label: AppString.kDoctorName,
                      hint: 'Enter doctor name',
                      controller: controller.doctorNameController,
                      prefixIcon: Icons.person_outline,
                    ),
                    SizedBox(height: 16.rh),
                    _buildSheetField(
                      label: AppString.kDoctorRegistration,
                      hint: 'Enter doctor registration number',
                      controller: controller.doctorRegController,
                      prefixIcon: Icons.badge_outlined,
                    ),
                    SizedBox(height: 24.rh),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.addBill();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.rh),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
                          elevation: 0,
                        ),
                        child: CommonText(AppString.kSaveBill, fontSize: 15.rf, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20.rh),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSheetField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 12.rf, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        SizedBox(height: 6.rh),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(fontSize: 14.rf, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13.rf, color: AppColors.textSecondary.withValues(alpha: 0.6)),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.rs, color: AppColors.textSecondary) : null,
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.rs), borderSide: BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.rs), borderSide: BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.rs), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppString.kSupportingDocuments, Icons.folder_outlined),
        SizedBox(height: 16.rh),
        _buildDocCategory(AppString.kPaymentReceipts, 'PAYMENT', Icons.payment_outlined, controller.paymentFiles),
        SizedBox(height: 12.rh),
        _buildDocCategory(AppString.kMedicalReports, 'REPORT', Icons.description_outlined, controller.reportFiles),
        SizedBox(height: 12.rh),
        _buildDocCategory(AppString.kOtherDocuments, 'OTHER', Icons.attach_file_outlined, controller.otherFiles),
      ],
    );
  }

  Widget _buildDocCategory(String title, String type, IconData icon, RxList<Map<String, dynamic>> files) {
    return Container(
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.rs, color: AppColors.textSecondary),
              SizedBox(width: 8.rw),
              Expanded(child: CommonText(title, fontSize: 13.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              GestureDetector(
                onTap: () => controller.pickFile(type),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 6.rh),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.rs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14.rs, color: AppColors.primary),
                      SizedBox(width: 4.rw),
                      CommonText(AppString.kUpload, fontSize: 11.rf, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (files.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 10.rh),
              child: Wrap(
                spacing: 8.rw,
                runSpacing: 8.rh,
                children: files.asMap().entries.map((entry) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 6.rh),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8.rs),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_drive_file_outlined, size: 14.rs, color: AppColors.primary),
                        SizedBox(width: 6.rw),
                        CommonText(entry.value['name'] ?? 'file', fontSize: 11.rf, color: AppColors.textPrimary),
                        SizedBox(width: 6.rw),
                        GestureDetector(
                          onTap: () => controller.removeFile(type, entry.key),
                          child: Icon(Icons.close, size: 14.rs, color: AppColors.error),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.rs),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.rs),
          ),
          child: Icon(icon, size: 18.rs, color: AppColors.primary),
        ),
        SizedBox(width: 10.rw),
        CommonText(title, fontSize: 16.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => controller.goToStep(0),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.rh),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
              side: BorderSide(color: AppColors.borderLight),
            ),
            child: CommonText(AppString.kBack, fontSize: 15.rf, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        SizedBox(width: 12.rw),
        Expanded(
          flex: 2,
          child: Obx(() => ElevatedButton(
                onPressed: controller.bills.isNotEmpty ? () => controller.goToStep(2) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.borderLight,
                  padding: EdgeInsets.symmetric(vertical: 16.rh),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
                  elevation: 0,
                ),
                child: CommonText(
                  AppString.kReviewClaim,
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w600,
                  color: controller.bills.isNotEmpty ? Colors.white : AppColors.textSecondary,
                ),
              )),
        ),
      ],
    );
  }
}
