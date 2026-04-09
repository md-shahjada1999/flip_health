import 'dart:convert';

import 'package:flip_health/core/services/api%20services/api_urls.dart';

class TicketMessageModel {
  final String id;
  final String ticketId;
  final dynamic message;
  final String type;
  final int userId;
  final String userType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userName;
  final bool? canReopen;
  final int? status;

  const TicketMessageModel({
    required this.id,
    this.ticketId = '',
    required this.message,
    this.type = 'TXT',
    required this.userId,
    this.userType = 'patient',
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.canReopen,
    this.status,
  });

  bool get isFromPatient => userType == 'patient';
  bool get isSystem => userType == 'system';
  bool get isAgent => userType == 'user';
  bool get isImage => type == 'IMG';
  bool get isPdf => type == 'PDF';
  bool get isAttachment => isImage || isPdf;

  String get displayMessage {
    final map = _messageMap;
    if (map != null) {
      return (map['title'] ?? map['path'] ?? '').toString();
    }
    if (message is String) return message;
    return message.toString();
  }

  /// Parses message as a Map, handling both parsed maps and JSON strings.
  Map<String, dynamic>? get _messageMap {
    if (message is Map) return message as Map<String, dynamic>;
    if (message is String) {
      try {
        final decoded = jsonDecode(message);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }

  /// Full public URL for image/PDF attachments.
  String? get fileUrl {
    if (!isAttachment) return null;
    final map = _messageMap;
    if (map != null) {
      final path = (map['path'] ?? '').toString();
      if (path.isEmpty) return null;
      return ApiUrl.publicFileUrl(path);
    }
    return null;
  }

  String? get imagePath => isImage ? fileUrl : null;

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;

    return TicketMessageModel(
      id: (json['id'] ?? '').toString(),
      ticketId: (json['ticket_id'] ?? '').toString(),
      message: json['message'],
      type: (json['type'] ?? 'TXT').toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      userType: (json['user_type'] ?? 'patient').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      userName: userMap?['name']?.toString(),
      canReopen: json['canReopen'] == true ? true : null,
      status: json['status'] is int ? json['status'] : null,
    );
  }

  static List<TicketMessageModel> fromListResponse(Map<String, dynamic> json) {
    final list = json['ticketMessages'] as List<dynamic>? ?? [];
    return list
        .map((e) => TicketMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
