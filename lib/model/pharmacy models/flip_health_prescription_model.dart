class FlipHealthPrescription {
  final String id;
  final int patientId;
  final String appointmentId;
  final String type;
  final bool isChronic;
  final String? endDate;
  final String? duration;
  final String? cancelNote;
  final String notes;
  final int status;
  final String createdAtDate;
  final PrescriptionDetails details;
  final PrescriptionAppointment? appointment;

  const FlipHealthPrescription({
    required this.id,
    required this.patientId,
    required this.appointmentId,
    this.type = 'LIST',
    this.isChronic = false,
    this.endDate,
    this.duration,
    this.cancelNote,
    this.notes = '',
    this.status = 1,
    this.createdAtDate = '',
    required this.details,
    this.appointment,
  });

  factory FlipHealthPrescription.fromJson(Map<String, dynamic> json) {
    return FlipHealthPrescription(
      id: (json['id'] ?? '').toString(),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id'].toString()) ?? 0,
      appointmentId: (json['appointment_id'] ?? '').toString(),
      type: (json['type'] ?? 'LIST').toString(),
      isChronic: json['isChronic'] == true,
      endDate: json['endDate']?.toString(),
      duration: json['duration']?.toString(),
      cancelNote: json['cancelNote']?.toString(),
      notes: (json['notes'] ?? '').toString(),
      status: json['status'] is int ? json['status'] : 1,
      createdAtDate: (json['createdAtDate'] ?? '').toString(),
      details: json['details'] is Map<String, dynamic>
          ? PrescriptionDetails.fromJson(json['details'])
          : const PrescriptionDetails(),
      appointment: json['appointment'] is Map<String, dynamic>
          ? PrescriptionAppointment.fromJson(json['appointment'])
          : null,
    );
  }

  int get medicineCount =>
      details.chronic.length + details.others.length;

  String get doctorName => appointment?.doctor?.name ?? '';
  String get doctorSpeciality =>
      appointment?.doctor?.speciality?.name ?? '';
}

class PrescriptionDetails {
  final List<MedicineItem> chronic;
  final List<MedicineItem> others;

  const PrescriptionDetails({
    this.chronic = const [],
    this.others = const [],
  });

  factory PrescriptionDetails.fromJson(Map<String, dynamic> json) {
    return PrescriptionDetails(
      chronic: (json['chronic'] as List<dynamic>?)
              ?.map((e) => MedicineItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      others: (json['others'] as List<dynamic>?)
              ?.map((e) => MedicineItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MedicineItem {
  final String name;
  final String days;
  final String type;
  final String morning;
  final String afternoon;
  final String night;
  final String weekly;
  final bool isChronic;

  const MedicineItem({
    required this.name,
    this.days = '',
    this.type = '',
    this.morning = '',
    this.afternoon = '',
    this.night = '',
    this.weekly = '0',
    this.isChronic = false,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      name: (json['name'] ?? '').toString(),
      days: (json['days'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      morning: (json['morning'] ?? '').toString(),
      afternoon: (json['afternoon'] ?? '').toString(),
      night: (json['night'] ?? '').toString(),
      weekly: (json['weekly'] ?? '0').toString(),
      isChronic: json['isChronic'] == true,
    );
  }

  bool get hasMorning =>
      morning.isNotEmpty &&
      morning.toLowerCase() != 'none';
  bool get hasAfternoon =>
      afternoon.isNotEmpty &&
      afternoon.toLowerCase() != 'none';
  bool get hasNight =>
      night.isNotEmpty &&
      night.toLowerCase() != 'none';
}

class PrescriptionAppointment {
  final String id;
  final String purpose;
  final String symptoms;
  final String history;
  final String diagnosis;
  final String recommendation;
  final PrescriptionDoctor? doctor;

  const PrescriptionAppointment({
    required this.id,
    this.purpose = '',
    this.symptoms = '',
    this.history = '',
    this.diagnosis = '',
    this.recommendation = '',
    this.doctor,
  });

  factory PrescriptionAppointment.fromJson(Map<String, dynamic> json) {
    return PrescriptionAppointment(
      id: (json['id'] ?? '').toString(),
      purpose: (json['purpose'] ?? '').toString(),
      symptoms: (json['symptoms'] ?? '').toString(),
      history: (json['history'] ?? '').toString(),
      diagnosis: (json['diagnosis'] ?? '').toString(),
      recommendation: (json['recommendation'] ?? '').toString(),
      doctor: json['doctor'] is Map<String, dynamic>
          ? PrescriptionDoctor.fromJson(json['doctor'])
          : null,
    );
  }
}

class PrescriptionDoctor {
  final int id;
  final String name;
  final String licenceNo;
  final String sign;
  final DoctorSpeciality? speciality;

  const PrescriptionDoctor({
    required this.id,
    required this.name,
    this.licenceNo = '',
    this.sign = '',
    this.speciality,
  });

  factory PrescriptionDoctor.fromJson(Map<String, dynamic> json) {
    return PrescriptionDoctor(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      licenceNo: (json['licenceNo'] ?? '').toString(),
      sign: (json['sign'] ?? '').toString(),
      speciality: json['speciality'] is Map<String, dynamic>
          ? DoctorSpeciality.fromJson(json['speciality'])
          : null,
    );
  }
}

class DoctorSpeciality {
  final int id;
  final String name;

  const DoctorSpeciality({required this.id, required this.name});

  factory DoctorSpeciality.fromJson(Map<String, dynamic> json) {
    return DoctorSpeciality(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}
