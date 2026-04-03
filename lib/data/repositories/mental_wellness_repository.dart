import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/wellness%20models/mental_wellness_category_model.dart';
import 'package:flip_health/model/wellness%20models/wellness_session_response.dart';

class MentalWellnessRepository {
  final ApiService apiService;

  MentalWellnessRepository({required this.apiService});

  /// GET `/patient/mental_wellness/type` — categories for Mental Wellness (`value` per item).
  Future<List<MentalWellnessCategoryModel>> fetchMentalWellnessCategories() async {
    try {
      final Response response =
          await apiService.get(ApiUrl.MENTAL_WELLNESS_TYPES);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw AppException(message: 'Invalid categories response');
      }
      if (data['status'] == true && data['data'] is List) {
        final list = data['data'] as List<dynamic>;
        return list.map((e) {
          if (e is Map<String, dynamic>) {
            return MentalWellnessCategoryModel.fromJson(e);
          }
          if (e is Map) {
            return MentalWellnessCategoryModel.fromJson(
              Map<String, dynamic>.from(e),
            );
          }
          return const MentalWellnessCategoryModel(value: '');
        }).where((c) => c.value.isNotEmpty).toList();
      }
      throw AppException(
        message: data['message']?.toString() ?? 'Failed to load categories',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('fetchMentalWellnessCategories: $e');
      throw AppException(message: 'Could not load categories. Please try again.');
    }
  }

  /// POST `/patient/wellness/session` — same payload shape as patient_app `submit`.
  Future<WellnessSessionResponse> submitWellnessSession({
    required String phone,
    required String email,
    required String service,
    required String language,
    String? serviceArea,
    /// Family member profile id from `/patient/member` (optional; backend may use for Trijog).
    String? userId,
  }) async {
    try {
      final body = <String, dynamic>{
        'phone': phone,
        'email': email,
        'service': service,
        'language': language,
      };
      if (userId != null && userId.isNotEmpty) {
        body['user_id'] = userId;
      }
      if (service == 'Mental Wellness' &&
          serviceArea != null &&
          serviceArea.isNotEmpty) {
        body['service_area'] = serviceArea;
      }

      PrintLog.printLog('Wellness session body: $body');
      final Response response =
          await apiService.post(ApiUrl.WELLNESS_SESSION, data: body);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final parsed = WellnessSessionResponse.fromJson(data);
        if (parsed.status &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          return parsed;
        }
        throw AppException(
          message: parsed.message.isNotEmpty
              ? parsed.message
              : 'Request could not be completed',
          statusCode: response.statusCode,
        );
      }

      throw AppException(message: 'Unexpected response from server');
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('submitWellnessSession: $e');
      throw AppException(message: 'Failed to submit request. Please try again.');
    }
  }
}
