import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/views/claims/add_bank_screen.dart';

class BankListScreen extends GetView<ClaimsController> {
  const BankListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar.build(title: AppString.kBankAccounts),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Get.to(() => const AddBankScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
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
                  onTap: () => Get.to(() => const AddBankScreen()),
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
            return Container(
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
                      ],
                    ),
                  ),
                  if (bank.verifyStatus == 2)
                    Container(
                      padding: EdgeInsets.all(4.rs),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warning, size: 14.rs, color: Colors.amber.shade700),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
