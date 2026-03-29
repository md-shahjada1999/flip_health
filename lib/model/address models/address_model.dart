enum AddressType { home, office, other }

class AddressModel {
  final String id;
  final String label;
  final String fullAddress;
  final String? houseNumber;
  final String? landmark;
  final String? pincode;
  final String? city;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final AddressType type;

  const AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.houseNumber,
    this.landmark,
    this.pincode,
    this.city,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.type = AddressType.home,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? houseNumber,
    String? landmark,
    String? pincode,
    String? city,
    double? latitude,
    double? longitude,
    bool? isDefault,
    AddressType? type,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      houseNumber: houseNumber ?? this.houseNumber,
      landmark: landmark ?? this.landmark,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
    );
  }
}
