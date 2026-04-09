import 'package:intl/intl.dart';

/// Shared model for womens health, mental wellness, and nutrition service requests.
class ServiceRequestModel {
  final String id;
  final int patientId;
  final String type;
  final String? invoiceId;
  final String? visitType;
  final String? source;
  final int status;
  final String? cancellationReason;
  final int? assignedTo;
  final String? jobId;

  final String serviceName;
  final String? serviceArea;
  final String? bookingTime;
  final String? phone;
  final String? email;

  final String? centerName;
  final String? centerAddress;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceRequestModel({
    required this.id,
    required this.patientId,
    required this.type,
    this.invoiceId,
    this.visitType,
    this.source,
    required this.status,
    this.cancellationReason,
    this.assignedTo,
    this.jobId,
    this.serviceName = '',
    this.serviceArea,
    this.bookingTime,
    this.phone,
    this.email,
    this.centerName,
    this.centerAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    if (cancellationReason != null && cancellationReason!.isNotEmpty) {
      return 'Cancelled';
    }
    if (status == 1) return 'Active';
    if (status == 2) return 'Completed';
    if (status == 0) return 'Pending';
    return 'Unknown';
  }

  bool get isAssigned => assignedTo != null;

  String get visitTypeLabel =>
      visitType?.toUpperCase() == 'HOME_PICKUP' ? 'Home Visit' : 'Self Visit';

  String get displayBookingTime {
    if (bookingTime == null || bookingTime!.isEmpty) return '';
    try {
      final parsed = DateTime.parse(bookingTime!);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return bookingTime!;
    }
  }

  String get displayDate {
    try {
      return DateFormat('dd MMM yyyy').format(createdAt);
    } catch (_) {
      return '';
    }
  }

  String get typeLabel => switch (type.toLowerCase()) {
        'mentalwellness' => 'Mental Wellness',
        'nutrition' => 'Diet & Nutrition',
        'womens' => "Women's Health",
        _ => type,
      };

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    final contact =
        details['contact_details'] as Map<String, dynamic>? ?? {};
    final center = details['center'] as Map<String, dynamic>?;

    String? centerName;
    String? centerAddr;
    if (center != null && center.isNotEmpty) {
      centerName = center['name']?.toString();
      final addr = center['address'];
      if (addr is Map<String, dynamic>) {
        centerAddr = addr['display_address']?.toString() ??
            [addr['line_1'], addr['city'], addr['state']]
                .where((e) => e != null && e.toString().isNotEmpty)
                .join(', ');
      }
      centerAddr ??= center['display_address']?.toString();
    }

    return ServiceRequestModel(
      id: (json['id'] ?? '').toString(),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id']?.toString() ?? '') ?? 0,
      type: (json['type'] ?? '').toString(),
      invoiceId: json['invoice_id']?.toString(),
      visitType: json['visit_type']?.toString(),
      source: json['source']?.toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      cancellationReason: json['cancellation_reason']?.toString(),
      assignedTo: json['assigned_to'] is int ? json['assigned_to'] : null,
      jobId: json['jobId']?.toString(),
      serviceName: (details['service'] ?? '').toString(),
      serviceArea: details['service_area']?.toString(),
      bookingTime: details['booking_time']?.toString(),
      phone: contact['phone']?.toString(),
      email: contact['email']?.toString(),
      centerName: centerName,
      centerAddress: centerAddr,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static List<ServiceRequestModel> fromResultsList(
      Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            ServiceRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
