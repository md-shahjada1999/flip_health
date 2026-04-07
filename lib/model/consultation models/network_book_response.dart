class NetworkBookResponse {
  final String appointmentId;
  final String message;
  final String date;
  final String time;
  final String status;
  final Map<String, dynamic> additionalInfo;

  const NetworkBookResponse({
    required this.appointmentId,
    required this.message,
    this.date = '',
    this.time = '',
    this.status = '',
    this.additionalInfo = const {},
  });

  factory NetworkBookResponse.fromJson(Map<String, dynamic> json) {
    return NetworkBookResponse(
      appointmentId: (json['appointment_id'] ?? '').toString(),
      message: (json['message'] ?? 'Appointment booked').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      additionalInfo: json['additional_info'] as Map<String, dynamic>? ?? {},
    );
  }
}
