class PrescriptionRecordModel {
  final String id;
  final int patientId;
  final String appointmentId;
  final int status;
  final bool isChronic;
  final String? endDate;
  final String? duration;
  final String? cancelNote;
  final String type;
  final String notes;
  final List<MedicineItem> chronicMedicines;
  final List<MedicineItem> otherMedicines;

  final String doctorName;
  final String? doctorImage;
  final String doctorSpeciality;
  final int doctorId;
  final double? doctorRating;
  final String? doctorExperience;
  final String? doctorSign;

  final String? purpose;
  final String? diagnosis;
  final String? recommendation;

  final String createdAtDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PrescriptionRecordModel({
    required this.id,
    required this.patientId,
    required this.appointmentId,
    required this.status,
    this.isChronic = false,
    this.endDate,
    this.duration,
    this.cancelNote,
    this.type = 'LIST',
    this.notes = '',
    this.chronicMedicines = const [],
    this.otherMedicines = const [],
    this.doctorName = '',
    this.doctorImage,
    this.doctorSpeciality = '',
    this.doctorId = 0,
    this.doctorRating,
    this.doctorExperience,
    this.doctorSign,
    this.purpose,
    this.diagnosis,
    this.recommendation,
    this.createdAtDate = '',
    required this.createdAt,
    required this.updatedAt,
  });

  List<MedicineItem> get allMedicines => [...chronicMedicines, ...otherMedicines];

  int get totalMedicines => allMedicines.length;

  String get statusLabel {
    if (cancelNote != null && cancelNote!.isNotEmpty) return 'Cancelled';
    if (status == 1) return 'Active';
    if (status == 0) return 'Inactive';
    return 'Unknown';
  }

  factory PrescriptionRecordModel.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    final chronicList = details['chronic'] as List? ?? [];
    final othersList = details['others'] as List? ?? [];

    final appointment = json['appointment'] as Map<String, dynamic>? ?? {};
    final doctor = appointment['doctor'] as Map<String, dynamic>? ?? {};
    final speciality = doctor['speciality'] as Map<String, dynamic>? ?? {};

    return PrescriptionRecordModel(
      id: (json['id'] ?? '').toString(),
      patientId: _toInt(json['patient_id']),
      appointmentId: (json['appointment_id'] ?? '').toString(),
      status: _toInt(json['status']),
      isChronic: json['isChronic'] == true,
      endDate: json['endDate']?.toString(),
      duration: json['duration']?.toString(),
      cancelNote: json['cancelNote']?.toString(),
      type: (json['type'] ?? 'LIST').toString(),
      notes: (json['notes'] ?? '').toString(),
      chronicMedicines: chronicList
          .map((e) => MedicineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      otherMedicines: othersList
          .map((e) => MedicineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      doctorName: (doctor['name'] ?? '').toString(),
      doctorImage: doctor['image']?.toString(),
      doctorSpeciality: (speciality['name'] ?? '').toString(),
      doctorId: _toInt(doctor['id']),
      doctorRating: _toDouble(doctor['rating']),
      doctorExperience: doctor['experience']?.toString(),
      doctorSign: doctor['sign']?.toString(),
      purpose: appointment['purpose']?.toString(),
      diagnosis: appointment['diagnosis']?.toString(),
      recommendation: appointment['recommendation']?.toString(),
      createdAtDate: (json['createdAtDate'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static List<PrescriptionRecordModel> fromResultsList(
      Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            PrescriptionRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
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
    this.weekly = '',
    this.isChronic = false,
  });

  List<String> get timings {
    final list = <String>[];
    if (_isValid(morning)) list.add(morning);
    if (_isValid(afternoon)) list.add(afternoon);
    if (_isValid(night)) list.add(night);
    return list;
  }

  String get timingSummary => timings.join(', ');

  String get durationText {
    if (days.isEmpty || days == '0') return '';
    final d = int.tryParse(days) ?? 0;
    return d == 1 ? '1 day' : '$d days';
  }

  String get weeklyText {
    if (weekly.isEmpty || weekly == '0') return '';
    final w = int.tryParse(weekly) ?? 0;
    return w == 1 ? '1x/week' : '${w}x/week';
  }

  bool _isValid(String value) {
    final lower = value.toLowerCase().trim();
    return lower.isNotEmpty && lower != 'none';
  }

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      name: (json['name'] ?? '').toString(),
      days: (json['days'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      morning: (json['morning'] ?? '').toString(),
      afternoon: (json['afternoon'] ?? '').toString(),
      night: (json['night'] ?? '').toString(),
      weekly: (json['weekly'] ?? '').toString(),
      isChronic: json['isChronic'] == true,
    );
  }
}
