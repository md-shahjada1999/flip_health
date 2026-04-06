import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/vvd%20models/vaccine_type_model.dart';
import 'package:flip_health/model/vvd%20models/vaccine_service_response.dart';

class VaccineRepository {
  final ApiService apiService;
  VaccineRepository({required this.apiService});

  Future<List<VaccineType>> getVaccineTypes() async {
    try {
      final response = await apiService.get(
        ApiUrl.NETWORK_SERVICES,
        queryParameters: {'search': 'service_type:vaccine'},
      );
      PrintLog.printLog('VaccineRepository.getVaccineTypes status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw AppException(
          message: 'Failed to load vaccine types',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      List<dynamic> list;
      if (root is Map<String, dynamic>) {
        list = (root['data'] as List<dynamic>?) ?? [];
      } else if (root is List<dynamic>) {
        list = root;
      } else {
        return [];
      }

      return list
          .whereType<Map>()
          .map((e) => VaccineType.fromJson(Map<String, dynamic>.from(e)))
          .where((v) => v.id != 0 && v.name.isNotEmpty)
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('VaccineRepository.getVaccineTypes error: $e');
      throw AppException(message: 'Failed to load vaccine types: $e');
    }
  }

  /// Build the 5-day date list starting from the appropriate skip-day.
  /// Mirrors patient-app `getDays()`.
  Map<String, dynamic> getDays() {
    final now = DateTime.now();
    final skipDays = now.hour < 18 ? 1 : 2;
    final startDate = now.add(Duration(days: skipDays));

    final monthYear = '${_monthName(startDate.month)} ${startDate.year}';

    final dates = <Map<String, String>>[];
    final dateStrings = <String>[];
    final wholeDates = <DateTime>[];

    for (int i = 0; i < 5; i++) {
      final date = startDate.add(Duration(days: i));
      dates.add({
        'day': '${date.day}',
        'weekday': _weekdayName(date.weekday),
      });
      dateStrings.add(
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      );
      wholeDates.add(date);
    }

    return {
      'monthYearLabel': monthYear,
      'availableDates': dates,
      'calendarDateStrings': dateStrings,
      'wholeDates': wholeDates,
    };
  }

  /// Generate time-slot lists for a given date.
  /// Same rules as dental: Morning 10–12, Afternoon 12–13,
  /// Evening 16–20 (skipped on Sunday), 1-hr intervals, >24h filter.
  Map<String, List<Map<String, dynamic>>> getSlotsForDate(DateTime date) {
    final isSunday = date.weekday == DateTime.sunday;
    final now = DateTime.now();

    List<String> generateHourlySlots(String opening, String closing) {
      final startParts = opening.split(':');
      final closeParts = closing.split(':');
      int h = int.parse(startParts[0]);
      int m = int.parse(startParts[1]);
      final closeH = int.parse(closeParts[0]);
      final closeM = int.parse(closeParts[1]);

      final slots = <String>[];
      while (h < closeH || (h == closeH && m <= closeM)) {
        slots.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
        final next = DateTime(0, 0, 0, h, m).add(const Duration(hours: 1));
        h = next.hour;
        m = next.minute;
      }
      return slots;
    }

    List<Map<String, dynamic>> filterAndFormat(List<String> raw, DateTime date) {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final out = <Map<String, dynamic>>[];
      for (int i = 0; i < raw.length - 1; i++) {
        final slotDt = DateTime.parse('$dateStr ${raw[i]}:00.000');
        if (slotDt.difference(now).inHours > 24) {
          out.add({
            'time': _to12Hr(raw[i]),
            'time24': raw[i],
            'isDisabled': false,
          });
        }
      }
      return out;
    }

    final morning = filterAndFormat(generateHourlySlots('10:00', '12:00'), date);
    final afternoon = filterAndFormat(generateHourlySlots('12:00', '13:00'), date);
    final evening = isSunday
        ? <Map<String, dynamic>>[]
        : filterAndFormat(generateHourlySlots('16:00', '20:00'), date);

    return {
      'morningSlots': morning,
      'afternoonSlots': afternoon,
      'eveningSlots': evening,
    };
  }

  static String _to12Hr(String hhmm) {
    final parts = hhmm.split(':');
    var h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final amPm = h >= 12 ? 'PM' : 'AM';
    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }
    return '$h:${m.toString().padLeft(2, '0')} $amPm';
  }

  Future<VaccineServiceResponse> bookVaccineService({
    required String addressId,
    required String preferredDateTime,
    required String userId,
    required List<int> vaccineTypeIds,
    String alternatePhone = '',
    String conditions = '',
    String note = '',
    String language = '',
    List<String> attachmentIds = const [],
  }) async {
    try {
      final body = <String, dynamic>{
        'address_id': addressId,
        'preferred_date_time': preferredDateTime,
        'request': vaccineTypeIds,
        'alternate_phone': alternatePhone,
        'conditions': conditions,
        'note': note,
        'user_id': int.parse(userId),
        'language': language,
      };
      if (attachmentIds.isNotEmpty) {
        body['prescription'] =
            attachmentIds.map((id) => {'id': id}).toList();
      }

      final response =
          await apiService.post(ApiUrl.VACCINE_SERVICE_REQUEST, data: body);
      PrintLog.printLog('VaccineRepository.bookVaccineService status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ?? 'Booking failed')
              : 'Booking failed',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return VaccineServiceResponse.fromJson(data);
      }
      return VaccineServiceResponse(
        service: VaccineServiceData(
          id: '',
          patientId: 0,
          type: 'vaccine',
          status: 0,
          details: const VaccineBookingDetails(),
        ),
        message: 'Request submitted',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('VaccineRepository.bookVaccineService error: $e');
      throw AppException(message: 'Booking failed: $e');
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
