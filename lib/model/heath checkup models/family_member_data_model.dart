class FamilyMember {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? bloodGroup;
  final String? relationship;
  final String? empId;
  final String? image;
  final int age;
  final bool hasPackages;
  final int corporateId;
  final bool isSubscribed;
  /// From members API `AHCAvailable` — eligible for sponsored annual health checkup.
  final bool ahcAvailable;

  FamilyMember({
    required this.id,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    this.email,
    this.phone,
    this.dob,
    this.gender,
    this.bloodGroup,
    this.relationship,
    this.empId,
    this.image,
    this.age = 0,
    this.hasPackages = false,
    this.corporateId = 0,
    this.isSubscribed = false,
    this.ahcAvailable = false,
  });
factory FamilyMember.fromJson(Map<String, dynamic> json) {
  final rel = (json['relationship'] ?? '').toString().trim();
  final subscribed = json['isSubscribed'] == true || json['isSubscribed'] == 1;

  return FamilyMember(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    firstName: (json['first_name'] ?? json['name'] ?? '').toString(),
    lastName: (json['last_name'] ?? '').toString(),
    email: json['email']?.toString(),
    phone: json['phone']?.toString(),
    dob: json['dob']?.toString(),
    gender: json['gender']?.toString(),
    bloodGroup: json['bloodGroup']?.toString(),
    relationship: rel.isNotEmpty ? rel : 'self',
    empId: json['empId']?.toString(),
    image: json['image']?.toString(),
    age: _safeInt(json['age']),
    hasPackages: subscribed || json['canActivate'] == 1,
    corporateId: _safeInt(json['corporate_id']),
    isSubscribed: subscribed,
    ahcAvailable: json['AHCAvailable'] == true,
  );
}

static int _safeInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.round();
  return int.tryParse(v.toString()) ?? 0;
}
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'dob': dob,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'relationship': relationship,
        'empId': empId,
        'image': image,
        'age': age,
        'hasPackages': hasPackages,
        'corporate_id': corporateId,
        'isSubscribed': isSubscribed,
        'AHCAvailable': ahcAvailable,
      };

static List<FamilyMember> fromMembersResponse(Map<String, dynamic> json) {
  final list = json['members'] as List<dynamic>? ?? [];
  return list
      .whereType<Map>()
      .map((e) => FamilyMember.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}
}