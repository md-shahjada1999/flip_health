class IssueModel {
  final int id;
  final String title;
  final String image;
  final bool assessmentRequired;
  final int parent;
  final String type;
  final int status;

  const IssueModel({
    required this.id,
    required this.title,
    this.image = '',
    this.assessmentRequired = false,
    this.parent = 0,
    this.type = 'issues',
    this.status = 1,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      assessmentRequired: json['assessment_required'] == 1 ||
          json['assessment_required'] == true,
      parent: json['parent'] is int
          ? json['parent']
          : int.tryParse(json['parent'].toString()) ?? 0,
      type: (json['type'] ?? 'issues').toString(),
      status: json['status'] is int ? json['status'] : 1,
    );
  }

  static List<IssueModel> fromListResponse(Map<String, dynamic> json) {
    final list = json['issues'] as List<dynamic>? ?? [];
    return list
        .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
        .where((i) => i.title.isNotEmpty)
        .toList();
  }
}
