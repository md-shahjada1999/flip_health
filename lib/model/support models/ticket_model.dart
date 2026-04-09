import 'package:flip_health/model/support%20models/ticket_feedback_model.dart';

class TicketModel {
  final String id;
  final bool canReopen;
  final String? type;
  final String? subType;
  final String message;
  final int userId;
  final String userType;
  final int? assignedTo;
  final int? assignedBy;
  final int status;
  final String language;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  TicketFeedbackModel? feedback;

  TicketModel({
    required this.id,
    this.canReopen = false,
    this.type,
    this.subType,
    required this.message,
    required this.userId,
    this.userType = 'patient',
    this.assignedTo,
    this.assignedBy,
    required this.status,
    this.language = '',
    this.priority = 1,
    required this.createdAt,
    required this.updatedAt,
    this.feedback,
  });

  bool get isClosed => status == 2;
  bool get isOpen => status == 1;
  bool get isCreated => status == 0;
  bool get canGiveFeedback => isClosed && feedback == null;

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Created';
      case 1:
        return 'Open';
      case 2:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: (json['id'] ?? '').toString(),
      canReopen: json['canReopen'] == true,
      type: json['type']?.toString(),
      subType: json['sub_type']?.toString(),
      message: (json['message'] ?? '').toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      userType: (json['user_type'] ?? 'patient').toString(),
      assignedTo: json['assigned_to'] is int ? json['assigned_to'] : null,
      assignedBy: json['assigned_by'] is int ? json['assigned_by'] : null,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status'].toString()) ?? 0,
      language: (json['language'] ?? '').toString(),
      priority: json['priority'] is int
          ? json['priority']
          : int.tryParse(json['priority'].toString()) ?? 1,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      feedback: json['feedback'] is Map<String, dynamic>
          ? TicketFeedbackModel.fromJson(json['feedback'])
          : null,
    );
  }

  static List<TicketModel> fromListResponse(Map<String, dynamic> json) {
    final list = json['tickets'] as List<dynamic>? ?? [];
    return list
        .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
