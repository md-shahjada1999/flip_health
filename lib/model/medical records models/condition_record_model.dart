import 'package:intl/intl.dart';

class ConditionRecordModel {
  final String id;
  final int patientId;
  final String condition;
  final String description;
  final String note;
  final String history;
  final String? since;
  final String? ended;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConditionRecordModel({
    required this.id,
    required this.patientId,
    required this.condition,
    this.description = '',
    this.note = '',
    this.history = '',
    this.since,
    this.ended,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOngoing => ended == null || ended!.isEmpty;

  String get displaySince {
    if (since == null || since!.isEmpty) return '';
    try {
      final parsed = DateTime.parse(since!);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return since!;
    }
  }

  String get displayEnded {
    if (ended == null || ended!.isEmpty) return '';
    try {
      final parsed = DateTime.parse(ended!);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return ended!;
    }
  }

  String get conditionLabel {
    return condition.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
  }

  factory ConditionRecordModel.fromJson(Map<String, dynamic> json) {
    return ConditionRecordModel(
      id: (json['id'] ?? '').toString(),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id']?.toString() ?? '') ?? 0,
      condition: (json['condition'] ?? '').toString(),
      description: (json['desc'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      history: (json['history'] ?? '').toString(),
      since: json['since']?.toString(),
      ended: json['ended']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static List<ConditionRecordModel> fromResultsList(
      Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            ConditionRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
