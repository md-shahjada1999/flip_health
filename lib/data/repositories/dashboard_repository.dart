import 'package:dio/dio.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

/// Same response shape as patient_app `getDashboard` / `_processDashboardData`.
Map<String, dynamic> _unwrapPayload(Map<String, dynamic> root) {
  if (root['status'] == true && root['data'] != null) {
    final d = root['data'];
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);
  }
  return root;
}

/// Dashboard flags often arrive as `1`/`0` or strings; normalize for UI checks.
bool _parseBoolFlag(dynamic v) {
  if (v == true) return true;
  if (v == false || v == null) return false;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  return s == 'true' || s == '1' || s == 'yes';
}

class DashboardRepository {
  final ApiService apiService;

  DashboardRepository({required this.apiService});

  /// GET `/patient/dashboard` — ongoing orders, gym, AHC flag, notifications, etc.
  Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      final Response response = await apiService.get(ApiUrl.DASHBOARD);
      final raw = response.data;
      if (raw is! Map) {
        throw AppException(
          message: 'Invalid dashboard response',
          statusCode: response.statusCode,
        );
      }
      final root = _asJsonMap(raw);
      if (root['status'] == false) {
        throw AppException(
          message: root['message']?.toString() ?? 'Failed to load dashboard',
          statusCode: response.statusCode,
        );
      }
      final payload = _unwrapPayload(root);

      final caloriesBurnt = payload['calories_burnt'];
      double parsedCalories = 0.0;
      if (caloriesBurnt != null) {
        if (caloriesBurnt is num) {
          parsedCalories = double.parse(caloriesBurnt.toStringAsFixed(2));
        } else if (caloriesBurnt is String) {
          parsedCalories = double.tryParse(caloriesBurnt) ?? 0.0;
        }
      }

      return {
        'ahc': _parseBoolFlag(payload['ahc']),
        'gym': payload['gym'] ?? {},
        'notificationCount': payload['notificationCount'] ?? 0,
        'moodReceived': (payload['mood'] ?? 1) != 0,
        'jm_token': payload['jm_token'] ?? '',
        'water_consumed': payload['water_consumed'] ?? 0,
        'calories_burnt': parsedCalories,
        'ongoing': payload['ongoing'] ?? [],
      };
    } on AppException {
      rethrow;
    } catch (e, st) {
      PrintLog.printLog('DashboardRepository.fetchDashboard: $e\n$st');
      throw AppException(message: 'Could not load dashboard. Please try again.');
    }
  }
}
