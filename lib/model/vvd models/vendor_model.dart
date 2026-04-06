class VendorModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String distance;
  final String? phone;
  final String? locationUrl;

  /// Dental network API: clinic / provider identifiers for booking
  final String clinicId;
  final String providerId;

  /// Pincode from network payload (`pin`)
  final String pin;

  VendorModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.distance = '0',
    this.phone,
    this.locationUrl,
    this.clinicId = '',
    this.providerId = '',
    this.pin = '',
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    dynamic pickRaw(Iterable<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          final s = json[k].toString();
          if (s.isNotEmpty) return json[k];
        }
      }
      for (final e in json.entries) {
        final ek = e.key.toLowerCase();
        for (final k in keys) {
          if (ek == k.toLowerCase()) {
            return e.value;
          }
        }
      }
      return null;
    }

    String pickStr(Iterable<String> keys) {
      final v = pickRaw(keys);
      return v?.toString() ?? '';
    }

    final clinicId = pickStr(['clinicid', 'clinic_id', 'clinicId']);
    final providerId = pickStr(['providerid', 'provider_id', 'providerId']);
    final id = pickStr(['id', 'clinicid', 'clinic_id', 'clinicId']);
    final name = pickStr(['name', 'clinicname', 'clinic_name']);
    final address = pickStr([
      'address',
      'practiceaddress',
      'practice_address',
      'line_1',
      'line1',
    ]);
    final city = pickStr(['city']);
    final dist = pickStr(['distance']);
    final cell = pickStr(['cell', 'phone', 'mobile']);
    final pin = pickStr(['pin', 'pincode']);
    final loc = pickStr(['location', 'locationUrl']);

    return VendorModel(
      id: id.isNotEmpty ? id : clinicId,
      name: name,
      address: address,
      city: city,
      distance: dist.isNotEmpty ? dist : '0',
      phone: cell.isNotEmpty ? cell : null,
      locationUrl: loc.isNotEmpty ? loc : null,
      clinicId: clinicId.isNotEmpty ? clinicId : id,
      providerId: providerId,
      pin: pin,
    );
  }
}
