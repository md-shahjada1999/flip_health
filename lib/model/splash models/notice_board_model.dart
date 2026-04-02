class NoticeBoardResponse {
  final List<Map<String, dynamic>>? banners;

  const NoticeBoardResponse({this.banners});

  factory NoticeBoardResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['banners'];
    List<Map<String, dynamic>>? parsed;
    if (raw is List && raw.isNotEmpty) {
      parsed = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return NoticeBoardResponse(banners: parsed);
  }

  bool get hasBanners => banners != null && banners!.isNotEmpty;
}
