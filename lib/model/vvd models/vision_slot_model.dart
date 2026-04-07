class VisionSlotModel {
  final String slotId;
  final String slotDate;
  final String startTime;
  final String endTime;

  const VisionSlotModel({
    required this.slotId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
  });

  factory VisionSlotModel.fromJson(Map<String, dynamic> json) {
    return VisionSlotModel(
      slotId: (json['slot_id'] ?? '').toString(),
      slotDate: (json['slot_date'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'slot_id': slotId,
        'slot_date': slotDate,
        'start_time': startTime,
        'end_time': endTime,
      };

  /// Convert to the format expected by [CommonSlotSelector].
  Map<String, dynamic> toSelectorMap() => {
        'time': startTime,
        'isDisabled': false,
        'slot_id': slotId,
        'slot_date': slotDate,
        'start_time': startTime,
        'end_time': endTime,
      };
}

class VisionSlotsResponse {
  final List<String> daysList;
  final List<VisionSlotModel> morningSlots;
  final List<VisionSlotModel> afternoonSlots;
  final List<VisionSlotModel> eveningSlots;

  const VisionSlotsResponse({
    this.daysList = const [],
    this.morningSlots = const [],
    this.afternoonSlots = const [],
    this.eveningSlots = const [],
  });

  factory VisionSlotsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    List<VisionSlotModel> parseSlotList(dynamic val) {
      if (val is! List) return [];
      return val
          .whereType<Map>()
          .map((e) => VisionSlotModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final slots = data['slots'] is Map<String, dynamic>
        ? data['slots'] as Map<String, dynamic>
        : <String, dynamic>{};

    return VisionSlotsResponse(
      daysList: (data['daysList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      morningSlots: parseSlotList(slots['morning']),
      afternoonSlots: parseSlotList(slots['afternoon']),
      eveningSlots: parseSlotList(slots['evening']),
    );
  }
}
