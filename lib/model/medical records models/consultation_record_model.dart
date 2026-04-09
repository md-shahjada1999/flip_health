import 'package:intl/intl.dart';

class ConsultationRecordModel {
  final String id;
  final int patientId;
  final int doctorId;
  final int specialityId;
  final int? issueId;
  final String date;
  final String time;
  final int status;
  final int completed;
  final String communication;
  final String source;
  final String type;
  final String? purpose;
  final String? language;
  final String? invoiceId;
  final int isPatientJoined;
  final int isDocJoined;
  final String? callEndedBy;
  final String? cancellationReason;
  final String? appointmentId;
  final String? networkId;

  final String doctorName;
  final String doctorSpeciality;
  final int? doctorSpecialityId;

  final String? timeSlot;
  final List<String> specialties;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ConsultationRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.specialityId = 0,
    this.issueId,
    required this.date,
    required this.time,
    required this.status,
    this.completed = 0,
    required this.communication,
    this.source = '',
    this.type = '',
    this.purpose,
    this.language,
    this.invoiceId,
    this.isPatientJoined = 0,
    this.isDocJoined = 0,
    this.callEndedBy,
    this.cancellationReason,
    this.appointmentId,
    this.networkId,
    required this.doctorName,
    this.doctorSpeciality = '',
    this.doctorSpecialityId,
    this.timeSlot,
    this.specialties = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOnline => communication.toUpperCase() == 'ONLINE';

  String get displayDate {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  String get displayTime {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2000, 1, 1, hour, minute);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return time;
    }
  }

  String get statusLabel {
    if (cancellationReason != null && cancellationReason!.isNotEmpty) {
      return 'Cancelled';
    }
    if (isPatientJoined == 1 && isDocJoined == 1) return 'Completed';
    if (status == 1 && completed == 0) {
      final appointmentDt = DateTime.tryParse('$date $time');
      if (appointmentDt != null && appointmentDt.isAfter(DateTime.now())) {
        return 'Upcoming';
      }
      return 'Missed';
    }
    if (status == 0) return 'Pending';
    return 'Completed';
  }

  factory ConsultationRecordModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>? ?? {};
    final speciality = doctor['speciality'] as Map<String, dynamic>? ?? {};
    final additionalInfo =
        json['additional_info'] as Map<String, dynamic>? ?? {};
    final bookingDetails =
        additionalInfo['booking_details'] as Map<String, dynamic>? ?? {};
    final rawSpecialties = bookingDetails['specialties'];

    return ConsultationRecordModel(
      id: (json['id'] ?? '').toString(),
      patientId: _toInt(json['patient_id']),
      doctorId: _toInt(json['doctor_id']),
      specialityId: _toInt(json['speciality_id']),
      issueId: json['issue_id'] is int ? json['issue_id'] : null,
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      status: _toInt(json['status']),
      completed: _toInt(json['completed']),
      communication: (json['communication'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      purpose: json['purpose']?.toString(),
      language: json['language']?.toString(),
      invoiceId: json['invoice_id']?.toString(),
      isPatientJoined: _toInt(json['isPatientJoined']),
      isDocJoined: _toInt(json['isDocJoined']),
      callEndedBy: json['callEndedBy']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      appointmentId: json['appointment_id']?.toString(),
      networkId: json['network_id']?.toString(),
      doctorName: (doctor['name'] ?? 'Doctor').toString(),
      doctorSpeciality: (speciality['name'] ?? '').toString(),
      doctorSpecialityId:
          speciality['id'] is int ? speciality['id'] : null,
      timeSlot: bookingDetails['time_slot']?.toString(),
      specialties: rawSpecialties is List
          ? rawSpecialties.map((e) => e.toString()).toList()
          : [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static List<ConsultationRecordModel> fromResultsList(
      Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            ConsultationRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
