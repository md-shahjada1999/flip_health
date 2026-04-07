class PharmacyOrderResponse {
  final String message;
  final PharmacyOrderData? data;

  const PharmacyOrderResponse({required this.message, this.data});

  factory PharmacyOrderResponse.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderResponse(
      message: (json['message'] ?? '').toString(),
      data: json['data'] is Map<String, dynamic>
          ? PharmacyOrderData.fromJson(json['data'])
          : null,
    );
  }
}

class PharmacyOrderData {
  final String id;
  final int patientId;
  final List<Map<String, dynamic>> prescriptions;
  final String type;
  final int status;
  final String platform;
  final String invoiceId;
  final PharmacyOrderUser? user;

  const PharmacyOrderData({
    required this.id,
    required this.patientId,
    this.prescriptions = const [],
    this.type = 'PHARMACY',
    this.status = 0,
    this.platform = 'APP',
    this.invoiceId = '',
    this.user,
  });

  factory PharmacyOrderData.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderData(
      id: (json['id'] ?? '').toString(),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id'].toString()) ?? 0,
      prescriptions: (json['prescriptions'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      type: (json['type'] ?? 'PHARMACY').toString(),
      status: json['status'] is int ? json['status'] : 0,
      platform: (json['platform'] ?? 'APP').toString(),
      invoiceId: (json['invoice_id'] ?? '').toString(),
      user: json['user'] is Map<String, dynamic>
          ? PharmacyOrderUser.fromJson(json['user'])
          : null,
    );
  }
}

class PharmacyOrderUser {
  final int id;
  final String name;
  final String type;

  const PharmacyOrderUser({
    required this.id,
    required this.name,
    this.type = 'patient',
  });

  factory PharmacyOrderUser.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'patient').toString(),
    );
  }
}
