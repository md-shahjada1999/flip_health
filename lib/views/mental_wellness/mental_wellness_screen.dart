import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/mental%20wellness%20controllers/mental_wellness_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/views/common/family_member_dropdown.dart';

class MentalWellnessScreen extends GetView<MentalWellnessController> {
  const MentalWellnessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.background,
          appBar: CommonAppBar.build(
            title: controller.isNutritionEntry
                ? AppString.kTalkToNutritionist
                : AppString.kMentalWellness,
          ),
          body: Obx(() {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.rw),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.rh),
                          _buildHeroImage(),
                          SizedBox(height: 20.rh),
                          _buildDescription(),
                          SizedBox(height: 20.rh),
                          Obx(
                            () => FamilyMemberDropdown(
                              members: controller.members,
                              isLoading: controller.membersLoading.value,
                              selectedMemberId: controller.selectedMemberId.value,
                              onSelected: controller.selectMember,
                            ),
                          ),
                          SizedBox(height: 16.rh),
                          CustomTextField(
                            label: AppString.kName,
                            hint: AppString.kName,
                            controller: controller.nameController,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z ]'),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.rh),
                          CustomTextField(
                            label: AppString.kMobileNumber,
                            hint: AppString.kMobileNumber,
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          SizedBox(height: 16.rh),
                          CustomTextField(
                            label: AppString.kEmailLabel,
                            hint: AppString.kEmailLabel,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16.rh),
                          Obx(
                            () => controller.isMentalWellnessEntry
                                ? _buildCategorySelector()
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(height: 16.rh),
                          _buildLanguageSelector(),
                          SizedBox(height: 20.rh),
                          _buildDisclaimers(),
                          SizedBox(height: 100.rh),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => ActionButton(
                    text: AppString.kConnect,
                    backgroundColor: controller.connectEnabled.value
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.onConnectPressed,
                    icon: Icons.connect_without_contact,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.rs),
      child: Image.asset(
        'assets/png/mental_wellness_card.png',
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildDescription() {
    return CommonText(
      controller.isNutritionEntry
          ? AppString.kNutritionConsultDescription
          : AppString.kMentalWellnessDescription,
      fontSize: 14.rf,
      color: AppColors.textTertiary,
      height: 1.5,
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          '${AppString.kSelectCategory} *',
          fontSize: 13.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        SizedBox(height: 6.rh),
        Obx(
          () => InkWell(
            onTap: () => _showCategoryDialog(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.rh),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CommonText(
                      controller.consultation.value.isEmpty
                          ? AppString.kSelectCategory
                          : controller.consultation.value,
                      fontSize: 14.rf,
                      color: controller.consultation.value.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                    size: 28.rs,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryDialog() {
    Get.defaultDialog(
      title: AppString.kSelectCategory,
      titleStyle: TextStyle(fontSize: 18.rf, fontWeight: FontWeight.w600),
      titlePadding: EdgeInsets.only(top: 16.rh),
      content: SizedBox(
        height: 300.rh,
        width: 280.rw,
        child: Obx(
          () => Scrollbar(
            thickness: 4,
            thumbVisibility: true,
            child: ListView.separated(
              itemCount: controller.categories.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (_, i) {
                final cat = controller.categories[i];
                return ListTile(
                  dense: true,
                  title: CommonText(
                    cat,
                    fontSize: 14.rf,
                    color: AppColors.textPrimary,
                  ),
                  onTap: () {
                    controller.setConsultation(cat);
                    Get.back();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          AppString.kLanguage,
          fontSize: 13.rf,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        SizedBox(height: 6.rh),
        Obx(
          () => InkWell(
            onTap: () => _showLanguageSheet(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.rh),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CommonText(
                      controller.language.value.isEmpty
                          ? AppString.kSelectLanguage
                          : controller.language.value,
                      fontSize: 14.rf,
                      color: controller.language.value.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                    size: 28.rs,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.rs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.rw,
              height: 4.rh,
              margin: EdgeInsets.only(bottom: 16.rh),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.rs),
              ),
            ),
            CommonText(
              AppString.kSelectLanguage,
              fontSize: 18.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 16.rh),
            ...MentalWellnessController.availableLanguages.map((lang) {
              return Obx(
                () => ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.rs),
                  ),
                  tileColor: controller.language.value == lang
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : null,
                  leading: Icon(
                    controller.language.value == lang
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: controller.language.value == lang
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20.rs,
                  ),
                  title: CommonText(
                    lang,
                    fontSize: 14.rf,
                    color: AppColors.textPrimary,
                  ),
                  onTap: () {
                    controller.setLanguage(lang);
                    Get.back();
                  },
                ),
              );
            }),
            SizedBox(height: 16.rh),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDisclaimers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              '** ',
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            Expanded(
              child: CommonText(
                AppString.kDisclaimerEmergency,
                fontSize: 13.rf,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.rh),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              '** ',
              fontSize: 13.rf,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            Expanded(
              child: CommonText(
                AppString.kDisclaimerServiceHours,
                fontSize: 13.rf,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
