import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/vvd%20models/vendor_model.dart';
import 'package:flip_health/model/vvd%20models/vision_booking_response.dart';
import 'package:flip_health/model/vvd%20models/vision_network_model.dart';
import 'package:flip_health/model/vvd%20models/vision_slot_model.dart';

class VisionRepository {
  final ApiService apiService;
  VisionRepository({required this.apiService});

  /// Fetch clinics (`vision.clinic`) or stores (`vision.store`) near [location].
  Future<List<VendorModel>> getVendors(
    String location, {
    required bool isEyeCheckup,
  }) async {
    try {
      final service = isEyeCheckup ? 'vision.clinic' : 'vision.store';
      final response = await apiService.get(
        ApiUrl.NETWORK_LIST,
        queryParameters: {'location': location, 'service': service},
      );
      PrintLog.printLog(
          'VisionRepository.getVendors status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ??
                  'Failed to load vendors')
              : 'Failed to load vendors',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is! Map<String, dynamic>) return [];

      final listRaw = root['data'];
      if (listRaw is! List<dynamic>) return [];

      return listRaw
          .whereType<Map>()
          .map((e) => VisionNetworkModel.fromJson(
              Map<String, dynamic>.from(e)))
          .map((n) => n.toVendorModel())
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('VisionRepository.getVendors error: $e');
      throw AppException(message: 'Failed to load vendors: $e');
    }
  }

  /// Fetch available slots from the API.
  /// Returns parsed response with daysList and categorised slot lists,
  /// plus pre-formatted data for [CommonSlotSelector].
  Future<Map<String, dynamic>> getSlots() async {
    try {
      final response = await apiService.get(ApiUrl.SERVICE_SLOTS);
      PrintLog.printLog(
          'VisionRepository.getSlots status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw AppException(
          message: 'Failed to load slots',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw AppException(message: 'Unexpected slots response format');
      }

      final slotsResponse = VisionSlotsResponse.fromJson(data);

      final availableDates = <Map<String, String>>[];
      for (final dateStr in slotsResponse.daysList) {
        final dt = DateTime.tryParse(dateStr);
        if (dt != null) {
          availableDates.add({
            'day': '${dt.day}',
            'weekday': _weekdayName(dt.weekday),
          });
        }
      }

      final monthYear = slotsResponse.daysList.isNotEmpty
          ? () {
              final dt = DateTime.tryParse(slotsResponse.daysList.first);
              return dt != null
                  ? '${_monthName(dt.month)} ${dt.year}'
                  : '';
            }()
          : '';

      return {
        'monthYearLabel': monthYear,
        'availableDates': availableDates,
        'daysList': slotsResponse.daysList,
        'morningSlots': slotsResponse.morningSlots
            .map((s) => s.toSelectorMap())
            .toList(),
        'afternoonSlots': slotsResponse.afternoonSlots
            .map((s) => s.toSelectorMap())
            .toList(),
        'eveningSlots': slotsResponse.eveningSlots
            .map((s) => s.toSelectorMap())
            .toList(),
      };
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('VisionRepository.getSlots error: $e');
      throw AppException(message: 'Failed to load slots: $e');
    }
  }

  /// Book a vision service (eye checkup or lens).
  Future<VisionBookingResponse> bookVisionService({
    required String bookingType,
    required int userId,
    required String addressId,
    required Map<String, dynamic> slot,
    String networkId = '',
    List<Map<String, String>> prescription = const [],
  }) async {
    try {
      final body = <String, dynamic>{
        'booking_type': bookingType,
        'user_id': userId,
        'network_id': networkId,
        'address_id': addressId,
        'slot': slot,
      };
      if (prescription.isNotEmpty) {
        body['prescription'] = prescription;
      }

      final response =
          await apiService.post(ApiUrl.VISION_SERVICE_REQUEST, data: body);
      PrintLog.printLog(
          'VisionRepository.bookVisionService status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException(
          message: response.data is Map
              ? (response.data['message']?.toString() ?? 'Booking failed')
              : 'Booking failed',
          statusCode: response.statusCode,
        );
      }

      final root = response.data;
      if (root is Map<String, dynamic>) {
        return VisionBookingResponse.fromJson(root);
      }
      return VisionBookingResponse(
        service: VisionBookingService(
          id: '',
          details: const VisionBookingDetails(),
        ),
        message: 'Request submitted',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('VisionRepository.bookVisionService error: $e');
      throw AppException(message: 'Booking failed: $e');
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
