/// Response from POST /patient/register, /patient/link, /patient/resendotp
class OtpSendResponse {
  final String message;

  const OtpSendResponse({required this.message});

  factory OtpSendResponse.fromJson(Map<String, dynamic> json) =>
      OtpSendResponse(message: json['message'] ?? '');
}
