class VersionCheckResponse {
  final bool updateAvailable;
  final String message;

  const VersionCheckResponse({
    required this.updateAvailable,
    required this.message,
  });

  factory VersionCheckResponse.fromJson(Map<String, dynamic> json) =>
      VersionCheckResponse(
        updateAvailable: json['updateAvailable'] ?? false,
        message: json['message'] ?? '',
      );
}
