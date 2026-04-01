import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/views/claims/add_bank_screen.dart';

class AddClaimStep1 extends GetView<ClaimsController> {
  const AddClaimStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(AppString.kSelectPatient, Icons.person_outline),
          SizedBox(height: 12.rh),
          _buildMemberSelector(),
          SizedBox(height: 28.rh),
          _buildSectionTitle(AppString.kContactDetails, Icons.phone_outlined),
          SizedBox(height: 12.rh),
          CustomTextField(
            label: AppString.kPhoneNumber,
            hint: 'Enter phone number',
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            prefixIcon: Icon(Icons.phone_outlined, size: 20.rs, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.rh),
          CustomTextField(
            label: AppString.kEmailAddress,
            hint: 'Enter email address',
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email_outlined, size: 20.rs, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.rh),
          CustomTextField(
            label: AppString.kAlternatePhoneNumber,
            hint: 'Enter alternate phone (optional)',
            controller: controller.alternatePhoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            prefixIcon: Icon(Icons.phone_forwarded_outlined, size: 20.rs, color: AppColors.textSecondary),
          ),
          SizedBox(height: 28.rh),
          _buildSectionTitle(AppString.kBankDetailsLabel, Icons.account_balance_outlined),
          SizedBox(height: 12.rh),
          _buildBankSelector(),
          SizedBox(height: 28.rh),
          _buildTermsCheckbox(),
          SizedBox(height: 32.rh),
          _buildNextButton(),
          SizedBox(height: 20.rh),
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

  Widget _buildMemberSelector() {
    return Obx(() => Column(
          children: controller.members.map((member) {
            final isSelected = controller.selectedMemberId.value == member['id'];
            return GestureDetector(
              onTap: () => controller.selectMember(member['id'], member['name']),
              child: Container(
                margin: EdgeInsets.only(bottom: 10.rh),
                padding: EdgeInsets.all(14.rs),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
                  borderRadius: BorderRadius.circular(14.rs),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.rs,
                      height: 42.rs,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(12.rs),
                      ),
                      child: Center(
                        child: CommonText(
                          (member['name'] as String)[0].toUpperCase(),
                          fontSize: 16.rf,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.rw),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(member['name'], fontSize: 14.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          SizedBox(height: 2.rh),
                          CommonText(
                            '${member['relation']} • ${member['gender']} • ${member['age']} yrs',
                            fontSize: 11.rf,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 22.rs,
                      height: 22.rs,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: 2),
                      ),
                      child: isSelected ? Icon(Icons.check, size: 14.rs, color: Colors.white) : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildBankSelector() {
    return Obx(() => GestureDetector(
          onTap: () => _showBankSheet(),
          child: Container(
            padding: EdgeInsets.all(16.rs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.rs),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.rs),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.rs)),
                  child: Icon(Icons.account_balance_outlined, size: 20.rs, color: AppColors.primary),
                ),
                SizedBox(width: 12.rw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(AppString.kSelectBank, fontSize: 12.rf, color: AppColors.textSecondary),
                      SizedBox(height: 2.rh),
                      CommonText(
                        controller.selectedBankName.value.isEmpty ? AppString.kTapToSelectBank : controller.selectedBankName.value,
                        fontSize: 14.rf,
                        fontWeight: FontWeight.w500,
                        color: controller.selectedBankName.value.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 24.rs),
              ],
            ),
          ),
        ));
  }

  void _showBankSheet() {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
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
              padding: EdgeInsets.all(16.rs),
              child: Row(
                children: [
                  CommonText(AppString.kSelectBank, fontSize: 18.rf, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
            Obx(() {
              if (controller.bankAccounts.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.rh),
                  child: Column(
                    children: [
                      Icon(Icons.account_balance_outlined, size: 48.rs, color: AppColors.borderLight),
                      SizedBox(height: 12.rh),
                      CommonText(AppString.kNoBankAccounts, fontSize: 14.rf, color: AppColors.textSecondary),
                    ],
                  ),
                );
              }
              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
                  itemCount: controller.bankAccounts.length,
                  itemBuilder: (_, i) {
                    final bank = controller.bankAccounts[i];
                    final isSelected = controller.selectedBank.value?.id == bank.id;
                    return GestureDetector(
                      onTap: () {
                        controller.selectBankAccount(bank);
                        Get.back();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.rh),
                        padding: EdgeInsets.all(14.rs),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(12.rs),
                          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: isSelected ? 1.5 : 0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: AppColors.primary,
                              size: 22.rs,
                            ),
                            SizedBox(width: 12.rw),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText(bank.holderName, fontSize: 14.rf, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  SizedBox(height: 2.rh),
                                  CommonText(
                                    '${bank.bankName} - ${bank.maskedAccountNumber}',
                                    fontSize: 12.rf,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(height: 2.rh),
                                  CommonText(
                                    'IFSC: ${bank.ifscCode}',
                                    fontSize: 11.rf,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            Padding(
              padding: EdgeInsets.fromLTRB(16.rw, 8.rh, 16.rw, 20.rh),
              child: GestureDetector(
                onTap: () {
                  Get.back();
                  Get.to(() => const AddBankScreen());
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.rh),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.rs),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Center(
                    child: CommonText(
                      '+ ${AppString.kAddBank}',
                      fontSize: 14.rf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTermsCheckbox() {
    return Obx(() => GestureDetector(
          onTap: () => controller.termsAccepted.toggle(),
          child: Container(
            padding: EdgeInsets.all(14.rs),
            decoration: BoxDecoration(
              color: controller.termsAccepted.value ? AppColors.primary.withValues(alpha: 0.04) : AppColors.surface,
              borderRadius: BorderRadius.circular(12.rs),
              border: Border.all(color: controller.termsAccepted.value ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 22.rs,
                  height: 22.rs,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.rs),
                    color: controller.termsAccepted.value ? AppColors.primary : Colors.transparent,
                    border: Border.all(color: controller.termsAccepted.value ? AppColors.primary : AppColors.borderLight, width: 2),
                  ),
                  child: controller.termsAccepted.value ? Icon(Icons.check, size: 14.rs, color: Colors.white) : null,
                ),
                SizedBox(width: 12.rw),
                Expanded(
                  child: CommonText(
                    AppString.kAcceptTermsAndConditions,
                    fontSize: 13.rf,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: controller.isStep1Valid ? () => controller.goToStep(1) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.borderLight,
              padding: EdgeInsets.symmetric(vertical: 16.rh),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
              elevation: 0,
            ),
            child: CommonText(
              AppString.kContinue,
              fontSize: 15.rf,
              fontWeight: FontWeight.w600,
              color: controller.isStep1Valid ? Colors.white : AppColors.textSecondary,
            ),
          )),
    );
  }
}
