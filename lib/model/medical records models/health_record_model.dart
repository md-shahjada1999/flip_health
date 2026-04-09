import 'package:intl/intl.dart';

/// Shared model for vitals, symptoms, medicines, moods, and measurements.
class HealthRecordModel {
  final String id;
  final int patientId;
  final String value;
  final String? unit;
  final String? type;
  final String? frequency;
  final String? title;
  final String? dose;
  final String? description;
  final String? source;
  final String? sourceId;
  final Map<String, dynamic>? details;
  final String datetime;
  final int status;
  final String category;
  final String ref;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthRecordModel({
    required this.id,
    required this.patientId,
    required this.value,
    this.unit,
    this.type,
    this.frequency,
    this.title,
    this.dose,
    this.description,
    this.source,
    this.sourceId,
    this.details,
    required this.datetime,
    required this.status,
    this.category = '',
    this.ref = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Vital helpers ──

  String get vitalTypeLabel => switch (type?.toUpperCase()) {
        'HR' => 'Heart Rate',
        'O2' => 'SpO2',
        'TEMP' => 'Temperature',
        'BP' => 'Blood Pressure',
        'RR' => 'Respiratory Rate',
        'SUGAR' => 'Blood Sugar',
        _ => type ?? 'Vital',
      };

  String get vitalUnit => switch (type?.toUpperCase()) {
        'HR' => 'bpm',
        'O2' => '%',
        'TEMP' => '°F',
        'BP' => 'mmHg',
        'RR' => 'breaths/min',
        'SUGAR' => 'mg/dL',
        _ => unit ?? '',
      };

  String get displayValue {
    if (value.isEmpty) return '—';
    final u = vitalUnit;
    return u.isNotEmpty ? '$value $u' : value;
  }

  // ── Symptom helpers ──

  bool get isChronic => ref.toLowerCase() == 'chronic';

  // ── Medicine helpers ──

  String get medicineName => value;

  String get doseDisplay {
    if (dose == null || dose!.isEmpty) return '';
    return dose!;
  }

  // ── Mood helpers ──

  int get moodValue => int.tryParse(value) ?? 0;

  String get moodLabel => switch (moodValue) {
        1 => 'Very Sad',
        2 => 'Sad',
        3 => 'Neutral',
        4 => 'Happy',
        5 => 'Very Happy',
        _ => 'Unknown',
      };

  String get moodEmoji => switch (moodValue) {
        1 => '😢',
        2 => '😔',
        3 => '😐',
        4 => '😊',
        5 => '😄',
        _ => '❓',
      };

  // ── Measurement (BMI) helpers ──

  double? get bmiValue => double.tryParse(value);

  double? get heightValue {
    if (details == null) return null;
    final h = details!['height'];
    if (h is num) return h.toDouble();
    return double.tryParse(h?.toString() ?? '');
  }

  double? get weightValue {
    if (details == null) return null;
    final w = details!['weight'];
    if (w is num) return w.toDouble();
    return double.tryParse(w?.toString() ?? '');
  }

  String get bmiCategory {
    final bmi = bmiValue;
    if (bmi == null) return '';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String get measurementTypeLabel {
    final t = type?.toLowerCase();
    if (t == 'height') return 'Height Update';
    if (t == 'weight') return 'Weight Update';
    return 'BMI Update';
  }

  // ── Common helpers ──

  String get displayDate {
    try {
      final parsed = DateTime.parse(datetime);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return datetime;
    }
  }

  String get displayTime {
    try {
      final parsed = DateTime.parse(datetime);
      return DateFormat('hh:mm a').format(parsed);
    } catch (_) {
      return '';
    }
  }

  String get displayDateTime {
    final d = displayDate;
    final t = displayTime;
    return t.isNotEmpty ? '$d  •  $t' : d;
  }

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: (json['id'] ?? '').toString(),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id']?.toString() ?? '') ?? 0,
      value: (json['value'] ?? '').toString(),
      unit: json['unit']?.toString(),
      type: json['type']?.toString(),
      frequency: json['frequency']?.toString(),
      title: json['title']?.toString(),
      dose: json['dose']?.toString(),
      description: json['description']?.toString(),
      source: json['source']?.toString(),
      sourceId: json['source_id']?.toString(),
      details: json['details'] is Map<String, dynamic>
          ? json['details']
          : null,
      datetime: (json['datetime'] ?? '').toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      category: (json['category'] ?? '').toString(),
      ref: (json['ref'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static List<HealthRecordModel> fromResultsList(Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return list
        .map((e) => HealthRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
