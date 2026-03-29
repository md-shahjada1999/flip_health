class PrescriptionFile {
  final String id;
  final String name;
  final String path;
  final String? thumbnailUrl;
  final DateTime? uploadedAt;

  PrescriptionFile({
    required this.id,
    required this.name,
    required this.path,
    this.thumbnailUrl,
    this.uploadedAt,
  });
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
