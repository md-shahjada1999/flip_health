class UploadResponse {
  final String id;
  final int userId;
  final String userType;
  final String title;
  final String path;
  final String type;
  final String ref;
  final String logo;

  const UploadResponse({
    required this.id,
    this.userId = 0,
    this.userType = '',
    this.title = '',
    this.path = '',
    this.type = '',
    this.ref = '',
    this.logo = '',
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      id: (json['id'] ?? '').toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      userType: (json['user_type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      ref: (json['ref'] ?? '').toString(),
      logo: (json['logo'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_type': userType,
        'title': title,
        'path': path,
        'type': type,
        'ref': ref,
        'logo': logo,
      };
}
