import 'package:flip_health/model/vvd%20models/vendor_model.dart';

class VisionNetworkModel {
  final String id;
  final String name;
  final String phone;
  final String? displayAddress;
  final VisionNetworkAddress? address;
  final String type;
  final List<String> serviceType;
  final String coordinates;
  final int vendorId;
  final VisionVendorInfo? vendor;

  const VisionNetworkModel({
    required this.id,
    required this.name,
    this.phone = '',
    this.displayAddress,
    this.address,
    this.type = '',
    this.serviceType = const [],
    this.coordinates = '',
    this.vendorId = 0,
    this.vendor,
  });

  factory VisionNetworkModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return VisionNetworkModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      displayAddress: json['display_address']?.toString(),
      address: json['address'] is Map<String, dynamic>
          ? VisionNetworkAddress.fromJson(json['address'])
          : null,
      type: (json['type'] ?? '').toString(),
      serviceType: parseStringList(json['service_type']),
      coordinates: (json['coordinates'] ?? '').toString(),
      vendorId: json['vendor_id'] is int
          ? json['vendor_id']
          : int.tryParse(json['vendor_id'].toString()) ?? 0,
      vendor: json['vendor'] is Map<String, dynamic>
          ? VisionVendorInfo.fromJson(json['vendor'])
          : null,
    );
  }

  String get resolvedAddress {
    if (displayAddress != null && displayAddress!.trim().isNotEmpty) {
      return displayAddress!;
    }
    if (address == null) return '';
    final parts = [
      address!.line1,
      address!.line2,
      address!.city,
      address!.state,
      address!.country,
      address!.pincode,
      address!.landmark,
    ].where((s) => s.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  VendorModel toVendorModel() {
    return VendorModel(
      id: id,
      name: name,
      address: resolvedAddress,
      city: address?.city ?? '',
      phone: phone.isNotEmpty ? phone : null,
      clinicId: id,
      providerId: vendorId.toString(),
    );
  }
}

class VisionNetworkAddress {
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String landmark;

  const VisionNetworkAddress({
    this.line1 = '',
    this.line2 = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.pincode = '',
    this.landmark = '',
  });

  factory VisionNetworkAddress.fromJson(Map<String, dynamic> json) {
    return VisionNetworkAddress(
      line1: (json['line_1'] ?? '').toString(),
      line2: (json['line_2'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      pincode: (json['pincode'] ?? '').toString(),
      landmark: (json['landmark'] ?? '').toString(),
    );
  }
}

class VisionVendorInfo {
  final int id;
  final String name;
  final String logo;
  final List<String> type;

  const VisionVendorInfo({
    this.id = 0,
    this.name = '',
    this.logo = '',
    this.type = const [],
  });

  factory VisionVendorInfo.fromJson(Map<String, dynamic> json) {
    return VisionVendorInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      logo: (json['logo'] ?? '').toString(),
      type: json['type'] is List
          ? (json['type'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }
}
