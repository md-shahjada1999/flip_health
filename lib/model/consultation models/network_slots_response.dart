class NetworkSlotsResponse {
  final String networkId;
  final String networkName;
  final List<NetworkDoctorSchedule> doctors;

  const NetworkSlotsResponse({
    this.networkId = '',
    this.networkName = '',
    this.doctors = const [],
  });

  factory NetworkSlotsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final doctorsList = data['network_doctor'] as List<dynamic>? ?? [];
    return NetworkSlotsResponse(
      networkId: (data['id'] ?? '').toString(),
      networkName: (data['name'] ?? '').toString(),
      doctors: doctorsList
          .map((e) =>
              NetworkDoctorSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NetworkDoctorSchedule {
  final int doctorId;
  final String doctorName;
  final List<NetworkSchedule> schedules;

  const NetworkDoctorSchedule({
    this.doctorId = 0,
    this.doctorName = '',
    this.schedules = const [],
  });

  factory NetworkDoctorSchedule.fromJson(Map<String, dynamic> json) {
    final scheduleList = json['schedules'] as List<dynamic>? ?? [];
    return NetworkDoctorSchedule(
      doctorId: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      doctorName: (json['name'] ?? '').toString(),
      schedules: scheduleList
          .map((e) => NetworkSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NetworkSchedule {
  final String day;
  final String shortCode;
  final List<ScheduleTiming> timings;

  const NetworkSchedule({
    this.day = '',
    this.shortCode = '',
    this.timings = const [],
  });

  factory NetworkSchedule.fromJson(Map<String, dynamic> json) {
    final timingsList = json['timings'] as List<dynamic>? ?? [];
    return NetworkSchedule(
      day: (json['day'] ?? '').toString(),
      shortCode: (json['short_code'] ?? '').toString(),
      timings: timingsList
          .map((e) => ScheduleTiming.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ScheduleTiming {
  final int id;
  final String opening;
  final String closing;

  const ScheduleTiming({
    this.id = 0,
    this.opening = '',
    this.closing = '',
  });

  factory ScheduleTiming.fromJson(Map<String, dynamic> json) {
    return ScheduleTiming(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      opening: (json['opening'] ?? '').toString().trim(),
      closing: (json['closing'] ?? '').toString().trim(),
    );
  }

  String get display => '$opening - $closing';
}
