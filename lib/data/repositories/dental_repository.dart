import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';

class DentalRepository {
  final ApiService apiService;
  DentalRepository({required this.apiService});

  Future<List<FamilyMember>> getFamilyMembers() async {
    try {
      // TODO: Replace with actual API call
      return [
        FamilyMember(id: '1', name: 'Kalyan'),
        FamilyMember(id: '2', name: 'Priya',  hasPackages: true),
        FamilyMember(id: '3', name: 'Rahul',  hasPackages: false),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<VendorModel>> getVendors(String location, {String service = 'dental'}) async {
    try {
      final response = await apiService.get(
        ApiUrl.NETWORK_LIST,
        queryParameters: {'location': location, 'service': service},
      );
      PrintLog.printLog('DentalRepository.getVendors status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw AppException(
          message: response.data is Map ? (response.data['message']?.toString() ?? 'Failed to load clinics') : 'Failed to load clinics',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is! Map<String, dynamic>) {
        PrintLog.printLog('DentalRepository.getVendors: unexpected root type');
        return [];
      }

      Map<String, dynamic> payload = root;
      final nested = root['data'];
      if (nested is Map<String, dynamic>) {
        payload = nested;
      }

      final result = payload['result']?.toString().toLowerCase();
      if (result != null && result != 'success' && result != 'true' && result != '1') {
        final listFallback = payload['clnlist'] ?? payload['clnList'];
        if (listFallback == null) {
          PrintLog.printLog('DentalRepository.getVendors: non-success result without list');
          return [];
        }
      }

      final listRaw = payload['clnlist'] ?? payload['clnList'];
      if (listRaw is! List<dynamic>) {
        return [];
      }

      return listRaw
          .map((e) => VendorModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('DentalRepository.getVendors error: $e');
      throw AppException(message: 'Failed to load clinics: $e');
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

    for (int i = 0; i < 6; i++) {
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
  /// Mirrors patient-app `fetch_slots_data()` + `getSlotsFromLoop()`.
  ///
  /// Rules from patient-app:
  ///   Morning   10:00–12:00  (1-hr intervals → 10:00, 11:00, 12:00)
  ///   Afternoon  12:00–13:00 (→ 12:00, 13:00)
  ///   Evening    16:00–20:00 (→ 16:00, 17:00, 18:00, 19:00, 20:00) — skipped on Sunday
  ///
  /// Each slot is only included if the slot-time is more than 24 hours from now.
  /// The last element of each bucket is the "end boundary" and is not shown as
  /// a selectable slot (patient-app skips `index == length - 1`).
  ///
  /// Returns `{ morningSlots, afternoonSlots, eveningSlots }` where each slot is
  /// `{ 'time': '10:00 AM', 'time24': '10:00', 'isDisabled': false }`.
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
      // Patient-app iterates [0..length-1) for display but generates the full
      // range including the closing boundary.  We keep the same pattern: only
      // include slots where `slotTime - now > 24 h`, and skip the last entry
      // (the closing boundary) so the UI never shows it.
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

  /// Convert 24-hour `"16:00"` → `"4:00 PM"`.
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

  Future<void> bookDentalService({
    required String addressId,
    required String preferredDateTime,
    required String userId,
    required String providerId,
    required String clinicId,
    String alternatePhone = '',
    String conditions = '',
    String note = '',
    String language = 'en',
    required Map<String, dynamic> center,
  }) async {
    try {
      final body = {
        'address_id': addressId,
        'preferred_date_time': preferredDateTime,
        'alternate_phone': alternatePhone,
        'conditions': conditions,
        'note': note,
        'language': language,
        'provider_id': providerId,
        'clinic_id': clinicId,
        'user_id': userId,
        'center': center,
      };

      final response =
          await apiService.post(ApiUrl.DENTAL_SERVICE_REQUEST, data: body);
      PrintLog.printLog('DentalRepository.bookDentalService status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException(
          message: response.data is Map ? (response.data['message']?.toString() ?? 'Booking failed') : 'Booking failed',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data is Map) {
        final inner = data['data'];
        if (inner is Map) {
          final r = inner['result']?.toString().toLowerCase();
          if (r != null && r != 'success' && r != 'true' && r != '1') {
            throw AppException(
              message: inner['message']?.toString() ?? 'Booking failed',
            );
          }
        }
      }
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('DentalRepository.bookDentalService error: $e');
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
