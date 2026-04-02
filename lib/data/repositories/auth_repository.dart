import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/auth%20models/otp_send_response.dart';
import 'package:flip_health/model/auth%20models/password_login_response.dart';
import 'package:flip_health/model/auth%20models/verify_otp_response.dart';
import 'package:flip_health/model/auth%20models/vlink_response.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository({required this.apiService});

  /// POST /patient/register -- send OTP for login or signup
  Future<OtpSendResponse> sendOtp({
    required String value,
    required String type,
    bool corporate = true,
    bool tcAccepted = true,
  }) async {
    try {
      final body = {
        'phone': value,
        'type': type,
        'corporate': corporate,
        'tc_accepted': tcAccepted,
      };
      PrintLog.printLog('Register body: $body');

      final response = await apiService.post(ApiUrl.REGISTER, data: body);
      PrintLog.printLog('Register status: ${response.statusCode}');

      final data = _ensureMap(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return OtpSendResponse.fromJson(data);
      }
      throw AppException(
        message: data['message'] ?? 'Failed to send OTP',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('sendOtp error: $e');
      throw AppException(message: 'Failed to send OTP. Please try again.');
    }
  }

  /// POST /patient/verify -- verify OTP, returns user + token + link + isReg
  Future<VerifyOtpResponse> verifyOtp({
    required String action,
    required String value,
    required String code,
    String? fcmToken,
  }) async {
    try {
      final body = {
        'action': action,
        'value': value,
        'code': code,
        if (fcmToken != null) 'fcm_token': fcmToken,
      };
      PrintLog.printLog('Verify body: $body');

      final response = await apiService.post(ApiUrl.VERIFY_OTP, data: body);
      PrintLog.printLog('Verify status: ${response.statusCode}');

      final data = _ensureMap(response.data);
      if (response.statusCode == 200 && data['token'] != null) {
        return VerifyOtpResponse.fromJson(data);
      }
      throw AppException(
        message: data['message'] ?? 'Verification failed',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('verifyOtp error: $e');
      throw AppException(message: 'OTP verification failed. Please try again.');
    }
  }

  /// POST /patient/link -- request linking email/phone to account
  Future<OtpSendResponse> linkAccount({
    required String value,
  }) async {
    try {
      final body = {
        'value': value,
      };
      PrintLog.printLog('Link body: $body');

      final response = await apiService.post(ApiUrl.LINK, data: body);
      PrintLog.printLog('Link status: ${response.statusCode}');

      final data = _ensureMap(response.data);
      if (response.statusCode == 200) {
        return OtpSendResponse.fromJson(data);
      }
      throw AppException(
        message: data['message'] ?? 'Failed to send link OTP',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('linkAccount error: $e');
      throw AppException(message: 'Failed to link account. Please try again.');
    }
  }

  /// POST /patient/vlink -- verify the link OTP
  Future<VlinkResponse> verifyLink({
    required String value,
    required String code,
  }) async {
    try {
      final body = {
        'action': 'LINK',
        'value': value,
        'code': code,
      };
      PrintLog.printLog('VerifyLink body: $body');

      final response = await apiService.post(ApiUrl.VERIFY_LINK, data: body);
      PrintLog.printLog('VerifyLink status: ${response.statusCode}');

      final data = _ensureMap(response.data);
      if (response.statusCode == 200 && data['token'] != null) {
        return VlinkResponse.fromJson(data);
      }
      throw AppException(
        message: data['message'] ?? 'Link verification failed',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('verifyLink error: $e');
      throw AppException(message: 'Link verification failed. Please try again.');
    }
  }

  /// POST /patient/login -- password-based login
  Future<PasswordLoginResponse> loginWithPassword({
    required String email,
    required String password,
    bool corporate = true,
    String? fcmToken,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
        'corporate': corporate,
        if (fcmToken != null) 'fcm_token': fcmToken,
      };
      PrintLog.printLog('Login body: $body');

      final response = await apiService.post(ApiUrl.LOGIN, data: body);
      PrintLog.printLog('Login status: ${response.statusCode}');

      final data = _ensureMap(response.data);
      if (response.statusCode == 200 && data['token'] != null) {
        return PasswordLoginResponse.fromJson(data);
      }
      throw AppException(
        message: data['message'] ?? 'Login failed',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('loginWithPassword error: $e');
      throw AppException(message: 'Login failed. Please try again.');
    }
  }

  /// POST /patient/resendotp
  Future<OtpSendResponse> resendOtp({required String value}) async {
    try {
      final body = {'value': value};
      final response = await apiService.post(ApiUrl.RESEND_OTP, data: body);

      final data = _ensureMap(response.data);
      return OtpSendResponse.fromJson(data);
    } catch (e) {
      PrintLog.printLog('resendOtp error: $e');
      throw AppException(message: 'Failed to resend OTP.');
    }
  }

  Map<String, dynamic> _ensureMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw AppException(message: 'Unexpected response format');
  }
}
