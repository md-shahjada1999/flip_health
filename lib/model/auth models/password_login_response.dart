import 'package:flip_health/model/user%20models/user_model.dart';

/// Response from POST /patient/login (password-based login)
///
/// Same shape as verify OTP but kept separate for clarity.
/// No `link` flow needed for password login.
class PasswordLoginResponse {
  final UserModel user;
  final String token;
  final bool isReg;
  final String message;

  const PasswordLoginResponse({
    required this.user,
    required this.token,
    this.isReg = true,
    this.message = '',
  });

  factory PasswordLoginResponse.fromJson(Map<String, dynamic> json) =>
      PasswordLoginResponse(
        user: UserModel.fromJson(json['user'] ?? {}),
        token: json['token'] ?? '',
        isReg: json['isReg'] ?? true,
        message: json['message'] ?? '',
      );

  /// Convert to LoginResponse for storage compatibility
  LoginResponse toLoginResponse() => LoginResponse(
        token: token,
        user: user,
        isReg: isReg,
        message: message,
      );
}
