import 'package:flip_health/model/user%20models/user_model.dart';

/// Response from POST /patient/verify and POST /patient/vlink
///
/// Example:
/// ```json
/// {
///   "user": { ... },
///   "token": "jwt...",
///   "isReg": true,
///   "link": "NONE",
///   "message": "OTP Successfully Verified"
/// }
/// ```
class VerifyOtpResponse {
  final UserModel user;
  final String token;
  final bool isReg;
  final String link;
  final String message;

  const VerifyOtpResponse({
    required this.user,
    required this.token,
    this.isReg = true,
    this.link = 'NONE',
    this.message = '',
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        user: UserModel.fromJson(json['user'] ?? {}),
        token: json['token'] ?? '',
        isReg: json['isReg'] ?? true,
        link: json['link'] ?? 'NONE',
        message: json['message'] ?? '',
      );

  bool get needsLinking => link != 'NONE';
  bool get needsEmailLink => link == 'EMAIL';
  bool get needsPhoneLink => link == 'PHONE';

  /// Convert to LoginResponse for storage compatibility
  LoginResponse toLoginResponse() => LoginResponse(
        token: token,
        user: user,
        isReg: isReg,
        link: link,
        message: message,
      );
}
