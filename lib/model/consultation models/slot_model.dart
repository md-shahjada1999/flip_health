class SlotModel {
  final String date;
  final String time;
  final bool available;
  final String displayTime;

  const SlotModel({
    required this.date,
    required this.time,
    this.available = true,
    this.displayTime = '',
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      available: json['available'] == '1' || json['available'] == 1 || json['available'] == true,
      displayTime: (json['displayTime'] ?? '').toString(),
    );
  }

  static List<SlotModel> fromListResponse(Map<String, dynamic> json) {
    final list = json['slots'] as List<dynamic>? ?? [];
    return list
        .map((e) => SlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  int get hour {
    final parts = time.split(':');
    return int.tryParse(parts.firstOrNull ?? '') ?? 0;
  }

  bool get isMorning => hour >= 6 && hour < 12;
  bool get isAfternoon => hour >= 12 && hour < 17;
  bool get isEvening => hour >= 17;
}
