import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/app_toasts.dart';

class AddFamilyMemberController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text editing controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Observable variables
  final RxString selectedRelationship = ''.obs;
  final RxString selectedGender = ''.obs;
  final Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Validators
  String? validateRelationship(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.kRelationshipRequired;
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.kNameRequired;
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateDateOfBirth(String? value) {
    if (selectedDateOfBirth.value == null) {
      return AppString.kDateOfBirthRequired;
    }
    return null;
  }

  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.kGenderRequired;
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.kPhoneNumberRequired;
    }
    if (value.length != 10) {
      return AppString.kInvalidPhoneNumber;
    }
    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return AppString.kInvalidPhoneNumber;
    }
    return null;
  }

  // Select relationship
  void selectRelationship(String? relationship) {
    if (relationship != null) {
      selectedRelationship.value = relationship;
    }
  }

  // Select gender
  void selectGender(String? gender) {
    if (gender != null) {
      selectedGender.value = gender;
    }
  }

  // Select date of birth
  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDateOfBirth.value) {
      selectedDateOfBirth.value = picked;
    }
  }

  // Format date for display
  String getFormattedDate() {
    if (selectedDateOfBirth.value == null) {
      return AppString.kDateOfBirthHint;
    }
    final date = selectedDateOfBirth.value!;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Save and continue
  Future<void> saveAndContinue() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for date of birth
    if (selectedDateOfBirth.value == null) {
      AppToast.error(
        title: 'Validation Error',
        message: AppString.kDateOfBirthRequired,
      );
      return;
    }

    // Show loading
    isLoading.value = true;

    try {
      // Simulate API call - Replace with actual service call
      await Future.delayed(Duration(seconds: 2));

      // Prepare data
      final familyMemberData = {
        'relationship': selectedRelationship.value,
        'name': nameController.text.trim(),
        'dateOfBirth': selectedDateOfBirth.value!.toIso8601String(),
        'gender': selectedGender.value,
        'phoneNumber': phoneController.text.trim(),
      };

      // TODO: Call your API service here
      // await yourApiService.addFamilyMember(familyMemberData);

      isLoading.value = false;

      // Show success message
      AppToast.success(
        title: 'Success',
        message: 'Family member added successfully',
      );

      // Navigate back or to next screen
      Get.back(result: familyMemberData);
    } catch (e) {
      isLoading.value = false;
      AppToast.error(
        title: 'Error',
        message: 'Failed to add family member. Please try again.',
      );
    }
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    phoneController.clear();
    selectedRelationship.value = '';
    selectedGender.value = '';
    selectedDateOfBirth.value = null;
  }
}