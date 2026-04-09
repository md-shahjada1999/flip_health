class TicketFeedbackModel {
  final String id;
  final int rating;
  final String description;
  final DateTime? createdAt;

  const TicketFeedbackModel({
    required this.id,
    required this.rating,
    this.description = '',
    this.createdAt,
  });

  factory TicketFeedbackModel.fromJson(Map<String, dynamic> json) {
    return TicketFeedbackModel(
      id: (json['id'] ?? '').toString(),
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating'].toString()) ?? 0,
      description: (json['description'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
