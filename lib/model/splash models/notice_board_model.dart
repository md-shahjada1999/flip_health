class NoticeBoardResponse {
  final NoticeBanner? banner;

  const NoticeBoardResponse({this.banner});

  factory NoticeBoardResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['banners'];
    NoticeBanner? parsed;

    if (raw is Map<String, dynamic>) {
      parsed = NoticeBanner.fromJson(raw);
    } else if (raw is List && raw.isNotEmpty) {
      parsed = NoticeBanner.fromJson(Map<String, dynamic>.from(raw.first as Map));
    }

    return NoticeBoardResponse(banner: parsed);
  }

  bool get hasBanner => banner != null && banner!.status;
}

class NoticeBanner {
  final int id;
  final String? image;
  final String? eventStart;
  final String? eventEnd;
  final String? note;
  final bool blockLogin;
  final String type;
  final bool status;
  final String? createdAt;

  const NoticeBanner({
    required this.id,
    this.image,
    this.eventStart,
    this.eventEnd,
    this.note,
    this.blockLogin = false,
    this.type = 'notice',
    this.status = true,
    this.createdAt,
  });

  factory NoticeBanner.fromJson(Map<String, dynamic> json) {
    return NoticeBanner(
      id: json['id'] ?? 0,
      image: json['image'],
      eventStart: json['event_start_timestamp'],
      eventEnd: json['event_end_timestamp'],
      note: json['note'],
      blockLogin: json['blockLogin'] == true,
      type: json['type'] ?? 'notice',
      status: json['status'] == true,
      createdAt: json['createdAt'],
    );
  }
}
