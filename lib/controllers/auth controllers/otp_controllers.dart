import 'dart:async';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OTPController extends GetxController {
  // Controllers & focus nodes
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  // Reactive OTP values
  final RxList<String> otpValues = List.filled(6, '').obs;

  // Other reactive state
  final RxBool _isButtonEnabled = false.obs;
  final RxBool _isLoading = false.obs;
  final RxInt _resendTimer = 30.obs;
  final RxBool _canResend = false.obs;
  final RxString _phoneNumber = ''.obs;
  final RxBool _isEmail = false.obs;

  Timer? _timer;

  // Getters
  bool get isButtonEnabled => _isButtonEnabled.value;
  bool get isLoading => _isLoading.value;
  int get resendTimer => _resendTimer.value;
  bool get canResend => _canResend.value;
  String get phoneNumber => _phoneNumber.value;
  bool get isEmail => _isEmail.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phoneNumber.value = args['input'] ?? '';
      _isEmail.value = args['isEmail'] ?? false;
    }

    _startResendTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNodes.isNotEmpty) focusNodes[0].requestFocus();
    });
  }

  @override
  void onClose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.onClose();
  }

  void onOTPChanged(String value, int index) {
    otpValues[index] = value;

    if (value.length == 1) {
      if (index < otpControllers.length - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    _validateOTP();
  }

  void _validateOTP() {
    bool allFilled = otpValues.every((v) => v.length == 1);
    _isButtonEnabled.value = allFilled;
  }

  String _getOTP() => otpValues.join();

  void _startResendTimer() {
    _resendTimer.value = 30;
    _canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer.value > 0) {
        _resendTimer.value--;
      } else {
        _canResend.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> verifyOTP() async {
    final otp = _getOTP();
    if (otp.length != otpControllers.length) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter all digits of the OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    try {
      _isLoading.value = true;
      // simulate API call
      await Future.delayed(const Duration(seconds: 2));
      // On success
      Get.snackbar(
        'Success',
        'OTP verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      _clearOTP();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resendOTP() async {
    if (!canResend) return;

    try {
      _isLoading.value = true;
      // simulate resend
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        'OTP Sent',
        'A new OTP has been sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
      _clearOTP();
      _startResendTimer();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _clearOTP() {
    for (int i = 0; i < otpControllers.length; i++) {
      otpControllers[i].clear();
      otpValues[i] = '';
    }
    _isButtonEnabled.value = false;
    if (focusNodes.isNotEmpty) focusNodes[0].requestFocus();
  }

  void editPhoneNumber() {
    Get.back();
  }
}
