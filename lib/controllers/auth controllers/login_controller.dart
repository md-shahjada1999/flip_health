import 'package:flip_health/core/helpers/app_validators.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/auth_repository.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';

/// Login types that can arrive via arguments (for the link flow)
enum LoginMode { phone, email, password, linkEmail, linkPhone }

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

  /// When arriving from the LINK flow, this is set to the required type
  final Rx<LoginMode> loginMode = LoginMode.phone.obs;

  /// Title override for link flow
  final RxString linkTitle = ''.obs;
  final RxString linkSubtitle = ''.obs;

  bool get isTermsAccepted => _isTermsAccepted.value;
  bool get isButtonEnabled => _isButtonEnabled.value;
  bool get isLoading => _isLoading.value;
  bool get isLinkFlow =>
      loginMode.value == LoginMode.linkEmail ||
      loginMode.value == LoginMode.linkPhone;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final linkType = args['linkType'] as String?;
      if (linkType == 'EMAIL') {
        loginMode.value = LoginMode.linkEmail;
        isEmailLogin.value = false;
        linkTitle.value = 'Link Your Email';
        linkSubtitle.value =
            'Please enter your email address to complete account setup';
        phoneController.clear();
        emailController.clear();
        passwordController.clear();
      } else if (linkType == 'PHONE') {
        loginMode.value = LoginMode.linkPhone;
        isEmailLogin.value = false;
        linkTitle.value = 'Link Your Phone';
        linkSubtitle.value =
            'Please enter your phone number to complete account setup';
        phoneController.clear();
        emailController.clear();
        passwordController.clear();
      }
    }

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
    if (isLinkFlow) return;
    isEmailLogin.value = !isEmailLogin.value;
    _isButtonEnabled.value = false;
    _validateInput();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void _validateInput() {
    if (loginMode.value == LoginMode.linkEmail) {
      _isButtonEnabled.value =
          AppValidator.isValidEmail(emailController.text) &&
          _isTermsAccepted.value;
    } else if (loginMode.value == LoginMode.linkPhone) {
      _isButtonEnabled.value =
          phoneController.text.length >= 10 &&
          AppValidator.isValidPhoneNumber(phoneController.text) &&
          _isTermsAccepted.value;
    } else if (isEmailLogin.value) {
      final isValid =
          AppValidator.isValidEmail(emailController.text) &&
          passwordController.text.length >= 6;
      _isButtonEnabled.value = isValid && _isTermsAccepted.value;
    } else {
      final input = phoneController.text.trim();
      final isInputValid = AppValidator.isValidPhoneOrEmail(input);
      _isButtonEnabled.value = isInputValid && _isTermsAccepted.value;
    }
  }

  void toggleTermsAcceptance() {
    _isTermsAccepted.value = !_isTermsAccepted.value;
    _validateInput();
  }

  /// Send OTP via POST /patient/register (type: RLOGIN)
  Future<void> sendOTP() async {
    final input = phoneController.text.trim();

    if (!AppValidator.isValidPhoneOrEmail(input)) {
      ToastCustom.showSnackBar(
        subtitle: 'Please enter a valid phone number or email',
      );
      return;
    }

    if (!_isTermsAccepted.value) {
      ToastCustom.showSnackBar(subtitle: 'Please accept terms and conditions');
      return;
    }

    try {
      _isLoading.value = true;
      final result = await _repository.sendOtp(value: input, type: 'RLOGIN');
      PrintLog.printLog('OTP response: ${result.message}');

      ToastCustom.showSnackBar(subtitle: result.message, isSuccess: true);

      final isInputEmail = AppValidator.isValidEmail(input);
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'input': input,
          'action': 'RLOGIN',
          'isEmail': isInputEmail,
        },
      );
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// Link flow: POST /patient/link then navigate to OTP
  Future<void> sendLinkOTP() async {
    final isEmail = loginMode.value == LoginMode.linkEmail;
    final input = isEmail
        ? emailController.text.trim()
        : phoneController.text.trim();

    if (isEmail && !AppValidator.isValidEmail(input)) {
      ToastCustom.showSnackBar(subtitle: 'Please enter a valid email');
      return;
    }
    if (!isEmail && !AppValidator.isValidPhoneNumber(input)) {
      ToastCustom.showSnackBar(subtitle: 'Please enter a valid phone number');
      return;
    }

    try {
      _isLoading.value = true;
      final result = await _repository.linkAccount(value: input);
      PrintLog.printLog('Link OTP response: ${result.message}');

      ToastCustom.showSnackBar(subtitle: result.message, isSuccess: true);

      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'input': input,
          'action': 'LINK',
          'isEmail': isEmail,
          'loginType': 'link',
        },
      );
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// Password login via POST /patient/login
  Future<void> loginWithEmail() async {
    PrintLog.printLog('loginWithEmail');
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!AppValidator.isValidEmail(email)) {
      ToastCustom.showSnackBar(subtitle: 'Please enter a valid email');
      return;
    }

    if (password.length < 6) {
      ToastCustom.showSnackBar(
        subtitle: 'Password must be at least 6 characters',
      );
      return;
    }

    if (!_isTermsAccepted.value) {
      ToastCustom.showSnackBar(subtitle: 'Please accept terms and conditions');
      return;
    }

    try {
      _isLoading.value = true;
      final result = await _repository.loginWithPassword(
        email: email,
        password: password,
      );

      accessToken = result.token;
      await AppSecureStorage.saveLoginResponse(result.toLoginResponse());

      if (result.isReg) {
        await AppSecureStorage.setHealthStatus(1);
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        await AppSecureStorage.setHealthStatus(0);
        Get.offAllNamed(AppRoutes.healthScore);
      }
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
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

  void onBackPressed() {
    Get.back();
  }
}
