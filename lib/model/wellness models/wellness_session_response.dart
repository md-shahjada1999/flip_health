/// Response for POST `/patient/wellness/session`
class WellnessSessionResponse {
  final bool status;
  final String message;

  const WellnessSessionResponse({
    required this.status,
    required this.message,
  });

  factory WellnessSessionResponse.fromJson(Map<String, dynamic> json) {
    return WellnessSessionResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}
