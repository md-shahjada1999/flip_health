class VisionBookingResponse {
  final VisionBookingService service;
  final String message;

  const VisionBookingResponse({
    required this.service,
    required this.message,
  });

  factory VisionBookingResponse.fromJson(Map<String, dynamic> json) {
    return VisionBookingResponse(
      service: VisionBookingService.fromJson(
        (json['service'] as Map<String, dynamic>?) ?? {},
      ),
      message: (json['message'] ?? '').toString(),
    );
  }
}

class VisionBookingService {
  final String id;
  final int patientId;
  final String type;
  final int status;
  final String generatedOn;
  final String platform;
  final String visitType;
  final String networkId;
  final VisionBookingDetails details;

  const VisionBookingService({
    required this.id,
    this.patientId = 0,
    this.type = '',
    this.status = 0,
    this.generatedOn = '',
    this.platform = '',
    this.visitType = '',
    this.networkId = '',
    required this.details,
  });

  factory VisionBookingService.fromJson(Map<String, dynamic> json) {
    return VisionBookingService(
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
      visitType: (json['visit_type'] ?? '').toString(),
      networkId: (json['network_id'] ?? '').toString(),
      details: VisionBookingDetails.fromJson(
        (json['details'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class VisionBookingDetails {
  final String bookingType;
  final String bookingTime;
  final String preferredDateTime;
  final Map<String, dynamic> slot;

  const VisionBookingDetails({
    this.bookingType = '',
    this.bookingTime = '',
    this.preferredDateTime = '',
    this.slot = const {},
  });

  factory VisionBookingDetails.fromJson(Map<String, dynamic> json) {
    return VisionBookingDetails(
      bookingType: (json['booking_type'] ?? '').toString(),
      bookingTime: (json['booking_time'] ?? '').toString(),
      preferredDateTime: (json['preferred_date_time'] ?? '').toString(),
      slot: (json['slot'] as Map<String, dynamic>?) ?? {},
    );
  }
}
