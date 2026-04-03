import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/health_score%20models/health_score_response.dart';

class HealthScoreRepository {
  final ApiService apiService;

  HealthScoreRepository({required this.apiService});

  /// PATCH /healthscore -- submit user health data and get BMI from backend
  Future<HealthScoreApiResponse> submitHealthScore({
    required String name,
    required String gender,
    required String dob,
    required String height,
    required double weight,
    required String isDiabetic,
    required String language,
    required String isBloodPressure,
  }) async {
    try {
      final body = {
        'name': name,
        'gender': gender,
        'dob': dob,
        'height': height,
        'weight': weight,
        'isDiabetic': isDiabetic,
        'language': language,
        'isBloodPressure': isBloodPressure,
      };
      PrintLog.printLog('HealthScore body: $body');

      final response = await apiService.patch(ApiUrl.HEALTH_SCORE, data: body);
      PrintLog.printLog('HealthScore status: ${response.statusCode}');

      final data = response.data;
      if (data is Map<String, dynamic> && response.statusCode == 200) {
        return HealthScoreApiResponse.fromJson(data);
      }

      throw AppException(
        message: data is Map ? (data['message'] ?? 'Failed to update health score') : 'Unexpected response',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('submitHealthScore error: $e');
      throw AppException(message: 'Failed to submit health score. Please try again.');
    }
  }
}
