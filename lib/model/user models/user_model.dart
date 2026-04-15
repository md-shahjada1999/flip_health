class CompanyModel {
  final int id;
  final String name;
  final String? image;
  final String code;

  const CompanyModel({
    required this.id,
    required this.name,
    this.image,
    required this.code,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        image: json['image'],
        code: json['code'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'code': code,
      };
}

class HealthScoreModel {
  final double? value;
  final String? unit;
  final String? category;
  final Map<String, dynamic>? details;

  const HealthScoreModel({this.value, this.unit, this.category, this.details});

  factory HealthScoreModel.fromJson(Map<String, dynamic> json) =>
      HealthScoreModel(
        value: (json['value'] as num?)?.toDouble(),
        unit: json['unit'],
        category: json['category'],
        details: json['details'] is Map ? Map<String, dynamic>.from(json['details']) : null,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        'unit': unit,
        'category': category,
        'details': details,
      };
}

class UserModel {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? dob;
  final String? image;
  final String? gender;
  final String? isBloodPressure;
  final String? isDiabetic;
  final String? bloodGroup;
  final String? occupation;
  final String? language;
  final bool vip;
  final String? empId;
  final String? deviceId;
  final String? platform;
  final String? refCode;
  final String? relationship;
  final int age;
  final String type;
  final String primary;
  final int freeConsultations;
  final int corporateId;
  final int status;
  final bool isSubscribed;
  /// Active subscription rows from profile/login — used for `plan.dependent_add`, etc.
  final List<Map<String, dynamic>> subscriptions;
  final CompanyModel? company;
  final HealthScoreModel? healthScore;

  const UserModel({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.dob,
    this.image,
    this.gender,
    this.isBloodPressure,
    this.isDiabetic,
    this.bloodGroup,
    this.occupation,
    this.language,
    this.vip = false,
    this.empId,
    this.deviceId,
    this.platform,
    this.refCode,
    this.relationship,
    this.age = 0,
    this.type = 'patient',
    this.primary = '',
    this.freeConsultations = 0,
    this.corporateId = 0,
    this.status = 1,
    this.isSubscribed = false,
    this.subscriptions = const [],
    this.company,
    this.healthScore,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: _toInt(json['id']),
        name: _toStr(json['name']),
        firstName: _toStr(json['first_name'] ?? json['name']),
        lastName: _toStr(json['last_name']),
        email: _toStr(json['email']),
        phone: _toStr(json['phone']),
        dob: json['dob']?.toString(),
        image: json['image']?.toString(),
        gender: json['gender']?.toString(),
        isBloodPressure: json['isBloodPressure']?.toString(),
        isDiabetic: json['isDiabetic']?.toString(),
        bloodGroup: json['bloodGroup']?.toString(),
        occupation: json['occupation']?.toString(),
        language: json['language']?.toString(),
        vip: json['vip'] == true,
        empId: json['empId']?.toString(),
        deviceId: json['device_id']?.toString(),
        platform: json['platform']?.toString(),
        refCode: json['ref_code']?.toString(),
        relationship: json['relationship']?.toString(),
        age: _toInt(json['age']),
        type: _toStr(json['type'], fallback: 'patient'),
        primary: _toStr(json['primary']),
        freeConsultations: _toInt(json['freeConsultations']),
        corporateId: _toInt(json['corporate_id']),
        status: _toInt(json['status'], fallback: 1),
        isSubscribed: json['isSubscribed'] == true || json['isSubscribed'] == 1,
        subscriptions: _subscriptionListFromJson(json['subscription'] ?? json['subscriptions']),
        company: json['company'] is Map
            ? CompanyModel.fromJson(Map<String, dynamic>.from(json['company']))
            : null,
        healthScore: json['health_score'] is Map
            ? HealthScoreModel.fromJson(Map<String, dynamic>.from(json['health_score']))
            : null,
      );

  static String _toStr(dynamic v, {String fallback = ''}) =>
      v?.toString() ?? fallback;

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static List<Map<String, dynamic>> _subscriptionListFromJson(dynamic v) {
    if (v is! List) return [];
    return v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'dob': dob,
        'image': image,
        'gender': gender,
        'isBloodPressure': isBloodPressure,
        'isDiabetic': isDiabetic,
        'bloodGroup': bloodGroup,
        'occupation': occupation,
        'language': language,
        'vip': vip,
        'empId': empId,
        'device_id': deviceId,
        'platform': platform,
        'ref_code': refCode,
        'relationship': relationship,
        'age': age,
        'type': type,
        'primary': primary,
        'freeConsultations': freeConsultations,
        'corporate_id': corporateId,
        'status': status,
        'isSubscribed': isSubscribed,
        'subscription': subscriptions,
        'company': company?.toJson(),
        'health_score': healthScore?.toJson(),
      };
}

class LoginResponse {
  final String token;
  final UserModel user;
  final bool isReg;
  final String link;
  final String message;

  const LoginResponse({
    required this.token,
    required this.user,
    this.isReg = true,
    this.link = 'NONE',
    this.message = '',
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] ?? '',
        user: UserModel.fromJson(json['user'] ?? {}),
        isReg: json['isReg'] ?? true,
        link: json['link'] ?? 'NONE',
        message: json['message'] ?? '',
      );

  bool get needsLinking => link != 'NONE';
  bool get needsEmailLink => link == 'EMAIL';
  bool get needsPhoneLink => link == 'PHONE';
}
