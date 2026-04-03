import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/routes/app_routes.dart';

class BankListScreen extends GetView<ClaimsController> {
  const BankListScreen({Key? key}) : super(key: key);

  void _openAddBank() {
    controller.clearEditBankMode();
    Get.toNamed(AppRoutes.addBank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: AppString.kBankAccounts),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddBank,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.bankAccounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_outlined, size: 64.rs, color: AppColors.borderLight),
                    SizedBox(height: 16.rh),
                    CommonText(AppString.kNoBankAccounts, fontSize: 16.rf, color: AppColors.textSecondary),
                    SizedBox(height: 12.rh),
                    GestureDetector(
                      onTap: _openAddBank,
                      child: CommonText(
                        '+ ${AppString.kAddBank}',
                        fontSize: 15.rf,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(20.rs),
              itemCount: controller.bankAccounts.length,
              itemBuilder: (_, index) {
                final bank = controller.bankAccounts[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.rs),
                    onTap: () => controller.openBankFromList(bank),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.rh),
                      padding: EdgeInsets.all(14.rs),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14.rs),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48.rs,
                            height: 48.rs,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundTertiary,
                              borderRadius: BorderRadius.circular(14.rs),
                            ),
                            child: Icon(Icons.account_balance_outlined, color: AppColors.textSecondary, size: 24.rs),
                          ),
                          SizedBox(width: 14.rw),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  bank.bankName,
                                  fontSize: 14.rf,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 3.rh),
                                CommonText(
                                  '${bank.maskedAccountNumber}  (IFSC: ${bank.ifscCode})',
                                  fontSize: 11.rf,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 2.rh),
                                CommonText(
                                  bank.holderName,
                                  fontSize: 11.rf,
                                  color: AppColors.textSecondary,
                                ),
                                if (bank.verifyStatus == 2 && (bank.verifyReason ?? '').isNotEmpty) ...[
                                  SizedBox(height: 6.rh),
                                  CommonText(
                                    bank.verifyReason!,
                                    fontSize: 11.rf,
                                    color: AppColors.error,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (bank.verifyStatus == 2) ...[
                                  SizedBox(height: 6.rh),
                                  CommonText(
                                    'Tap to update bank details',
                                    fontSize: 10.rf,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (bank.verifyStatus == 2)
                            Padding(
                              padding: EdgeInsets.only(left: 4.rw),
                              child: Container(
                                padding: EdgeInsets.all(4.rs),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.warning, size: 14.rs, color: Colors.amber.shade700),
                              ),
                            )
                          else
                            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 22.rs),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          Obx(() {
            if (!controller.isBankDetailLoading.value) return const SizedBox.shrink();
            return Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }),
        ],
      ),
    );
  }
}
