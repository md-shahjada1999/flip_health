import 'dart:async';

import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/controllers/auth%20controllers/login_controller.dart';
import 'package:flip_health/data/repositories/auth_repository.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';

class OTPController extends GetxController {
  final AuthRepository _repository;

  OTPController({required AuthRepository repository})
      : _repository = repository;

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final RxList<String> otpValues = List.filled(6, '').obs;

  final RxBool _isButtonEnabled = false.obs;
  final RxBool _isLoading = false.obs;
  final RxInt _resendTimer = 30.obs;
  final RxBool _canResend = false.obs;
  final RxString _phoneNumber = ''.obs;
  final RxString _action = 'RLOGIN'.obs;
  final RxBool _isEmail = false.obs;
  final RxString _loginType = ''.obs;

  Timer? _timer;

  bool get isButtonEnabled => _isButtonEnabled.value;
  bool get isLoading => _isLoading.value;
  int get resendTimer => _resendTimer.value;
  bool get canResend => _canResend.value;
  String get phoneNumber => _phoneNumber.value;
  bool get isEmail => _isEmail.value;
  bool get isLinkFlow => _loginType.value == 'link';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phoneNumber.value = args['input'] ?? '';
      _action.value = args['action'] ?? 'RLOGIN';
      _isEmail.value = args['isEmail'] ?? false;
      _loginType.value = args['loginType'] ?? '';
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
    _isButtonEnabled.value = otpValues.every((v) => v.length == 1);
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

  /// Verify OTP -- either normal verify or link verify depending on flow
  Future<void> verifyOTP() async {
    final otp = _getOTP();
    if (otp.length != otpControllers.length) {
      ToastCustom.showSnackBar(subtitle: 'Please enter all digits');
      return;
    }

    try {
      _isLoading.value = true;

      if (isLinkFlow) {
        await _verifyLinkOTP(otp);
      } else {
        await _verifyLoginOTP(otp);
      }
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
      _clearOTP();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Normal verify: POST /patient/verify
  Future<void> _verifyLoginOTP(String otp) async {
    final result = await _repository.verifyOtp(
      action: _action.value,
      value: _phoneNumber.value,
      code: otp,
    );

    PrintLog.printLog('Verify response - token: ${result.token.isNotEmpty}, '
        'isReg: ${result.isReg}, link: ${result.link}');

    accessToken = result.token;
    await AppSecureStorage.saveLoginResponse(result.toLoginResponse());

    ToastCustom.showSnackBar(
      subtitle: result.message.isNotEmpty ? result.message : 'OTP verified',
      isSuccess: true,
    );

    if (result.needsLinking) {
      _handleLinkFlow(result.link);
      return;
    }

    _handlePostLogin(result.isReg);
  }

  /// Link verify: POST /patient/vlink
  Future<void> _verifyLinkOTP(String otp) async {
    final result = await _repository.verifyLink(
      value: _phoneNumber.value,
      code: otp,
    );

    PrintLog.printLog('VerifyLink response - link: ${result.link}, '
        'isReg: ${result.isReg}');

    accessToken = result.token;
    await AppSecureStorage.saveLoginResponse(result.toLoginResponse());

    if (result.needsLinking) {
      _handleLinkFlow(result.link);
      return;
    }

    _handlePostLogin(result.isReg);
  }

  /// Redirect to login screen for the missing identifier
  void _handleLinkFlow(String linkType) {
    PrintLog.printLog('Link flow needed: $linkType');

    // Remove old LoginController so a fresh one is created with the link args
    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>(force: true);
    }

    Get.offNamed(AppRoutes.login, arguments: {
      'linkType': linkType,
    });
  }

  /// Route based on isReg: true -> Dashboard, false -> Health Score
  void _handlePostLogin(bool isReg) {
    if (isReg) {
      AppSecureStorage.setHealthStatus(1);
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      AppSecureStorage.setHealthStatus(0);
      Get.offAllNamed(AppRoutes.healthScore);
    }
  }

  Future<void> resendOTP() async {
    if (!canResend) return;

    try {
      _isLoading.value = true;
      final result = await _repository.resendOtp(
        value: _phoneNumber.value,
      );
      ToastCustom.showSnackBar(subtitle: result.message, isSuccess: true);
      _clearOTP();
      _startResendTimer();
    } catch (e) {
      ToastCustom.showSnackBar(subtitle: e.toString());
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
