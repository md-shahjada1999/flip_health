class VaccineServiceResponse {
  final VaccineServiceData service;
  final String message;

  const VaccineServiceResponse({
    required this.service,
    required this.message,
  });

  factory VaccineServiceResponse.fromJson(Map<String, dynamic> json) {
    return VaccineServiceResponse(
      service: VaccineServiceData.fromJson(
        (json['service'] as Map<String, dynamic>?) ?? {},
      ),
      message: (json['message'] ?? '').toString(),
    );
  }
}

class VaccineServiceData {
  final String id;
  final int patientId;
  final String type;
  final int status;
  final String generatedOn;
  final String platform;
  final String language;
  final String visitType;
  final VaccineBookingDetails details;

  const VaccineServiceData({
    required this.id,
    required this.patientId,
    required this.type,
    required this.status,
    this.generatedOn = '',
    this.platform = '',
    this.language = '',
    this.visitType = '',
    required this.details,
  });

  factory VaccineServiceData.fromJson(Map<String, dynamic> json) {
    return VaccineServiceData(
      id: (json['id'] ?? '').toString(),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id'].toString()) ?? 0,
      type: (json['type'] ?? '').toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status'].toString()) ?? 0,
      generatedOn: (json['generated_on'] ?? '').toString(),
      platform: (json['platform'] ?? '').toString(),
      language: (json['language'] ?? '').toString(),
      visitType: (json['visit_type'] ?? '').toString(),
      details: VaccineBookingDetails.fromJson(
        (json['details'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class VaccineBookingDetails {
  final String alternatePhone;
  final String bookingTime;
  final String preferredDateTime;
  final List<String> request;
  final String conditions;
  final String note;

  const VaccineBookingDetails({
    this.alternatePhone = '',
    this.bookingTime = '',
    this.preferredDateTime = '',
    this.request = const [],
    this.conditions = '',
    this.note = '',
  });

  factory VaccineBookingDetails.fromJson(Map<String, dynamic> json) {
    return VaccineBookingDetails(
      alternatePhone: (json['alternate_phone'] ?? '').toString(),
      bookingTime: (json['booking_time'] ?? '').toString(),
      preferredDateTime: (json['preferred_date_time'] ?? '').toString(),
      request: (json['request'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      conditions: (json['conditions'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
    );
  }
}
