import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/model/heath%20checkup%20models/family_member_data_model.dart';

class HealthCheckupRepository {
  final ApiService apiService;
  HealthCheckupRepository({required this.apiService});


  Future<List<Map<String, String>>> getAvailableDates() async {
    try {
      // TODO: Replace with actual API call
      return [
        {'day': '10', 'weekday': 'Mon'},
        {'day': '11', 'weekday': 'Tue'},
        {'day': '12', 'weekday': 'Wed'},
        {'day': '13', 'weekday': 'Thu'},
        {'day': '14', 'weekday': 'Fri'},
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }
}
