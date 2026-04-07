class OnlineDoctorModel {
  final int id;
  final String name;
  final String? image;
  final String experience;
  final String gender;
  final String language;
  final String qualification;
  final String specialityName;
  final int specialityId;
  final String? nextAvailableTime;

  const OnlineDoctorModel({
    required this.id,
    required this.name,
    this.image,
    this.experience = '',
    this.gender = '',
    this.language = '',
    this.qualification = '',
    this.specialityName = '',
    this.specialityId = 0,
    this.nextAvailableTime,
  });

  factory OnlineDoctorModel.fromJson(Map<String, dynamic> json) {
    final spec = json['speciality'] as Map<String, dynamic>? ?? {};
    return OnlineDoctorModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      image: json['image']?.toString(),
      experience: (json['experience'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      language: (json['language'] ?? '').toString(),
      qualification: (json['qualification'] ?? '').toString(),
      specialityName: (spec['name'] ?? '').toString(),
      specialityId: spec['id'] is int
          ? spec['id']
          : int.tryParse(spec['id'].toString()) ?? 0,
      nextAvailableTime: json['doctor_next_available_time']?.toString(),
    );
  }

  static List<OnlineDoctorModel> fromListResponse(Map<String, dynamic> json) {
    final list = json['doctors'] as List<dynamic>? ?? [];
    return list
        .map((e) => OnlineDoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<String> get languageList =>
      language.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}
