import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class ClaimOverviewScreen extends GetView<ClaimsController> {
  const ClaimOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.rs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientSection(),
                SizedBox(height: 20.rh),
                _buildBillsSummary(),
                SizedBox(height: 20.rh),
                _buildDocumentsSummary(),
                SizedBox(height: 20.rh),
                _buildAmountSummary(),
                SizedBox(height: 20.rh),
                _buildDisclaimerNote(),
                SizedBox(height: 20.rh),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildPatientSection() {
    return _buildCard(
      title: AppString.kPatientDetails,
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildInfoRow(AppString.kPatientNameLabel, controller.selectedMemberName.value),
          _buildInfoRow(AppString.kPhoneNumber, controller.phoneController.text),
          if (controller.emailController.text.isNotEmpty) _buildInfoRow(AppString.kEmailAddress, controller.emailController.text),
          if (controller.alternatePhoneController.text.isNotEmpty)
            _buildInfoRow(AppString.kAlternatePhoneNumber, controller.alternatePhoneController.text),
          if (controller.selectedBankName.value.isNotEmpty) _buildInfoRow(AppString.kBankDetailsLabel, controller.selectedBankName.value),
        ],
      ),
    );
  }

  Widget _buildBillsSummary() {
    return _buildCard(
      title: AppString.kMedicalBills,
      icon: Icons.receipt_outlined,
      child: Obx(() => Column(
            children: controller.bills.asMap().entries.map((entry) {
              final bill = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: entry.key < controller.bills.length - 1 ? 10.rh : 0),
                padding: EdgeInsets.all(12.rs),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10.rs),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.rs,
                      height: 36.rs,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.rs),
                      ),
                      child: Center(child: CommonText('${entry.key + 1}', fontSize: 14.rf, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                    SizedBox(width: 12.rw),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText('Bill #${bill.billNumber}', fontSize: 13.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          SizedBox(height: 2.rh),
                          CommonText('${bill.clinicName} • ${bill.billDate}', fontSize: 11.rf, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    CommonText('₹${bill.billAmount.toStringAsFixed(0)}', fontSize: 14.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ],
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildDocumentsSummary() {
    return _buildCard(
      title: AppString.kSupportingDocuments,
      icon: Icons.folder_outlined,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocCount(AppString.kPaymentReceipts, controller.paymentFiles.length, Icons.payment_outlined),
              _buildDocCount(AppString.kMedicalReports, controller.reportFiles.length, Icons.description_outlined),
              _buildDocCount(AppString.kOtherDocuments, controller.otherFiles.length, Icons.attach_file_outlined),
            ],
          )),
    );
  }

  Widget _buildDocCount(String label, int count, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.rh),
      child: Row(
        children: [
          Icon(icon, size: 16.rs, color: AppColors.textSecondary),
          SizedBox(width: 8.rw),
          Expanded(child: CommonText(label, fontSize: 13.rf, color: AppColors.textPrimary)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
            decoration: BoxDecoration(
              color: count > 0 ? AppColors.primary.withValues(alpha: 0.1) : AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(12.rs),
            ),
            child: CommonText(
              '$count ${count == 1 ? 'file' : 'files'}',
              fontSize: 11.rf,
              fontWeight: FontWeight.w600,
              color: count > 0 ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSummary() {
    return Container(
      padding: EdgeInsets.all(20.rs),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.06), AppColors.primary.withValues(alpha: 0.02)]),
        borderRadius: BorderRadius.circular(16.rs),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(AppString.kTotalClaimAmount, fontSize: 12.rf, color: AppColors.textSecondary),
                  SizedBox(height: 4.rh),
                  CommonText(
                    '₹${controller.totalBillAmount.toStringAsFixed(0)}',
                    fontSize: 28.rf,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.rs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.currency_rupee, color: AppColors.primary, size: 24.rs),
              ),
            ],
          )),
    );
  }

  Widget _buildDisclaimerNote() {
    return Container(
      padding: EdgeInsets.all(14.rs),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18.rs, color: const Color(0xFFF57C00)),
          SizedBox(width: 10.rw),
          Expanded(
            child: CommonText(
              AppString.kClaimDisclaimer,
              fontSize: 12.rf,
              color: const Color(0xFF795548),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.rs),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.rs, color: AppColors.primary),
              SizedBox(width: 8.rw),
              CommonText(title, fontSize: 15.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ],
          ),
          Divider(height: 24.rh, color: AppColors.borderLight),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(label, fontSize: 12.rf, color: AppColors.textSecondary),
          Flexible(child: CommonText(value, fontSize: 13.rf, fontWeight: FontWeight.w500, color: AppColors.textPrimary, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(20.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.goToStep(1),
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
              child: ElevatedButton(
                onPressed: () => _showSuccessDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.rh),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
                  elevation: 0,
                ),
                child: CommonText(AppString.kSubmitClaim, fontSize: 15.rf, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.rs)),
        child: Padding(
          padding: EdgeInsets.all(28.rs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.rs),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.check_circle_outline, size: 56.rs, color: AppColors.success),
              ),
              SizedBox(height: 20.rh),
              CommonText(AppString.kClaimSubmitted, fontSize: 20.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              SizedBox(height: 8.rh),
              CommonText(
                AppString.kClaimSubmittedMsg,
                fontSize: 13.rf,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
                height: 1.4,
              ),
              SizedBox(height: 24.rh),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                    controller.resetAddClaim();
                    controller.filterByStatus(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.rh),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
                    elevation: 0,
                  ),
                  child: CommonText(AppString.kDone, fontSize: 15.rf, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
