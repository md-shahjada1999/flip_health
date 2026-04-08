import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/claims%20controllers/claims_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/views/claims/claim_opd_terms_text.dart';
import 'package:flip_health/views/common/family_member_dropdown.dart';
import 'package:url_launcher/url_launcher.dart';

class AddClaimStep1 extends GetView<ClaimsController> {
  const AddClaimStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.rs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => FamilyMemberDropdown(
              label: AppString.kSelectPatient,
              members: controller.familyMembers,
              isLoading: controller.membersLoading.value,
              selectedMemberId: controller.selectedMemberId.value,
              onSelected: controller.selectMember,
            ),
          ),
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
          _buildTermsRow(),
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
                  controller.clearEditBankMode();
                  Get.toNamed(AppRoutes.addBank);
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

  /// Same flow as patient_app `claims_step_1`: checkbox / link opens scrollable T&C sheet;
  /// accepting is completed after scrolling to the end (or short content) and tapping Continue.
  Widget _buildTermsRow() {
    return Obx(() => Container(
          padding: EdgeInsets.all(14.rs),
          decoration: BoxDecoration(
            color: controller.termsAccepted.value ? AppColors.primary.withValues(alpha: 0.04) : AppColors.surface,
            borderRadius: BorderRadius.circular(12.rs),
            border: Border.all(
              color: controller.termsAccepted.value ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: controller.termsAccepted.value,
                onChanged: (_) => _showOpdTermsBottomSheet(),
                activeColor: AppColors.primary,
              ),
              SizedBox(width: 4.rw),
              Expanded(
                child: GestureDetector(
                  onTap: _showOpdTermsBottomSheet,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.rh),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13.rf,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: '${AppString.kIAgreeToThe} '),
                          TextSpan(
                            text: AppString.kTermsAndConditionsLink,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                            ),
                          ),
                          const TextSpan(
                            text: ' for OPD claim reimbursement.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _showOpdTermsBottomSheet() {
    Get.bottomSheet(
      _OpdTermsBottomSheet(controller: controller),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  /// patient_app `step1PopupTermsNConditionsBS` — shown before navigating to bills step.
  void _showImportantNoteBottomSheet() {
    Get.bottomSheet(
      _ImportantNoteBottomSheet(controller: controller),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: controller.isStep1Valid ? () => _showImportantNoteBottomSheet() : null,
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

class _OpdTermsBottomSheet extends StatefulWidget {
  const _OpdTermsBottomSheet({required this.controller});

  final ClaimsController controller;

  @override
  State<_OpdTermsBottomSheet> createState() => _OpdTermsBottomSheetState();
}

class _OpdTermsBottomSheetState extends State<_OpdTermsBottomSheet> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeMarkReadIfNotScrollable());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final p = _scrollController.position;
    if (p.maxScrollExtent <= 4) {
      widget.controller.termsAccepted.value = true;
    } else if (p.pixels >= p.maxScrollExtent - 28) {
      widget.controller.termsAccepted.value = true;
    }
  }

  void _maybeMarkReadIfNotScrollable() {
    if (!_scrollController.hasClients) return;
    final p = _scrollController.position;
    if (p.maxScrollExtent <= 4) {
      widget.controller.termsAccepted.value = true;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openFullTermsUrl() async {
    final uri = Uri.parse(ApiUrl.TERMS_AND_CONDITIONS_URL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.88,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.rw, 12.rh, 20.rw, 16.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(6.rs),
                    decoration: const BoxDecoration(color: Color(0xFFE0E0E0), shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded, size: 20.rs, color: AppColors.textPrimary),
                  ),
                ),
              ),
              SizedBox(height: 8.rh),
              CommonText(
                ClaimOpdTermsText.title,
                fontSize: 17.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 12.rh),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12.rw, 10.rh, 16.rw, 10.rh),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(12.rs),
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: CommonText(
                        ClaimOpdTermsText.body,
                        fontSize: 13.rf,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.rh),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _openFullTermsUrl,
                  child: CommonText(
                    AppString.kViewFullTermsInBrowser,
                    fontSize: 13.rf,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 8.rh),
              Obx(() {
                final accepted = widget.controller.termsAccepted.value;
                return ElevatedButton(
                  onPressed: accepted
                      ? () {
                          Get.back();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accepted ? AppColors.textPrimary : AppColors.borderLight,
                    disabledBackgroundColor: AppColors.borderLight,
                    padding: EdgeInsets.symmetric(vertical: 14.rh),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
                    elevation: 0,
                  ),
                  child: CommonText(
                    AppString.kContinue,
                    fontSize: 15.rf,
                    fontWeight: FontWeight.w600,
                    color: accepted ? Colors.white : AppColors.textSecondary,
                  ),
                );
              }),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImportantNoteBottomSheet extends StatelessWidget {
  const _ImportantNoteBottomSheet({required this.controller});

  final ClaimsController controller;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontSize: 13.rf, color: AppColors.textPrimary, height: 1.45);
    final bold = TextStyle(
      fontSize: 13.rf,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      height: 1.45,
    );

    return SizedBox(
      height: Get.height * 0.52,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.rw, 12.rh, 20.rw, 16.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(6.rs),
                    decoration: const BoxDecoration(color: Color(0xFFE0E0E0), shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded, size: 20.rs, color: AppColors.textPrimary),
                  ),
                ),
              ),
              SizedBox(height: 8.rh),
              CommonText(
                ClaimStep1ImportantNoteText.title,
                fontSize: 17.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 12.rh),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12.rw, 10.rh, 16.rw, 10.rh),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(12.rs),
                    ),
                    child: SingleChildScrollView(
                      child: RichText(
                        text: TextSpan(
                          style: base,
                          children: [
                            TextSpan(text: ClaimStep1ImportantNoteText.part1),
                            TextSpan(text: ClaimStep1ImportantNoteText.part1Bold, style: bold),
                            TextSpan(text: ClaimStep1ImportantNoteText.part2),
                            TextSpan(text: ClaimStep1ImportantNoteText.part2Bold, style: bold),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.rh),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.goToStep(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.rh),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.rs)),
                  elevation: 0,
                ),
                child: CommonText(
                  AppString.kContinue,
                  fontSize: 15.rf,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
