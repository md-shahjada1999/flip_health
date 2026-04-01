import 'package:flip_health/core/helpers/app_validators.dart';
import 'package:flip_health/data/repositories/auth_repository.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final AuthRepository _repository;

  LoginController({required AuthRepository repository})
      : _repository = repository;
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _isTermsAccepted = false.obs;
  final _isButtonEnabled = false.obs;
  final _isLoading = false.obs;
  final phoneText = ''.obs;
  final emailText = ''.obs;
  final passwordText = ''.obs;
  final isEmailLogin = false.obs;
  final obscurePassword = true.obs;

  bool get isTermsAccepted => _isTermsAccepted.value;
  bool get isButtonEnabled => _isButtonEnabled.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(() {
      phoneText.value = phoneController.text;
      _validateInput();
    });
    emailController.addListener(() {
      emailText.value = emailController.text;
      _validateInput();
    });
    passwordController.addListener(() {
      passwordText.value = passwordController.text;
      _validateInput();
    });
  }

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleLoginMode() {
    isEmailLogin.value = !isEmailLogin.value;
    _isButtonEnabled.value = false;
    _validateInput();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void _validateInput() {
    if (isEmailLogin.value) {
      final isValid = AppValidator.isValidEmail(emailController.text) &&
          passwordController.text.length >= 6;
      _isButtonEnabled.value = isValid && _isTermsAccepted.value;
    } else {
      bool isInputValid = phoneController.text.length >= 10 &&
          AppValidator.isValidPhoneOrEmail(phoneController.text);
      _isButtonEnabled.value = isInputValid && _isTermsAccepted.value;
    }
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

      await _repository.sendOtp(input: input, inputType: inputType.name);

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

  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!AppValidator.isValidEmail(email)) {
      Get.snackbar('Invalid Email', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800);
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Invalid Password', 'Password must be at least 6 characters',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800);
      return;
    }

    if (!_isTermsAccepted.value) {
      Get.snackbar('Terms Required', 'Please accept terms and conditions',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800);
      return;
    }

    try {
      _isLoading.value = true;
      await _repository.loginWithEmail(email: email, password: password);
      Get.snackbar('Success', 'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800);
      Get.offAllNamed(AppRoutes.healthScore);
    } catch (e) {
      Get.snackbar('Error', 'Login failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800);
    } finally {
      _isLoading.value = false;
    }
  }

  void clearForm() {
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    _isTermsAccepted.value = false;
    _isButtonEnabled.value = false;
  }

  // Handle back button
  void onBackPressed() {
    Get.back();
  }
}
