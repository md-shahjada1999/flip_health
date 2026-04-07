class OfflineSpecialityModel {
  final int id;
  final String name;
  final int consultationTime;
  final int consultationPrice;
  final int consultationType;
  final int status;

  const OfflineSpecialityModel({
    required this.id,
    required this.name,
    this.consultationTime = 15,
    this.consultationPrice = 0,
    this.consultationType = 1,
    this.status = 1,
  });

  factory OfflineSpecialityModel.fromJson(Map<String, dynamic> json) {
    return OfflineSpecialityModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      consultationTime: json['consultation_time'] is int
          ? json['consultation_time']
          : int.tryParse(json['consultation_time'].toString()) ?? 15,
      consultationPrice: json['consultation_price'] is int
          ? json['consultation_price']
          : int.tryParse(json['consultation_price'].toString()) ?? 0,
      consultationType: json['consultation_type'] is int
          ? json['consultation_type']
          : int.tryParse(json['consultation_type'].toString()) ?? 1,
      status: json['status'] is int ? json['status'] : 1,
    );
  }

  static List<OfflineSpecialityModel> fromListResponse(
      Map<String, dynamic> json) {
    final list = json['specialities'] as List<dynamic>? ?? [];
    return list
        .map((e) => OfflineSpecialityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
