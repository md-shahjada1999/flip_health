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
  final bool isSponsored;
  final String? sponsoredBy;
  final bool hasPackages;
  final int corporateId;
  final bool isSubscribed;

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
    this.isSponsored = false,
    this.sponsoredBy,
    this.hasPackages = false,
    this.corporateId = 0,
    this.isSubscribed = false,
  });

  /// Parse from the /patient/member API response item
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final rel = (json['relationship'] ?? '').toString().trim();
    final isPrimary = rel.isEmpty || rel == 'employee';
    final subscribed =
        json['isSubscribed'] == true || json['isSubscribed'] == 1;

    return FamilyMember(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      dob: json['dob'],
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      relationship: rel.isNotEmpty ? rel : 'self',
      empId: json['empId'],
      image: json['image'],
      age: json['age'] ?? 0,
      isSponsored: isPrimary,
      sponsoredBy: isPrimary ? 'your company' : null,
      hasPackages: subscribed || (json['canActivate'] == 1),
      corporateId: json['corporate_id'] ?? 0,
      isSubscribed: subscribed,
    );
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
        'isSponsored': isSponsored,
        'sponsoredBy': sponsoredBy,
        'hasPackages': hasPackages,
        'corporate_id': corporateId,
        'isSubscribed': isSubscribed,
      };

  /// Parse the full members API response: { "members": [...] }
  static List<FamilyMember> fromMembersResponse(Map<String, dynamic> json) {
    final list = json['members'] as List<dynamic>? ?? [];
    return list
        .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
