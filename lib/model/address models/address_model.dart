class AddressModel {
  final String id;
  final String name;
  final String tag;
  final String line1;
  final String? line2;
  final String? landmark;
  final String? area;
  final String city;
  final String? state;
  final String pincode;
  final String? location;
  final bool isPrimary;
  final int? userId;
  final String? userType;
  final String? createdAt;
  final String? updatedAt;

  const AddressModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.line1,
    this.line2,
    this.landmark,
    this.area,
    required this.city,
    this.state,
    required this.pincode,
    this.location,
    this.isPrimary = false,
    this.userId,
    this.userType,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      tag: json['tag'] ?? '',
      line1: json['line_1'] ?? '',
      line2: json['line_2'],
      landmark: json['landmark'],
      area: json['area'],
      city: json['city'] ?? '',
      state: json['state'],
      pincode: (json['pincode'] ?? '').toString(),
      location: json['location'],
      isPrimary: json['isPrimary'] == true,
      userId: json['user_id'] is int ? json['user_id'] : null,
      userType: json['user_type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line_1': line1,
      'line_2': line2 ?? '',
      'landmark': landmark ?? '',
      'area': area ?? '',
      'city': city,
      'state': state ?? '',
      'pincode': pincode,
      'location': location ?? '',
      'tag': tag,
      'name': name,
    };
  }

  /// Parse GET /address response: {"addressess": [...]}
  static List<AddressModel> fromListResponse(Map<String, dynamic> json) {
    final list = (json['addressess'] as List<dynamic>?) ??
        (json['data'] as List<dynamic>?) ??
        [];
    return list
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Parse POST /address response: {"data": {...}}
  static AddressModel fromSingleResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  String get fullAddress {
    final parts = <String>[
      line1,
      if (line2 != null && line2!.isNotEmpty) line2!,
      if (landmark != null && landmark!.isNotEmpty) landmark!,
      if (area != null && area!.isNotEmpty) area!,
      city,
      if (state != null && state!.isNotEmpty) state!,
      pincode,
    ];
    return parts.join(', ');
  }

  String get displayLabel => name.isNotEmpty ? name : tag;

  double? get latitude {
    if (location == null || !location!.contains(',')) return null;
    return double.tryParse(location!.split(',')[0]);
  }

  double? get longitude {
    if (location == null || !location!.contains(',')) return null;
    return double.tryParse(location!.split(',')[1]);
  }

  bool get isHome => tag.toUpperCase() == 'HOME';
  bool get isWork => tag.toUpperCase() == 'WORK';
}
