import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';

class ClaimDetailScreen extends GetView<ClaimsController> {
  const ClaimDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final claim = controller.selectedClaim.value;
      if (claim == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

      final config = ClaimStatusConfig.fromStatus(claim.status);

      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(claim, config),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSummaryCard(claim, config),
                  _buildQuickStats(claim),
                  _buildDetailsSection(claim),
                  SizedBox(height: 100.rh),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSliverAppBar(ClaimModel claim, ClaimStatusConfig config) {
    return SliverAppBar(
      expandedHeight: 140.rh,
      pinned: true,
      elevation: 0,
      backgroundColor: config.color,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: EdgeInsets.all(8.rs),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10.rs),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18.rs),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [config.color, config.color.withValues(alpha: 0.8)]),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.rw, 50.rh, 20.rw, 20.rh),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.rs),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.rs),
                        ),
                        child: Icon(config.icon, color: Colors.white, size: 24.rs),
                      ),
                      SizedBox(width: 12.rw),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText('Claim #${claim.id}', fontSize: 18.rf, fontWeight: FontWeight.w700, color: Colors.white),
                            SizedBox(height: 4.rh),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20.rs),
                              ),
                              child: CommonText(config.label, fontSize: 11.rf, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ClaimModel claim, ClaimStatusConfig config) {
    return Container(
      margin: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.rs),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.rs),
            child: Row(
              children: [
                Container(
                  width: 50.rs,
                  height: 50.rs,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(14.rs),
                  ),
                  child: Center(
                    child: CommonText(claim.userName[0].toUpperCase(), fontSize: 20.rf, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                SizedBox(width: 14.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(claim.userName, fontSize: 16.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      SizedBox(height: 4.rh),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 14.rs, color: AppColors.textSecondary),
                          SizedBox(width: 4.rw),
                          CommonText(claim.userPhone, fontSize: 12.rf, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CommonText(AppString.kSubmittedLabel, fontSize: 10.rf, color: AppColors.textSecondary),
                    CommonText(claim.createdAt, fontSize: 12.rf, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ],
                ),
              ],
            ),
          ),
          if (claim.serviceType != null) ...[
            Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
              child: Row(
                children: [
                  Icon(Icons.medical_services_outlined, size: 16.rs, color: AppColors.textSecondary),
                  SizedBox(width: 8.rw),
                  CommonText(claim.serviceType!, fontSize: 13.rf, color: AppColors.textPrimary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(ClaimModel claim) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.rw),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(AppString.kClaimedLabel, '₹${claim.claimAmount.toStringAsFixed(0)}', AppColors.primary)),
          SizedBox(width: 12.rw),
          Expanded(child: _buildStatCard(AppString.kApprovedLabel, '₹${claim.approvedAmount.toStringAsFixed(0)}', AppColors.success)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.rs),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(label, fontSize: 11.rf, color: AppColors.textSecondary),
          SizedBox(height: 6.rh),
          CommonText(value, fontSize: 22.rf, fontWeight: FontWeight.w700, color: color),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ClaimModel claim) {
    return Container(
      margin: EdgeInsets.all(16.rs),
      padding: EdgeInsets.all(20.rs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.rs),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(AppString.kClaimDetails, fontSize: 16.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          SizedBox(height: 16.rh),
          _buildDetailRow(AppString.kClaimId, '#${claim.id}'),
          _buildDetailRow(AppString.kPatientNameLabel, claim.userName),
          _buildDetailRow(AppString.kDateLabel, claim.createdAt),
          _buildDetailRow(AppString.kServiceTypeLabel, claim.serviceType ?? '-'),
          _buildDetailRow(AppString.kClaimedAmountLabel, '₹${claim.claimAmount.toStringAsFixed(0)}'),
          _buildDetailRow(AppString.kApprovedAmountLabel, '₹${claim.approvedAmount.toStringAsFixed(0)}'),
          if (claim.bills.isNotEmpty) ...[
            SizedBox(height: 16.rh),
            Divider(color: AppColors.borderLight),
            SizedBox(height: 16.rh),
            CommonText(AppString.kBillsLabel, fontSize: 14.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            SizedBox(height: 12.rh),
            ...claim.bills.map((bill) => _buildBillItem(bill)),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(label, fontSize: 13.rf, color: AppColors.textSecondary),
          CommonText(value, fontSize: 13.rf, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildBillItem(ClaimBill bill) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.rh),
      padding: EdgeInsets.all(12.rs),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.rs),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_outlined, color: AppColors.primary, size: 20.rs),
          SizedBox(width: 12.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText('Bill #${bill.billNumber}', fontSize: 13.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                SizedBox(height: 2.rh),
                CommonText(bill.clinicName, fontSize: 11.rf, color: AppColors.textSecondary),
              ],
            ),
          ),
          CommonText('₹${bill.billAmount.toStringAsFixed(0)}', fontSize: 14.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
