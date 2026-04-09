import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/model/heath%20checkup%20models/diagnostics_package_model.dart';

class HealthCheckupRepository {
  final ApiService apiService;
  HealthCheckupRepository({required this.apiService});

  Future<List<DiagnosticsPackage>> getPackages({
    required int userId,
    String type = 'tests',
    bool sponsored = false,
    String name = '',
  }) async {
    try {
      final response = await apiService.get(
        ApiUrl.DIAGNOSTICS_PACKAGES,
        queryParameters: {
          'type': type,
          'sponsored': sponsored,
          'name': name,
          'user': userId,
        },
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch packages',
          statusCode: response.statusCode,
        );
      }

      final root = response.data as Map<String, dynamic>;
      final list = root['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => DiagnosticsPackage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getPackages error: $e');
      throw AppException(message: 'Failed to load packages: $e');
    }
  }

  Future<DiagnosticsPackageDetail> getPackageDetail(int packageId) async {
    try {
      final response = await apiService.get(
        '${ApiUrl.DIAGNOSTICS_PACKAGE_DETAIL}$packageId',
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw AppException(
          message: 'Failed to fetch package details',
          statusCode: response.statusCode,
        );
      }

      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      return DiagnosticsPackageDetail.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      PrintLog.printLog('getPackageDetail error: $e');
      throw AppException(message: 'Failed to load package details: $e');
    }
  }

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
