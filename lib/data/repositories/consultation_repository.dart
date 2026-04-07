import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/model/consultation%20models/issue_model.dart';
import 'package:flip_health/model/consultation%20models/online_doctor_model.dart';
import 'package:flip_health/model/consultation%20models/slot_model.dart';
import 'package:flip_health/model/consultation%20models/book_appointment_response.dart';
import 'package:flip_health/model/consultation%20models/offline_speciality_model.dart';
import 'package:flip_health/model/consultation%20models/network_doctor_model.dart';
import 'package:flip_health/model/consultation%20models/network_slots_response.dart';
import 'package:flip_health/model/consultation%20models/network_book_response.dart';

class ConsultationRepository {
  final ApiService apiService;

  ConsultationRepository({required this.apiService});

  // ─── Online / Virtual flow ───────────────────────────────────

  Future<List<IssueModel>> getIssues() async {
    try {
      final response = await apiService.get(ApiUrl.ISSUES);
      final data = response.data as Map<String, dynamic>? ?? {};
      return IssueModel.fromListResponse(data);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<OnlineDoctorModel>> getDoctorsBySpeciality(int specialityId) async {
    try {
      final response = await apiService.get(
        '${ApiUrl.SPECIALITY_DOCTORS}/$specialityId/doctors',
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return OnlineDoctorModel.fromListResponse(data);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<SlotModel>> getAvailableSlots({
    required String date,
    required int spid,
    required String language,
  }) async {
    try {
      final response = await apiService.get(
        ApiUrl.AVAILABLE_SLOTS,
        queryParameters: {
          'date': date,
          'spid': spid,
          'language': language,
        },
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return SlotModel.fromListResponse(data);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<BookAppointmentResponse> bookOnlineAppointment({
    required String date,
    required String time,
    required String language,
    required String patientId,
    required int issueId,
    String? assessmentId,
    String? purpose,
  }) async {
    try {
      final body = <String, dynamic>{
        'date': date,
        'time': time,
        'language': language,
        'patient_id': int.parse(patientId),
        'issue_id': issueId,
        if (assessmentId != null) 'assessment_id': assessmentId,
        if (purpose != null && purpose.isNotEmpty) 'purpose': purpose,
      };
      final response = await apiService.post(
        '${ApiUrl.BOOK_APPOINTMENT}?status=confirm',
        data: body,
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return BookAppointmentResponse.fromJson(data);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  // ─── Offline / Hospital flow ─────────────────────────────────

  Future<List<OfflineSpecialityModel>> getOfflineSpecialities() async {
    try {
      final response = await apiService.get(
        ApiUrl.SPECIALTIES,
        queryParameters: {'consultation_type': 1},
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return OfflineSpecialityModel.fromListResponse(data);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<NetworkDoctorModel>> getNearbyDoctors({
    required String location,
    required int specialityId,
  }) async {
    try {
      final response = await apiService.get(
        ApiUrl.NETWORK_LIST,
        queryParameters: {
          'location': location,
          'service': 'consultation',
          'speciality_id': specialityId,
        },
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return NetworkDoctorModel.fromListResponse(data);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<NetworkSlotsResponse> getNetworkSlots({
    required String networkId,
    required int doctorId,
  }) async {
    try {
      final response = await apiService.get(
        '${ApiUrl.NETWORK_SLOTS}/$networkId',
        queryParameters: {'doctor_id': doctorId},
      );
      final data = response.data as Map<String, dynamic>? ?? {};
      return NetworkSlotsResponse.fromJson(data);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<NetworkBookResponse> bookOfflineAppointment({
    required int doctorId,
    required String networkId,
    required String timeSlot,
    required int specialityId,
    required String addressId,
    required String patientId,
  }) async {
    try {
      final body = <String, dynamic>{
        'doctor_id': doctorId,
        'network_id': networkId,
        'time_slot': timeSlot,
        'speciality_id': specialityId,
        'address_id': addressId,
        "patient_id": int.parse(patientId),
      };
      final response = await apiService.post(ApiUrl.NETWORK_BOOK, data: body);
      final data = response.data as Map<String, dynamic>? ?? {};
      return NetworkBookResponse.fromJson(data);
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }
}
