import 'package:flutter/foundation.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository({required this.apiService});

  Future<void> sendOtp({
    required String input,
    required String inputType,
  }) async {
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('Sending OTP to: $input ($inputType)');
    } catch (e) {
      throw AppException(message: 'Failed to send OTP. Please try again.');
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw AppException(message: 'Login failed. Please try again.');
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw AppException(message: 'OTP verification failed. Please try again.');
    }
  }

  Future<void> resendOtp({required String input}) async {
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw AppException(message: 'Failed to resend OTP.');
    }
  }
}
