import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/model/claims%20models/claim_model.dart';
import 'package:flip_health/views/claims/add_claim_screen.dart';

class ClaimsListScreen extends GetView<ClaimsController> {
  const ClaimsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      backgroundColor: AppColors.surfaceLight,
      appBar: CommonAppBar.build(title: AppString.kMyClaims),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildClaimsList()),
        ],
      ),
      floatingActionButton: _buildNewClaimFAB(),
    );
  }

  Widget _buildFilterBar() {
    return Obx(() {
      final idx = controller.selectedFilterIndex.value;
      final filter = ClaimsController.statusFilters[idx];
      final color = filter['color'] as Color;
      final label = filter['label'] as String;

      return GestureDetector(
        onTap: () => _showFilterSheet(),
        child: Container(
          margin: EdgeInsets.all(16.rs),
          padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.rs),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 10.rs,
                height: 10.rs,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 12.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(AppString.kFilterByStatus, fontSize: 10.rf, color: AppColors.textSecondary),
                    SizedBox(height: 2.rh),
                    CommonText(label, fontSize: 14.rf, fontWeight: FontWeight.w600, color: color),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 10.rh),
                decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(12.rs)),
                child: Column(
                  children: [
                    Obx(() => CommonText(
                          controller.filteredClaims.length.toString(),
                          fontSize: 18.rf,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        )),
                    CommonText(AppString.kClaimsLabel, fontSize: 10.rf, color: AppColors.textSecondary),
                  ],
                ),
              ),
              SizedBox(width: 8.rw),
              Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 24.rs),
            ],
          ),
        ),
      );
    });
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 24.rs),
                  SizedBox(width: 12.rw),
                  CommonText(AppString.kFilterByStatus, fontSize: 18.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.borderLight),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
                child: Obx(() => Column(
                      children: ClaimsController.statusFilters.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tab = entry.value;
                        final isSelected = controller.selectedFilterIndex.value == index;
                        final color = tab['color'] as Color;
                        final label = tab['label'] as String;
                        final count = controller.getStatusCount(tab['status'] as int);

                        return GestureDetector(
                          onTap: () {
                            controller.filterByStatus(index);
                            Get.back();
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.rh),
                            padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12.rs),
                              border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.rs),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8.rs),
                                  ),
                                  child: Icon(ClaimStatusConfig.fromStatus(tab['status'] as int).icon, color: color, size: 18.rs),
                                ),
                                SizedBox(width: 14.rw),
                                Expanded(
                                  child: CommonText(label, fontSize: 14.rf, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? color : AppColors.textPrimary),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 6.rh),
                                  decoration: BoxDecoration(color: isSelected ? color : AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(20.rs)),
                                  child: CommonText(count.toString(), fontSize: 12.rf, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textSecondary),
                                ),
                                if (isSelected) ...[
                                  SizedBox(width: 8.rw),
                                  Icon(Icons.check_circle, color: color, size: 22.rs),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )),
              ),
            ),
            SizedBox(height: 20.rh),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildClaimsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.filteredClaims.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.rs),
                decoration: BoxDecoration(color: AppColors.backgroundTertiary, shape: BoxShape.circle),
                child: Icon(Icons.receipt_long_outlined, size: 48.rs, color: AppColors.textSecondary),
              ),
              SizedBox(height: 20.rh),
              CommonText(AppString.kNoClaimsFound, fontSize: 15.rf, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => controller.refreshClaims(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
              controller.loadMoreClaims();
            }
            return false;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 4.rh, bottom: 80.rh, left: 16.rw, right: 16.rw),
            itemCount: controller.filteredClaims.length +
                (controller.isClaimsLoadingMore.value ? 1 : 0), // ignore: unnecessary_statements
            itemBuilder: (context, index) {
              if (index >= controller.filteredClaims.length) {
                return Padding(
                  padding: EdgeInsets.all(16.rs),
                  child: Center(
                    child: SizedBox(
                      width: 24.rs,
                      height: 24.rs,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                );
              }
              return _buildClaimCard(controller.filteredClaims[index]);
            },
          ),
        ),
      );
    });
  }

  Widget _buildClaimCard(ClaimModel claim) {
    final config = ClaimStatusConfig.fromStatus(claim.status);

    return GestureDetector(
      onTap: () => controller.openClaimDetail(claim),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.rh),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.rs),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.rs),
              child: Row(
                children: [
                  Container(
                    width: 44.rs,
                    height: 44.rs,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(12.rs),
                    ),
                    child: Center(
                      child: CommonText(claim.userName[0].toUpperCase(), fontSize: 18.rf, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(claim.userName, fontSize: 15.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        SizedBox(height: 2.rh),
                        CommonText('#${claim.id}', fontSize: 11.rf, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 5.rh),
                    decoration: BoxDecoration(color: config.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20.rs)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(config.icon, size: 14.rs, color: config.color),
                        SizedBox(width: 4.rw),
                        CommonText(config.label, fontSize: 10.rf, fontWeight: FontWeight.w600, color: config.color),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 12.rh),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(AppString.kClaimedLabel, '₹${claim.claimAmount.toStringAsFixed(0)}'),
                  if (claim.approvedAmount > 0) _buildStatItem(AppString.kApprovedLabel, '₹${claim.approvedAmount.toStringAsFixed(0)}', color: AppColors.success),
                  _buildStatItem(AppString.kDateLabel, claim.createdAt.split('T').first),
                  if (claim.serviceType != null) _buildStatItem(AppString.kTypeLabel, claim.serviceType!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        CommonText(label, fontSize: 9.rf, color: AppColors.textSecondary),
        SizedBox(height: 2.rh),
        CommonText(value, fontSize: 12.rf, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary),
      ],
    );
  }

  Widget _buildNewClaimFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.rs),
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)]),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.rs),
          onTap: () {
            controller.resetAddClaim();
            Get.to(() => const AddClaimScreen());
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 14.rh),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 22.rs),
                SizedBox(width: 8.rw),
                CommonText(AppString.kNewClaim, fontSize: 14.rf, fontWeight: FontWeight.w600, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
