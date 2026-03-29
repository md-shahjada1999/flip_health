import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/health%20checkup%20controllers/add_family_member_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/action_button.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/custom_dropdown.dart';
import 'package:flip_health/core/utils/custom_textfeild.dart';
import 'package:flip_health/core/utils/common_text.dart';

class AddFamilyMemberScreen extends StatelessWidget {
  const AddFamilyMemberScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddFamilyMemberController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:CommonAppBar.build(
    title: AppString.kAddNewFamilyMemberTitle,
  ),
      
      
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.rw,
                  vertical: 20.rh,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Relationship dropdown
                    Obx(() => CustomDropdown(
                          hint: AppString.kRelationshipHint,
                          value: controller.selectedRelationship.value.isEmpty
                              ? null
                              : controller.selectedRelationship.value,
                          items: AppString.kRelationships,
                          onChanged: controller.selectRelationship,
                          validator: controller.validateRelationship,
                        )),
                    SizedBox(height: 20.rh),

                    // Name field
                    CustomTextField(
                      label: AppString.kName,
                      hint: AppString.kNameHint,
                      controller: controller.nameController,
                      keyboardType: TextInputType.name,
                      validator: controller.validateName,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]')),
                      ],
                    ),
                    SizedBox(height: 20.rh),

                    // Date of birth field
                    Obx(() => CustomTextField(
                          label: AppString.kDateOfBirth,
                          hint: controller.getFormattedDate(),
                          readOnly: true,
                          onTap: () => controller.selectDateOfBirth(context),
                          validator: controller.validateDateOfBirth,
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                            size: 20.rs,
                          ),
                        )),
                    SizedBox(height: 20.rh),

                    // Gender dropdown
                    Obx(() => CustomDropdown(
                          hint: AppString.kGenderHint,
                          value: controller.selectedGender.value.isEmpty
                              ? null
                              : controller.selectedGender.value,
                          items: AppString.kGenders,
                          onChanged: controller.selectGender,
                          validator: controller.validateGender,
                        )),
                    SizedBox(height: 20.rh),

                    // Phone number field
                    CustomTextField(
                      label: AppString.kPhoneNumber,
                      hint: AppString.kPhoneNumberHint,
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      validator: controller.validatePhoneNumber,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: 24.rh),

                    // Disclaimer text
                    CommonText(
                      AppString.kFamilyMemberDisclaimer,
                      fontSize: 12.rf,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button
            Obx(() => ActionButton(
                  text: AppString.kSaveAndContinue,
                  onPressed: controller.saveAndContinue,
                  isLoading: controller.isLoading.value,
                )),
          ],
        ),
      ),
    );
  }
}