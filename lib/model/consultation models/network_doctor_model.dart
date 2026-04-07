class NetworkDoctorModel {
  final int id;
  final String name;
  final String experience;
  final String qualification;
  final String gender;
  final String networkId;
  final List<String> specialities;
  final NetworkInfo? network;

  const NetworkDoctorModel({
    required this.id,
    required this.name,
    this.experience = '',
    this.qualification = '',
    this.gender = '',
    this.networkId = '',
    this.specialities = const [],
    this.network,
  });

  factory NetworkDoctorModel.fromJson(Map<String, dynamic> json) {
    final specList = json['specialities'] as List<dynamic>? ?? [];
    final specNames = specList.map((e) {
      if (e is Map<String, dynamic>) {
        final info = e['speciality_info'] as Map<String, dynamic>?;
        return (info?['name'] ?? '').toString();
      }
      return e.toString();
    }).where((n) => n.isNotEmpty).toList();

    return NetworkDoctorModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      experience: (json['experience'] ?? '').toString(),
      qualification: (json['qualification'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      networkId: (json['network_id'] ?? '').toString(),
      specialities: specNames,
      network: json['network'] != null
          ? NetworkInfo.fromJson(json['network'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<NetworkDoctorModel> fromListResponse(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => NetworkDoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class NetworkInfo {
  final String id;
  final String name;
  final String displayAddress;
  final String phone;
  final VendorInfo? vendor;

  const NetworkInfo({
    required this.id,
    this.name = '',
    this.displayAddress = '',
    this.phone = '',
    this.vendor,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      displayAddress: (json['display_address'] ?? json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      vendor: json['vendor'] != null
          ? VendorInfo.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VendorInfo {
  final int id;
  final String name;
  final String phone;
  final String email;

  const VendorInfo({
    this.id = 0,
    this.name = '',
    this.phone = '',
    this.email = '',
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}
