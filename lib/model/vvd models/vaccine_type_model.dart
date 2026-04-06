class VaccineType {
  final int id;
  final String name;
  final String serviceType;
  final String type;
  final bool excludeOpdWallet;
  final bool excludeRewardPoints;

  const VaccineType({
    required this.id,
    required this.name,
    this.serviceType = '',
    this.type = '',
    this.excludeOpdWallet = false,
    this.excludeRewardPoints = false,
  });

  factory VaccineType.fromJson(Map<String, dynamic> json) {
    return VaccineType(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      serviceType: (json['service_type'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      excludeOpdWallet: json['excludeOpdWallet'] == true,
      excludeRewardPoints: json['excludeRewardPoints'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'service_type': serviceType,
        'type': type,
        'excludeOpdWallet': excludeOpdWallet,
        'excludeRewardPoints': excludeRewardPoints,
      };
}
