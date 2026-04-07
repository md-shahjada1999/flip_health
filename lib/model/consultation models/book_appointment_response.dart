class BookAppointmentResponse {
  final String appointmentId;
  final String message;
  final bool freeConsultation;
  final bool isSubscribed;
  final bool paymentRequired;
  final double price;

  const BookAppointmentResponse({
    required this.appointmentId,
    required this.message,
    this.freeConsultation = false,
    this.isSubscribed = false,
    this.paymentRequired = false,
    this.price = 0,
  });

  factory BookAppointmentResponse.fromJson(Map<String, dynamic> json) {
    return BookAppointmentResponse(
      appointmentId: (json['appointment_id'] ?? '').toString(),
      message: (json['message'] ?? 'Appointment booked').toString(),
      freeConsultation: json['freeConsultation'] == true,
      isSubscribed: json['isSubscribed'] == true,
      paymentRequired: json['paymentRequired'] == true,
      price: (json['price'] is num ? json['price'].toDouble() : 0),
    );
  }
}
