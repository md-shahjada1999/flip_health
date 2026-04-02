import 'package:flip_health/model/user%20models/user_model.dart';

/// Lightweight user returned by POST /patient/vlink
class VlinkUserModel {
  final int id;
  final String phone;
  final String email;
  final String name;
  final String primary;
  final String type;
  final String userType;
  final int corporateId;
  final String access;

  const VlinkUserModel({
    required this.id,
    required this.phone,
    required this.email,
    required this.name,
    required this.primary,
    required this.type,
    required this.userType,
    required this.corporateId,
    required this.access,
  });

  factory VlinkUserModel.fromJson(Map<String, dynamic> json) =>
      VlinkUserModel(
        id: _toInt(json['id']),
        phone: _toStr(json['phone']),
        email: _toStr(json['email']),
        name: _toStr(json['name']),
        primary: _toStr(json['primary']),
        type: _toStr(json['type'], fallback: 'patient'),
        userType: _toStr(json['user_type'], fallback: 'patient'),
        corporateId: _toInt(json['corporate_id']),
        access: _toStr(json['access']),
      );

  /// Convert to full UserModel with defaults for missing fields
  UserModel toUserModel() => UserModel(
        id: id,
        name: name,
        firstName: name.split(' ').first,
        lastName: name.split(' ').length > 1
            ? name.split(' ').sublist(1).join(' ')
            : '',
        email: email,
        phone: phone,
        primary: primary,
        type: type,
        corporateId: corporateId,
      );

  static String _toStr(dynamic v, {String fallback = ''}) =>
      v?.toString() ?? fallback;

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }
}

/// Response from POST /patient/vlink
///
/// Example:
/// ```json
/// {
///   "user": { "id": 1003080, "phone": "9849777206", ... },
///   "link": "NONE",
///   "token": "jwt...",
///   "isReg": false,
///   "message": "OTP Successfully Verified"
/// }
/// ```
class VlinkResponse {
  final VlinkUserModel user;
  final String link;
  final String token;
  final bool isReg;
  final String message;

  const VlinkResponse({
    required this.user,
    required this.link,
    required this.token,
    required this.isReg,
    required this.message,
  });

  factory VlinkResponse.fromJson(Map<String, dynamic> json) => VlinkResponse(
        user: VlinkUserModel.fromJson(json['user'] ?? {}),
        link: json['link']?.toString() ?? 'NONE',
        token: json['token']?.toString() ?? '',
        isReg: json['isReg'] == true,
        message: json['message']?.toString() ?? '',
      );

  bool get needsLinking => link != 'NONE';
  bool get needsEmailLink => link == 'EMAIL';
  bool get needsPhoneLink => link == 'PHONE';

  /// Convert to LoginResponse for storage compatibility
  LoginResponse toLoginResponse() => LoginResponse(
        token: token,
        user: user.toUserModel(),
        isReg: isReg,
        link: link,
        message: message,
      );
}
