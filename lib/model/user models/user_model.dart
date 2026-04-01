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
    this.company,
    this.healthScore,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        firstName: json['first_name'] ?? json['name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        dob: json['dob'],
        image: json['image'],
        gender: json['gender'],
        isBloodPressure: json['isBloodPressure'],
        isDiabetic: json['isDiabetic'],
        bloodGroup: json['bloodGroup'],
        occupation: json['occupation'],
        language: json['language'],
        vip: json['vip'] ?? false,
        empId: json['empId'],
        deviceId: json['device_id'],
        platform: json['platform'],
        refCode: json['ref_code'],
        relationship: json['relationship'],
        age: json['age'] ?? 0,
        type: json['type'] ?? 'patient',
        primary: json['primary']?.toString() ?? '',
        freeConsultations: json['freeConsultations'] ?? 0,
        corporateId: json['corporate_id'] ?? 0,
        status: json['status'] ?? 1,
        isSubscribed: json['isSubscribed'] == true || json['isSubscribed'] == 1,
        company: json['company'] != null
            ? CompanyModel.fromJson(json['company'])
            : null,
        healthScore: json['health_score'] != null
            ? HealthScoreModel.fromJson(json['health_score'])
            : null,
      );

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
        'company': company?.toJson(),
        'health_score': healthScore?.toJson(),
      };
}

class LoginResponse {
  final String token;
  final UserModel user;

  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] ?? '',
        user: UserModel.fromJson(json['user'] ?? {}),
      );
}
