import 'package:flip_health/core/helpers/app_validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // Text editing controller
  final phoneController = TextEditingController();

  // Observable variables
  final _isTermsAccepted = false.obs;
  final _isButtonEnabled = false.obs;
  final _isLoading = false.obs;
  final phoneText = ''.obs; // NEW observable for text

  // Getters
  bool get isTermsAccepted => _isTermsAccepted.value;
  bool get isButtonEnabled => _isButtonEnabled.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(() {
      phoneText.value = phoneController.text; // update observable
      _validateInput();
    });
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  // Validate input fields
  void _validateInput() {
    bool isInputValid = phoneController.text.length >= 10 &&
        AppValidator.isValidPhoneOrEmail(phoneController.text);
    _isButtonEnabled.value = isInputValid && _isTermsAccepted.value;
  }

  // Toggle terms acceptance
  void toggleTermsAcceptance() {
    _isTermsAccepted.value = !_isTermsAccepted.value;
    _validateInput();
  }

  // Send OTP API call
  Future<void> sendOTP() async {
    final input = phoneController.text.trim();

    if (!AppValidator.isValidPhoneOrEmail(input)) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a valid phone number or email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (!_isTermsAccepted.value) {
      Get.snackbar(
        'Terms Required',
        'Please accept terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    try {
      _isLoading.value = true;

      // Determine input type
      final inputType = AppValidator.getInputType(input);

      // Mock API call
      await _mockSendOTPAPI(input, inputType);

      // Navigate to OTP screen
      Get.toNamed('/otp', arguments: {
        'input': input,
        'inputType': inputType.name,
        'isEmail': inputType == InputType.email,
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Mock API call - replace with actual implementation
  Future<void> _mockSendOTPAPI(String input, InputType inputType) async {
    await Future.delayed(const Duration(seconds: 2));
    print('Sending OTP to: $input (${inputType.name})');
  }

  // Clear form
  void clearForm() {
    phoneController.clear();
    _isTermsAccepted.value = false;
    _isButtonEnabled.value = false;
  }

  // Handle back button
  void onBackPressed() {
    Get.back();
  }
}
