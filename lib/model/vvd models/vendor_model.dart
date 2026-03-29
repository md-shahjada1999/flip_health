class VendorModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String distance;
  final String? phone;
  final String? locationUrl;

  VendorModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.distance = '0',
    this.phone,
    this.locationUrl,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      distance: json['distance']?.toString() ?? '0',
      phone: json['phone'],
      locationUrl: json['locationUrl'],
    );
  }
}
